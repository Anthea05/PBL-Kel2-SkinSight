"""Test endpoint edukasi dan ingredients."""

from tests.helpers import API


def test_tips_without_condition_returns_all_tips(client):
    response = client.get(f"{API}/education/tips")

    assert response.status_code == 200
    tips = response.json()["data"]
    assert len(tips) >= 5
    assert {tip["type"] for tip in tips} == {"tip"}


def test_tips_for_condition_include_specific_then_general(client):
    tips = client.get(f"{API}/education/tips", params={"condition": "oily"}).json()["data"]

    conditions = [tip["condition"] for tip in tips]
    assert set(conditions) == {"oily", None}
    assert conditions == sorted(conditions, key=lambda code: code is None)  # spesifik dulu, lalu umum


def test_nutrition_for_condition(client):
    items = client.get(f"{API}/education/nutrition", params={"condition": "dry"}).json()["data"]

    assert {item["type"] for item in items} == {"nutrition"}
    assert "dry" in {item["condition"] for item in items}
    assert {item["condition"] for item in items} <= {"dry", None}


def test_education_unknown_condition_returns_404(client):
    response = client.get(f"{API}/education/nutrition", params={"condition": "tidak-ada"})

    assert response.status_code == 404
    assert response.json()["error"]["code"] == "CONDITION_NOT_FOUND"


def test_list_ingredients_paginated(client):
    data = client.get(f"{API}/ingredients", params={"page_size": 5}).json()["data"]

    assert len(data["items"]) == 5
    assert data["total"] == 17
    assert data["total_pages"] == 4


def test_search_ingredient_by_alias(client):
    data = client.get(f"{API}/ingredients", params={"q": "parfum"}).json()["data"]

    assert [item["name"] for item in data["items"]] == ["Fragrance"]


def test_ingredient_detail_lists_conditions(client):
    niacinamide = client.get(f"{API}/ingredients", params={"q": "niacinamide"}).json()["data"]["items"][0]

    response = client.get(f"{API}/ingredients/{niacinamide['id']}")

    assert response.status_code == 200
    detail = response.json()["data"]
    assert [condition["code"] for condition in detail["conditions"]] == ["combination", "normal", "oily"]


def test_ingredient_not_found(client):
    response = client.get(f"{API}/ingredients/999999")

    assert response.status_code == 404
    assert response.json()["error"]["code"] == "INGREDIENT_NOT_FOUND"
