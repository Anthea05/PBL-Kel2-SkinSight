"""Konfigurasi aplikasi yang dibaca dari environment variable / file .env.

Semua nilai sensitif (secret JWT, password database) WAJIB datang dari environment.
Tidak ada secret yang di-hardcode di kode.
"""

from functools import lru_cache
from pathlib import Path
from typing import Literal
from zoneinfo import ZoneInfo, ZoneInfoNotFoundError

from pydantic import Field, field_validator, model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict

# Folder root backend/ (acuan untuk path relatif: data/, storage/, ml_models/).
BASE_DIR = Path(__file__).resolve().parents[2]

# Nilai contoh di .env.example. Ditolak jika APP_ENV=production.
PLACEHOLDER_JWT_SECRET = "ganti-dengan-string-acak-minimal-32-karakter"


class Settings(BaseSettings):
    """Konfigurasi SkinSight. Nama env = nama field huruf besar (mis. DATABASE_URL)."""

    model_config = SettingsConfigDict(
        env_file=BASE_DIR / ".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    # --- Aplikasi ---
    app_name: str = "SkinSight API"
    app_version: str = "1.0.0"
    app_env: Literal["development", "test", "production"] = "development"
    api_v1_prefix: str = "/api/v1"
    log_level: str = "INFO"
    app_timezone: str = "Asia/Jakarta"

    # --- Database ---
    database_url: str = "postgresql+psycopg://skinsight:skinsight@localhost:5433/skinsight"

    # --- JWT ---
    jwt_secret_key: str = Field(min_length=32)
    jwt_algorithm: Literal["HS256", "HS384", "HS512"] = "HS256"
    access_token_expire_minutes: int = Field(default=30, ge=1)
    refresh_token_expire_days: int = Field(default=7, ge=1)

    # --- CORS (pisahkan dengan koma; "*" = semua origin) ---
    cors_origins: str = "*"

    # --- Upload & privasi foto ---
    max_upload_size_mb: float = Field(default=5, gt=0, le=20)
    save_scan_images: bool = False
    scan_image_dir: str = "storage/scans"

    # --- Machine Learning ---
    ml_mode: Literal["mock", "local", "remote"] = "mock"
    ml_model_path: str = "ml_models/best.pt"
    ml_image_size: int = Field(default=224, ge=32, le=1024)
    ml_labels: str = "combination,dry,normal,oily"
    ml_api_url: str | None = None
    ml_api_timeout_seconds: float = Field(default=15, gt=0)

    # --- Rate limiting (per IP, fixed window) ---
    rate_limit_enabled: bool = True
    rate_limit_auth_requests: int = Field(default=10, ge=1)
    rate_limit_auth_window_seconds: int = Field(default=60, ge=1)
    rate_limit_scans_requests: int = Field(default=30, ge=1)
    rate_limit_scans_window_seconds: int = Field(default=60, ge=1)

    @field_validator("app_timezone")
    @classmethod
    def _validate_timezone(cls, value: str) -> str:
        try:
            ZoneInfo(value)
        except (ZoneInfoNotFoundError, ValueError) as exc:
            raise ValueError(f"APP_TIMEZONE tidak dikenal: {value}") from exc
        return value

    @model_validator(mode="after")
    def _validate_combination(self) -> "Settings":
        if self.app_env == "production" and self.jwt_secret_key == PLACEHOLDER_JWT_SECRET:
            raise ValueError("JWT_SECRET_KEY masih nilai contoh. Ganti dengan string acak sebelum production.")
        if self.ml_mode == "remote" and not self.ml_api_url:
            raise ValueError("ML_API_URL wajib diisi jika ML_MODE=remote.")
        if not self.ml_label_list:
            raise ValueError("ML_LABELS tidak boleh kosong.")
        return self

    @property
    def cors_origin_list(self) -> list[str]:
        """CORS_ORIGINS dalam bentuk list."""
        return [origin.strip() for origin in self.cors_origins.split(",") if origin.strip()]

    @property
    def ml_label_list(self) -> list[str]:
        """ML_LABELS dalam bentuk list; urutannya = urutan indeks output model."""
        return [label.strip() for label in self.ml_labels.split(",") if label.strip()]

    @property
    def max_upload_size_bytes(self) -> int:
        return int(self.max_upload_size_mb * 1024 * 1024)

    @property
    def scan_image_path(self) -> Path:
        return _resolve_path(self.scan_image_dir)

    @property
    def ml_model_file(self) -> Path:
        return _resolve_path(self.ml_model_path)


def _resolve_path(value: str) -> Path:
    """Path relatif dianggap relatif terhadap folder backend/."""
    path = Path(value)
    return path if path.is_absolute() else BASE_DIR / path


@lru_cache
def get_settings() -> Settings:
    """Membuat Settings sekali lalu menyimpannya di cache."""
    return Settings()
