"""Test profil pengguna (GET/PATCH /users/me)."""

from tests.helpers import API


def test_get_my_profile(client, auth_headers):
    response = client.get(f"{API}/users/me", headers=auth_headers)

    assert response.status_code == 200
    data = response.json()["data"]
    assert data["email"] == "alea@skinsight.id"
    assert set(data) == {"id", "name", "email", "phone", "created_at"}


def test_update_profile_partially(client, auth_headers):
    response = client.patch(
        f"{API}/users/me", headers=auth_headers, json={"name": "  Alea Baru  ", "phone": "+62 811-1111-2222"}
    )

    assert response.status_code == 200
    assert response.json()["message"] == "Profil berhasil diperbarui."
    profile = client.get(f"{API}/users/me", headers=auth_headers).json()["data"]
    assert profile["name"] == "Alea Baru"
    assert profile["phone"] == "+62 811-1111-2222"
    assert profile["email"] == "alea@skinsight.id"  # tidak dikirim -> tidak berubah


def test_update_email_already_used_returns_409(client, register_user):
    register_user(email="pertama@skinsight.id")
    second = register_user(email="kedua@skinsight.id")
    headers = {"Authorization": f"Bearer {second['access_token']}"}

    response = client.patch(f"{API}/users/me", headers=headers, json={"email": "PERTAMA@skinsight.id"})

    assert response.status_code == 409
    assert response.json()["error"]["code"] == "EMAIL_ALREADY_REGISTERED"


def test_update_rejects_unknown_or_null_fields(client, auth_headers):
    unknown = client.patch(f"{API}/users/me", headers=auth_headers, json={"password": "rahasia-baru"})
    null_name = client.patch(f"{API}/users/me", headers=auth_headers, json={"name": None})

    assert unknown.status_code == 422
    assert null_name.status_code == 422
