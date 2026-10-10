"""Fixture pytest.

Test memakai database PostgreSQL TERPISAH (default `skinsight_test`) yang dibuat otomatis jika belum ada.
URL diambil dari env TEST_DATABASE_URL, lalu dari file .env, lalu nilai default di bawah.
Nama database wajib mengandung "test" sebagai pengaman agar database development tidak ikut terhapus.
"""

import os
from collections.abc import Callable, Iterator
from pathlib import Path
from typing import Any

import pytest
from dotenv import dotenv_values

BACKEND_DIR = Path(__file__).resolve().parents[1]
TEST_DATABASE_URL = (
    os.environ.get("TEST_DATABASE_URL")
    or dotenv_values(BACKEND_DIR / ".env").get("TEST_DATABASE_URL")
    or "postgresql+psycopg://skinsight:skinsight@localhost:5433/skinsight_test"
)

# Environment test di-set SEBELUM modul `app` di-import (Settings dibaca saat import).
os.environ.update(
    {
        "APP_ENV": "test",
        "DATABASE_URL": TEST_DATABASE_URL,
        "JWT_SECRET_KEY": "test-only-secret-key-bukan-untuk-production-123",
        "ML_MODE": "mock",
        "ML_LABELS": "combination,dry,normal,oily",
        "SAVE_SCAN_IMAGES": "false",
        "SCAN_IMAGE_DIR": "storage/test-scans",
        "MAX_UPLOAD_SIZE_MB": "2",
        "RATE_LIMIT_ENABLED": "true",
        "RATE_LIMIT_AUTH_REQUESTS": "1000",
        "RATE_LIMIT_SCANS_REQUESTS": "1000",
        "LOG_LEVEL": "WARNING",
        "CORS_ORIGINS": "*",
        "APP_TIMEZONE": "Asia/Jakarta",
    }
)

from fastapi.testclient import TestClient  # noqa: E402
from httpx import Response  # noqa: E402
from sqlalchemy import create_engine, text  # noqa: E402
from sqlalchemy.engine import make_url  # noqa: E402
from sqlalchemy.orm import Session  # noqa: E402

from app import models as _models  # noqa: E402,F401  (registrasi semua tabel)
from app.core.config import Settings, get_settings  # noqa: E402
from app.core.rate_limit import limiter  # noqa: E402
from app.db.base import Base  # noqa: E402
from app.db.seed import seed_all  # noqa: E402
from app.db.session import SessionLocal, engine  # noqa: E402
from app.main import app as fastapi_app  # noqa: E402
from tests.helpers import API, make_image_bytes  # noqa: E402


def _ensure_test_database(url: str) -> None:
    """Buat database test jika belum ada (user DB butuh hak CREATE DATABASE)."""
    db_url = make_url(url)
    if "test" not in (db_url.database or ""):
        raise RuntimeError(f"Nama database test harus mengandung 'test' (sekarang: {db_url.database}).")
    admin_engine = create_engine(db_url.set(database="postgres"), isolation_level="AUTOCOMMIT")
    try:
        with admin_engine.connect() as connection:
            exists = connection.scalar(
                text("SELECT 1 FROM pg_database WHERE datname = :name"), {"name": db_url.database}
            )
            if not exists:
                connection.execute(text(f'CREATE DATABASE "{db_url.database}"'))
    finally:
        admin_engine.dispose()


@pytest.fixture(scope="session", autouse=True)
def _test_database() -> Iterator[None]:
    _ensure_test_database(TEST_DATABASE_URL)
    Base.metadata.drop_all(engine)
    Base.metadata.create_all(engine)
    yield
    Base.metadata.drop_all(engine)
    engine.dispose()


@pytest.fixture(autouse=True)
def _clean_state(_test_database: None) -> Iterator[None]:
    """Setiap test mulai dari tabel kosong + seed data referensi (kondisi, ingredients, produk, edukasi)."""
    with SessionLocal() as db:
        for table in reversed(Base.metadata.sorted_tables):
            db.execute(table.delete())
        db.commit()
        seed_all(db)
    limiter.reset()
    yield


@pytest.fixture
def settings() -> Settings:
    return get_settings()


@pytest.fixture
def client() -> Iterator[TestClient]:
    with TestClient(fastapi_app) as test_client:
        yield test_client
    fastapi_app.dependency_overrides.clear()


@pytest.fixture
def db_session() -> Iterator[Session]:
    with SessionLocal() as session:
        yield session


@pytest.fixture
def register_user(client: TestClient) -> Callable[..., dict[str, Any]]:
    """Daftarkan user lewat API; kembalikan isi `data` (token + user)."""

    def _register(
        email: str = "alea@skinsight.id", password: str = "skinsight123", name: str = "Alea Kucing"
    ) -> dict[str, Any]:
        response = client.post(f"{API}/auth/register", json={"name": name, "email": email, "password": password})
        assert response.status_code == 201, response.text
        return response.json()["data"]

    return _register


@pytest.fixture
def auth_headers(register_user: Callable[..., dict[str, Any]]) -> dict[str, str]:
    return {"Authorization": f"Bearer {register_user()['access_token']}"}


@pytest.fixture
def upload_scan(client: TestClient) -> Callable[..., Response]:
    """Kirim POST /scans (multipart) dengan gambar JPEG valid sebagai default."""

    def _upload(
        headers: dict[str, str],
        *,
        body_area: str = "wajah",
        data: bytes | None = None,
        filename: str = "scan.jpg",
        content_type: str = "image/jpeg",
    ) -> Response:
        payload = data if data is not None else make_image_bytes()
        return client.post(
            f"{API}/scans",
            headers=headers,
            files={"image": (filename, payload, content_type)},
            data={"body_area": body_area},
        )

    return _upload
