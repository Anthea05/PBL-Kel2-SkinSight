"""Test register, login, refresh token, dan akses endpoint terproteksi tanpa token."""

import uuid
from datetime import UTC, datetime, timedelta

import jwt
import pytest

from tests.helpers import API


def test_register_returns_tokens_and_user(client):
    response = client.post(
        f"{API}/auth/register",
        json={"name": "Alea Kucing", "email": "Alea@SkinSight.id", "password": "skinsight123", "phone": "+62 812-3456-7890"},
    )

    assert response.status_code == 201
    body = response.json()
    assert body["success"] is True
    assert body["message"] == "Registrasi berhasil."
    data = body["data"]
    assert data["access_token"] and data["refresh_token"]
    assert data["token_type"] == "bearer"
    assert data["expires_in"] > 0
    assert data["user"]["email"] == "alea@skinsight.id"  # disimpan huruf kecil
    assert data["user"]["phone"] == "+62 812-3456-7890"
    assert "password" not in data["user"] and "password_hash" not in data["user"]


def test_register_duplicate_email_returns_409(client, register_user):
    register_user(email="alea@skinsight.id")

    response = client.post(
        f"{API}/auth/register", json={"name": "Lain", "email": "ALEA@skinsight.id", "password": "skinsight123"}
    )

    assert response.status_code == 409
    assert response.json() == {
        "success": False,
        "error": {"code": "EMAIL_ALREADY_REGISTERED", "message": "Email sudah terdaftar."},
    }


def test_register_invalid_data_returns_validation_error(client):
    response = client.post(f"{API}/auth/register", json={"name": "", "email": "bukan-email", "password": "123"})

    assert response.status_code == 422
    error = response.json()["error"]
    assert error["code"] == "VALIDATION_ERROR"
    assert {"name", "email", "password"} <= {detail["field"] for detail in error["details"]}


def test_login_success_and_token_works(client, register_user):
    register_user(email="alea@skinsight.id", password="skinsight123")

    response = client.post(f"{API}/auth/login", json={"email": "alea@skinsight.id", "password": "skinsight123"})

    assert response.status_code == 200
    data = response.json()["data"]
    assert data["user"]["email"] == "alea@skinsight.id"
    me = client.get(f"{API}/users/me", headers={"Authorization": f"Bearer {data['access_token']}"})
    assert me.status_code == 200
    assert me.json()["data"]["name"] == "Alea Kucing"


@pytest.mark.parametrize(
    ("email", "password"),
    [("alea@skinsight.id", "password-salah"), ("tidak-terdaftar@skinsight.id", "skinsight123")],
)
def test_login_wrong_credentials_uses_same_message(client, register_user, email, password):
    register_user(email="alea@skinsight.id", password="skinsight123")

    response = client.post(f"{API}/auth/login", json={"email": email, "password": password})

    assert response.status_code == 401
    assert response.json()["error"] == {"code": "INVALID_CREDENTIALS", "message": "Email atau password salah."}


def test_refresh_returns_new_working_tokens(client, register_user):
    tokens = register_user()

    response = client.post(f"{API}/auth/refresh", json={"refresh_token": tokens["refresh_token"]})

    assert response.status_code == 200
    new_access_token = response.json()["data"]["access_token"]
    me = client.get(f"{API}/users/me", headers={"Authorization": f"Bearer {new_access_token}"})
    assert me.status_code == 200


def test_refresh_rejects_access_token(client, register_user):
    tokens = register_user()

    response = client.post(f"{API}/auth/refresh", json={"refresh_token": tokens["access_token"]})

    assert response.status_code == 401
    assert response.json()["error"]["code"] == "INVALID_TOKEN"


SCAN_ID = uuid.uuid4()
PROTECTED_ENDPOINTS = [
    ("GET", "/users/me"),
    ("PATCH", "/users/me"),
    ("POST", "/quiz"),
    ("GET", "/quiz/latest"),
    ("POST", "/scans"),
    ("GET", "/scans"),
    ("GET", f"/scans/{SCAN_ID}"),
    ("DELETE", f"/scans/{SCAN_ID}"),
    ("GET", f"/scans/{SCAN_ID}/recommendations"),
]


@pytest.mark.parametrize(("method", "path"), PROTECTED_ENDPOINTS)
def test_protected_endpoint_without_token_returns_401(client, method, path):
    response = client.request(method, f"{API}{path}")

    assert response.status_code == 401
    body = response.json()
    assert body["success"] is False
    assert body["error"]["code"] == "UNAUTHORIZED"
    assert response.headers["www-authenticate"] == "Bearer"


def test_protected_endpoint_with_invalid_token_returns_401(client):
    response = client.get(f"{API}/users/me", headers={"Authorization": "Bearer token-asal-asalan"})

    assert response.status_code == 401
    assert response.json()["error"]["code"] == "INVALID_TOKEN"


def test_refresh_token_cannot_access_protected_endpoint(client, register_user):
    tokens = register_user()

    response = client.get(f"{API}/users/me", headers={"Authorization": f"Bearer {tokens['refresh_token']}"})

    assert response.status_code == 401
    assert response.json()["error"]["code"] == "INVALID_TOKEN"


def test_expired_token_returns_token_expired(client, register_user, settings):
    user_id = register_user()["user"]["id"]
    past = datetime.now(UTC) - timedelta(hours=2)
    expired = jwt.encode(
        {"sub": user_id, "type": "access", "iat": past, "exp": past + timedelta(minutes=5)},
        settings.jwt_secret_key,
        algorithm=settings.jwt_algorithm,
    )

    response = client.get(f"{API}/users/me", headers={"Authorization": f"Bearer {expired}"})

    assert response.status_code == 401
    assert response.json()["error"]["code"] == "TOKEN_EXPIRED"
