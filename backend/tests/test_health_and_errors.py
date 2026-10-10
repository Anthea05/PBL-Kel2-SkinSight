"""Test health check, format error global, rate limit, dan importer CSV."""

from pathlib import Path

import pytest

from app.services.product_import_service import ProductImportService, parse_price
from app.services.product_service import ProductService
from tests.helpers import API


def test_health_check(client):
    response = client.get(f"{API}/health")

    assert response.status_code == 200
    data = response.json()["data"]
    assert data["status"] == "ok"
    assert data["database"] == "ok"
    assert data["ml"] == {"mode": "mock", "ready": True, "version": "mock-v1"}
    assert response.headers["x-request-id"]


def test_openapi_schema_is_generated(client):
    response = client.get("/openapi.json")

    assert response.status_code == 200
    paths = response.json()["paths"]
    assert f"{API}/scans/{{scan_id}}/recommendations" in paths
    assert "multipart/form-data" in paths[f"{API}/scans"]["post"]["requestBody"]["content"]


def test_unknown_route_uses_error_format(client):
    response = client.get(f"{API}/tidak-ada")

    assert response.status_code == 404
    assert response.json() == {"success": False, "error": {"code": "NOT_FOUND", "message": "Endpoint tidak ditemukan."}}


def test_unexpected_error_does_not_leak_details(client, monkeypatch):
    def broken(*args, **kwargs):
        raise RuntimeError("detail internal rahasia")

    monkeypatch.setattr(ProductService, "list_products", broken)

    response = client.get(f"{API}/products")

    assert response.status_code == 500
    assert response.json() == {
        "success": False,
        "error": {"code": "INTERNAL_SERVER_ERROR", "message": "Terjadi kesalahan pada server. Silakan coba lagi."},
    }
    assert "rahasia" not in response.text and "Traceback" not in response.text


def test_auth_rate_limit(client, settings, monkeypatch):
    monkeypatch.setattr(settings, "rate_limit_auth_requests", 3)
    payload = {"email": "siapa@skinsight.id", "password": "password-salah"}

    statuses = [client.post(f"{API}/auth/login", json=payload).status_code for _ in range(3)]
    blocked = client.post(f"{API}/auth/login", json=payload)

    assert statuses == [401, 401, 401]
    assert blocked.status_code == 429
    assert blocked.json()["error"]["code"] == "RATE_LIMITED"
    assert int(blocked.headers["retry-after"]) >= 1


def test_scans_rate_limit(client, auth_headers, settings, monkeypatch):
    monkeypatch.setattr(settings, "rate_limit_scans_requests", 2)

    statuses = [client.get(f"{API}/scans", headers=auth_headers).status_code for _ in range(3)]

    assert statuses == [200, 200, 429]


@pytest.mark.parametrize(
    ("raw", "expected"),
    [
        ("Rp 125.000", 125_000),
        ("89,900", 89_900),
        ("125000.00", 125_000),
        ("Rp 125.000,50", 125_000),
        ("1,234.56", 1_234),
        ("Rp 50.000 - Rp 75.000", 50_000),
        ("gratis", None),
    ],
)
def test_parse_price(raw, expected):
    assert parse_price(raw) == expected


def test_import_csv_with_custom_columns_is_idempotent(db_session, tmp_path: Path):
    csv_file = tmp_path / "female_daily.csv"
    csv_file.write_text(
        "Nama Produk;Merek;Kategori;Harga;Komposisi\n"
        "Serum Impor;Brand Impor;Serum;Rp 99.000;Aqua, Niacinamide, Parfum\n"
        "Tanpa Harga;Brand Impor;Toner;-;Aqua\n",
        encoding="utf-8",
    )
    overrides = {"name": "Nama Produk", "brand": "Merek", "category": "Kategori", "price": "Harga", "ingredients": "Komposisi"}
    service = ProductImportService(db_session)

    first = service.import_csv(csv_file, column_overrides=overrides, delimiter=";")
    second = service.import_csv(csv_file, column_overrides=overrides, delimiter=";")

    assert (first.created, first.updated, first.skipped) == (1, 0, 1)
    assert (second.created, second.updated) == (0, 1)
    assert "Baris 3" in first.errors[0]
    product = service.products.get_by_brand_and_name("Brand Impor", "Serum Impor")
    assert product is not None and product.price == 99_000 and product.category == "serum"
    assert {ingredient.name for ingredient in product.ingredients} == {"Niacinamide", "Fragrance"}
