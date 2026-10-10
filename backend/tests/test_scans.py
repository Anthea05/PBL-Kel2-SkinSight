"""Test alur scan dengan ML_MODE=mock: upload, riwayat, detail, hapus, validasi gambar, privasi foto."""

from datetime import datetime
from zoneinfo import ZoneInfo

from app.core.dependencies import get_ml_service
from app.main import app as fastapi_app
from tests.helpers import API, FixedMLService, make_image_bytes


def test_scan_flow_with_mock_ml(client, auth_headers, upload_scan, settings):
    response = upload_scan(auth_headers, body_area="wajah")

    assert response.status_code == 201, response.text
    body = response.json()
    assert body["message"] == "Analisis kulit berhasil."
    scan = body["data"]
    assert scan["body_area"] == "wajah"
    assert scan["label"] in settings.ml_label_list
    assert 0 <= scan["confidence"] <= 1
    assert scan["model_version"] == "mock-v1"
    assert scan["image_stored"] is False
    assert "bukan diagnosis medis" in scan["disclaimer"]
    confidences = [prediction["confidence"] for prediction in scan["predictions"]]
    assert confidences == sorted(confidences, reverse=True)
    assert scan["predictions"][0] == {"label": scan["label"], "confidence": scan["confidence"]}
    assert {prediction["label"] for prediction in scan["predictions"]} == set(settings.ml_label_list)
    assert scan["title"] == scan["skin_type"] and scan["title"].startswith("Kulit ")

    history = client.get(f"{API}/scans", headers=auth_headers).json()["data"]
    assert history["total"] == 1
    assert history["items"][0]["id"] == scan["id"]

    detail = client.get(f"{API}/scans/{scan['id']}", headers=auth_headers)
    assert detail.status_code == 200
    assert detail.json()["data"]["disclaimer"] == scan["disclaimer"]

    deleted = client.delete(f"{API}/scans/{scan['id']}", headers=auth_headers)
    assert deleted.status_code == 200
    assert deleted.json() == {"success": True, "data": None, "message": "Data scan berhasil dihapus."}
    assert client.get(f"{API}/scans/{scan['id']}", headers=auth_headers).status_code == 404
    assert client.get(f"{API}/scans", headers=auth_headers).json()["data"]["total"] == 0


def test_mock_prediction_is_deterministic(auth_headers, upload_scan):
    image = make_image_bytes(color=(120, 80, 60))

    first = upload_scan(auth_headers, data=image).json()["data"]
    second = upload_scan(auth_headers, data=image).json()["data"]

    assert first["predictions"] == second["predictions"]
    assert first["id"] != second["id"]


def test_png_is_accepted(auth_headers, upload_scan):
    response = upload_scan(
        auth_headers, body_area="punggung", data=make_image_bytes("PNG"), filename="scan.png", content_type="image/png"
    )

    assert response.status_code == 201
    assert response.json()["data"]["body_area"] == "punggung"


def test_photo_is_not_saved_by_default(auth_headers, upload_scan, settings, monkeypatch, tmp_path):
    storage = tmp_path / "scans"
    monkeypatch.setattr(settings, "scan_image_dir", str(storage))

    response = upload_scan(auth_headers)

    assert response.status_code == 201
    assert response.json()["data"]["image_stored"] is False
    assert not storage.exists() or not any(storage.rglob("*"))


def test_photo_saved_when_enabled_and_removed_on_delete(client, auth_headers, upload_scan, settings, monkeypatch, tmp_path):
    storage = tmp_path / "scans"
    monkeypatch.setattr(settings, "save_scan_images", True)
    monkeypatch.setattr(settings, "scan_image_dir", str(storage))

    scan = upload_scan(auth_headers).json()["data"]

    assert scan["image_stored"] is True
    saved_files = list(storage.rglob("*.jpg"))
    assert len(saved_files) == 1 and saved_files[0].stem == scan["id"]

    client.delete(f"{API}/scans/{scan['id']}", headers=auth_headers)

    assert not saved_files[0].exists()


def test_rejects_file_that_is_not_an_image(auth_headers, upload_scan):
    response = upload_scan(auth_headers, data=b"ini bukan gambar", filename="palsu.jpg", content_type="image/jpeg")

    assert response.status_code == 415
    assert response.json()["error"]["code"] == "UNSUPPORTED_MEDIA_TYPE"


def test_rejects_disallowed_content_type(auth_headers, upload_scan):
    response = upload_scan(auth_headers, data=make_image_bytes("PNG"), filename="scan.pdf", content_type="application/pdf")

    assert response.status_code == 415


def test_rejects_other_image_formats(auth_headers, upload_scan):
    response = upload_scan(auth_headers, data=make_image_bytes("GIF"), filename="scan.jpg", content_type="image/jpeg")

    assert response.status_code == 415


def test_rejects_file_over_size_limit(auth_headers, upload_scan, settings):
    oversized = make_image_bytes() + b"0" * (settings.max_upload_size_bytes + 1)

    response = upload_scan(auth_headers, data=oversized)

    assert response.status_code == 413
    assert response.json()["error"]["code"] == "FILE_TOO_LARGE"


def test_rejects_huge_request_early(auth_headers, upload_scan, settings):
    response = upload_scan(auth_headers, data=b"0" * (settings.max_upload_size_bytes * 2))

    assert response.status_code == 413
    assert response.json()["error"]["code"] == "FILE_TOO_LARGE"


def test_rejects_unknown_body_area(auth_headers, upload_scan):
    response = upload_scan(auth_headers, body_area="perut")

    assert response.status_code == 422
    assert response.json()["error"]["details"][0]["field"] == "body_area"


def test_returns_503_when_ml_not_ready(client, auth_headers, upload_scan):
    fastapi_app.dependency_overrides[get_ml_service] = lambda: FixedMLService(ready=False)

    response = upload_scan(auth_headers)

    assert response.status_code == 503
    assert response.json()["error"]["code"] == "ML_UNAVAILABLE"
    assert client.get(f"{API}/scans", headers=auth_headers).json()["data"]["total"] == 0


def test_returns_503_without_leaking_ml_error(auth_headers, upload_scan):
    fastapi_app.dependency_overrides[get_ml_service] = lambda: FixedMLService(error=RuntimeError("detail rahasia"))

    response = upload_scan(auth_headers)

    assert response.status_code == 503
    assert "detail rahasia" not in response.text


def test_history_pagination_and_order(client, auth_headers, upload_scan):
    ids = [upload_scan(auth_headers, data=make_image_bytes(color=(index * 40, 90, 90))).json()["data"]["id"] for index in range(3)]

    page_one = client.get(f"{API}/scans", headers=auth_headers, params={"page": 1, "page_size": 2}).json()["data"]
    oldest_first = client.get(f"{API}/scans", headers=auth_headers, params={"newest_first": "false"}).json()["data"]

    assert page_one["total"] == 3 and page_one["total_pages"] == 2
    assert [item["id"] for item in page_one["items"]] == [ids[2], ids[1]]
    assert [item["id"] for item in oldest_first["items"]] == ids


def test_history_date_filter(client, auth_headers, upload_scan):
    upload_scan(auth_headers)
    today = datetime.now(ZoneInfo("Asia/Jakarta")).date().isoformat()

    on_today = client.get(f"{API}/scans", headers=auth_headers, params={"date": today}).json()["data"]
    on_other_day = client.get(f"{API}/scans", headers=auth_headers, params={"date": "2020-01-01"}).json()["data"]

    assert on_today["total"] == 1
    assert on_other_day["total"] == 0


def test_cannot_access_other_users_scan(client, register_user, upload_scan):
    owner = register_user(email="pemilik@skinsight.id")
    other = register_user(email="lain@skinsight.id")
    owner_headers = {"Authorization": f"Bearer {owner['access_token']}"}
    other_headers = {"Authorization": f"Bearer {other['access_token']}"}
    scan_id = upload_scan(owner_headers).json()["data"]["id"]

    assert client.get(f"{API}/scans/{scan_id}", headers=other_headers).status_code == 404
    assert client.delete(f"{API}/scans/{scan_id}", headers=other_headers).status_code == 404
    assert client.get(f"{API}/scans/{scan_id}/recommendations", headers=other_headers).status_code == 404
    assert client.get(f"{API}/scans", headers=other_headers).json()["data"]["total"] == 0
    assert client.get(f"{API}/scans/{scan_id}", headers=owner_headers).status_code == 200
