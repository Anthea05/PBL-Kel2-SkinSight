"""Test rekomendasi: bahan aktif + produk harus MENGECUALIKAN alergi dari kuis terbaru."""

from sqlalchemy import select

from app.core.dependencies import get_ml_service
from app.main import app as fastapi_app
from app.models.ingredient import Ingredient
from app.models.product import Product
from tests.helpers import API, VALID_QUIZ, FixedMLService


def _recommendations(client, headers, scan_id, **params):
    response = client.get(f"{API}/scans/{scan_id}/recommendations", headers=headers, params=params)
    assert response.status_code == 200, response.text
    return response.json()["data"]


def _submit_allergies(client, headers, allergies):
    response = client.post(f"{API}/quiz", headers=headers, json={**VALID_QUIZ, "allergies": allergies})
    assert response.status_code == 201, response.text


def test_recommendations_exclude_allergic_ingredient_and_products(client, auth_headers, upload_scan):
    scan_id = upload_scan(auth_headers).json()["data"]["id"]  # ML_MODE=mock
    before = _recommendations(client, auth_headers, scan_id)
    assert before["ingredients"] and before["products"]
    assert before["excluded_ingredients"] == [] and before["allergies"] == []
    allergen = before["products"][0]["matched_ingredients"][0]

    _submit_allergies(client, auth_headers, [allergen.lower()])
    after = _recommendations(client, auth_headers, scan_id)

    assert after["allergies"] == [allergen.lower()]
    assert allergen not in [ingredient["name"] for ingredient in after["ingredients"]]
    assert {"name": allergen, "matched_allergy": allergen.lower()} in [
        {"name": item["name"], "matched_allergy": item["matched_allergy"]} for item in after["excluded_ingredients"]
    ]
    assert after["excluded_products_count"] >= 1
    for product in after["products"]:
        assert allergen not in product["matched_ingredients"]
        detail = client.get(f"{API}/products/{product['id']}").json()["data"]
        assert allergen not in [ingredient["name"] for ingredient in detail["ingredients"]]
    assert "bukan diagnosis medis" in after["disclaimer"]


def test_alias_in_composition_text_is_also_excluded(client, auth_headers, upload_scan, db_session):
    """Alergi 'fragrance' harus mengecualikan produk yang komposisinya hanya menulis 'Parfum'."""
    fastapi_app.dependency_overrides[get_ml_service] = lambda: FixedMLService("oily")
    niacinamide = db_session.scalar(select(Ingredient).where(Ingredient.slug == "niacinamide"))
    db_session.add(
        Product(
            name="Serum Uji Parfum",
            brand="Brand Uji",
            category="serum",
            price=1_000,
            ingredients_text="Aqua, Niacinamide, Parfum",
            ingredients=[niacinamide],  # sengaja hanya ditautkan ke Niacinamide
        )
    )
    db_session.commit()
    scan_id = upload_scan(auth_headers).json()["data"]["id"]
    # max_price=1000 -> hanya produk uji yang masuk rentang harga.
    before = _recommendations(client, auth_headers, scan_id, max_price=1_000)
    assert [product["name"] for product in before["products"]] == ["Serum Uji Parfum"]

    _submit_allergies(client, auth_headers, ["fragrance"])
    after = _recommendations(client, auth_headers, scan_id, max_price=1_000)
    after_all = _recommendations(client, auth_headers, scan_id, limit=50)

    assert after["products"] == []
    assert after["excluded_products_count"] == 1
    assert "Niacinamide" in [ingredient["name"] for ingredient in after["ingredients"]]
    fragrance_products = {
        product.id
        for product in db_session.scalars(select(Product)).all()
        if product.ingredients_text and "parfum" in product.ingredients_text.lower()
    }
    assert fragrance_products
    assert not fragrance_products & {product["id"] for product in after_all["products"]}


def test_recommendations_for_known_condition(client, auth_headers, upload_scan):
    fastapi_app.dependency_overrides[get_ml_service] = lambda: FixedMLService("oily")
    scan_id = upload_scan(auth_headers).json()["data"]["id"]

    data = _recommendations(client, auth_headers, scan_id)

    assert data["condition"]["code"] == "oily"
    assert [ingredient["name"] for ingredient in data["ingredients"]][:2] == ["Niacinamide", "Salicylic Acid"]
    priorities = [ingredient["priority"] for ingredient in data["ingredients"]]
    assert priorities == sorted(priorities)
    match_counts = [len(product["matched_ingredients"]) for product in data["products"]]
    assert match_counts == sorted(match_counts, reverse=True)


def test_recommendations_respect_price_range_and_limit(client, auth_headers, upload_scan):
    scan_id = upload_scan(auth_headers).json()["data"]["id"]

    data = _recommendations(client, auth_headers, scan_id, min_price=50_000, max_price=100_000, limit=3)

    assert 0 < len(data["products"]) <= 3
    assert all(50_000 <= product["price"] <= 100_000 for product in data["products"])


def test_allergy_that_matches_nothing_changes_nothing(client, auth_headers, upload_scan):
    scan_id = upload_scan(auth_headers).json()["data"]["id"]
    before = _recommendations(client, auth_headers, scan_id)

    _submit_allergies(client, auth_headers, ["kacang tanah"])
    after = _recommendations(client, auth_headers, scan_id)

    assert after["ingredients"] == before["ingredients"]
    assert after["products"] == before["products"]
    assert after["excluded_ingredients"] == [] and after["excluded_products_count"] == 0


def test_unknown_label_returns_empty_recommendations(client, auth_headers, upload_scan):
    fastapi_app.dependency_overrides[get_ml_service] = lambda: FixedMLService("label_baru")
    scan = upload_scan(auth_headers).json()["data"]

    data = _recommendations(client, auth_headers, scan["id"])

    assert scan["title"] == "label_baru"
    assert data["condition"] is None
    assert data["ingredients"] == [] and data["products"] == []
