"""Test kuis kondisi kulit & gaya hidup."""

from tests.helpers import API, VALID_QUIZ


def test_submit_quiz_normalizes_allergies(client, auth_headers):
    response = client.post(
        f"{API}/quiz",
        headers=auth_headers,
        json={**VALID_QUIZ, "allergies": ["Fragrance", "fragrance", " Alcohol Denat "], "habits": ["begadang"]},
    )

    assert response.status_code == 201
    data = response.json()["data"]
    assert data["allergies"] == ["fragrance", "alcohol denat"]
    assert data["habits"] == ["begadang"]
    assert data["skin_feel"] == "oily_t_zone"


def test_latest_quiz_returns_newest_submission(client, auth_headers):
    client.post(f"{API}/quiz", headers=auth_headers, json=VALID_QUIZ)
    newest = client.post(f"{API}/quiz", headers=auth_headers, json={**VALID_QUIZ, "main_concern": "fine_lines"})

    response = client.get(f"{API}/quiz/latest", headers=auth_headers)

    assert response.status_code == 200
    assert response.json()["data"]["id"] == newest.json()["data"]["id"]
    assert response.json()["data"]["main_concern"] == "fine_lines"


def test_latest_quiz_not_found_before_submission(client, auth_headers):
    response = client.get(f"{API}/quiz/latest", headers=auth_headers)

    assert response.status_code == 404
    assert response.json()["error"]["code"] == "QUIZ_NOT_FOUND"


def test_quiz_rejects_unknown_answer(client, auth_headers):
    response = client.post(f"{API}/quiz", headers=auth_headers, json={**VALID_QUIZ, "skin_feel": "super_berminyak"})

    assert response.status_code == 422
    assert response.json()["error"]["details"][0]["field"] == "skin_feel"
