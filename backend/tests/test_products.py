"""Test katalog produk: filter harga, kategori, kondisi kulit, pencarian, urutan, detail."""

from app.models.product import Product
from tests.helpers import API

OILY_INGREDIENTS = {"niacinamide", "salicylic-acid", "zinc-pca", "hyaluronic-acid", "tea-tree-oil"}


def _list(client, **params):
    response = client.get(f"{API}/products", params=params)
    assert response.status_code == 200, response.text
    return response.json()["data"]


def test_filter_by_price_range_only_returns_products_in_range(client):
    data = _list(client, min_price=50_000, max_price=100_000, page_size=100)

    assert data["total"] > 0
    assert data["total"] == len(data["items"])
    assert all(50_000 <= item["price"] <= 100_000 for item in data["items"])


def test_price_filter_bounds_are_inclusive_and_sortable(client, db_session):
    db_session.add_all(
        [
            Product(name="Produk Murah", brand="Brand Uji", category="uji harga", price=10_000),
            Product(name="Produk Sedang", brand="Brand Uji", category="uji harga", price=60_000),
            Product(name="Produk Mahal", brand="Brand Uji", category="uji harga", price=150_000),
        ]
    )
    db_session.commit()

    def names(**params):
        return [item["name"] for item in _list(client, category="Uji Harga", **params)["items"]]

    assert names(min_price=50_000, max_price=100_000) == ["Produk Sedang"]
    assert names(min_price=60_000) == ["Produk Sedang", "Produk Mahal"]
    assert names(max_price=60_000) == ["Produk Murah", "Produk Sedang"]
    assert names(max_price=60_000, sort="price_desc") == ["Produk Sedang", "Produk Murah"]


def test_min_price_greater_than_max_price_is_rejected(client):
    response = client.get(f"{API}/products", params={"min_price": 200_000, "max_price": 100_000})

    assert response.status_code == 422
    assert response.json()["error"]["code"] == "VALIDATION_ERROR"


def test_negative_price_is_rejected(client):
    response = client.get(f"{API}/products", params={"min_price": -1})

    assert response.status_code == 422


def test_filter_by_concern_and_category(client):
    data = _list(client, concern="oily", category="serum", page_size=100)

    assert data["total"] > 0
    for item in data["items"]:
        assert item["category"] == "serum"
        detail = client.get(f"{API}/products/{item['id']}").json()["data"]
        assert {ingredient["slug"] for ingredient in detail["ingredients"]} & OILY_INGREDIENTS


def test_unknown_concern_returns_404(client):
    response = client.get(f"{API}/products", params={"concern": "tidak-ada"})

    assert response.status_code == 404
    assert response.json()["error"]["code"] == "CONDITION_NOT_FOUND"


def test_search_is_case_insensitive_and_paginated(client):
    data = _list(client, q="VITAMIN C", page_size=1)

    assert data["total"] == 3
    assert len(data["items"]) == 1
    assert data["page"] == 1 and data["page_size"] == 1 and data["total_pages"] == 3


def test_search_treats_wildcards_literally(client):
    # Tanpa escape, '%' akan mencocokkan semua produk.
    data = _list(client, q="%", page_size=100)

    assert data["total"] == 5
    assert all("%" in item["name"] for item in data["items"])


def test_product_detail_includes_linked_ingredients(client):
    product = _list(client, q="Niacinamide 10%")["items"][0]

    response = client.get(f"{API}/products/{product['id']}")

    assert response.status_code == 200
    detail = response.json()["data"]
    assert {"Niacinamide", "Zinc PCA", "Glycerin"} <= {ingredient["name"] for ingredient in detail["ingredients"]}
    assert "Niacinamide" in detail["ingredients_text"]


def test_product_not_found(client):
    response = client.get(f"{API}/products/999999")

    assert response.status_code == 404
    assert response.json()["error"]["code"] == "PRODUCT_NOT_FOUND"
