"""Test unit service ML untuk ketiga mode (tanpa file model sungguhan)."""

import sys
import types

import httpx
import pytest

from app.services.ml_service import LocalMLService, MLServiceError, MockMLService, RemoteMLService, init_ml_service
from tests.helpers import make_image_bytes

LABELS = ["combination", "dry", "normal", "oily"]


def test_mock_is_deterministic_sorted_and_normalized():
    service = MockMLService(LABELS)
    image = make_image_bytes()

    predictions = service.predict(image, "wajah")

    assert predictions == service.predict(image, "wajah")
    assert sorted(prediction.label for prediction in predictions) == sorted(LABELS)
    confidences = [prediction.confidence for prediction in predictions]
    assert confidences == sorted(confidences, reverse=True)
    assert sum(confidences) == pytest.approx(1, abs=1e-3)


def test_local_mode_with_missing_model_starts_degraded(settings, monkeypatch, tmp_path):
    monkeypatch.setattr(settings, "ml_mode", "local")
    monkeypatch.setattr(settings, "ml_model_path", str(tmp_path / "tidak-ada.pt"))

    service = init_ml_service(settings)

    assert service.mode == "local"
    assert service.ready is False
    with pytest.raises(MLServiceError):
        service.predict(make_image_bytes(), "wajah")


class _FakeTensor:
    def __init__(self, values: list[float]) -> None:
        self._values = values

    def tolist(self) -> list[float]:
        return list(self._values)


class _FakeResult:
    def __init__(self, values: list[float]) -> None:
        self.probs = types.SimpleNamespace(data=_FakeTensor(values))


class _FakeYOLO:
    """Tiruan minimal API Ultralytics: YOLO(path, task) -> .names dan .predict(...)[0].probs.data."""

    names = {0: "combination", 1: "dry", 2: "normal", 3: "oily"}
    output = [0.1, 0.2, 0.05, 0.65]
    calls: list[dict] = []

    def __init__(self, path: str, task: str | None = None) -> None:
        self.task = task

    def predict(self, image, imgsz: int, verbose: bool) -> list[_FakeResult]:
        _FakeYOLO.calls.append({"mode": image.mode, "imgsz": imgsz, "verbose": verbose, "task": self.task})
        return [_FakeResult(self.output)]


@pytest.fixture
def fake_ultralytics(monkeypatch):
    module = types.ModuleType("ultralytics")
    module.YOLO = _FakeYOLO
    monkeypatch.setitem(sys.modules, "ultralytics", module)
    return _FakeYOLO


def test_local_ultralytics_uses_labels_from_model(fake_ultralytics, tmp_path):
    model_file = tmp_path / "best.pt"
    model_file.write_bytes(b"dummy")
    service = LocalMLService(model_file, 224, ["urutan", "salah"])

    service.load()
    predictions = service.predict(make_image_bytes("PNG"), "wajah")

    assert service.ready is True
    assert service.labels == LABELS
    assert [(p.label, p.confidence) for p in predictions] == [
        ("oily", 0.65),
        ("dry", 0.2),
        ("combination", 0.1),
        ("normal", 0.05),
    ]
    assert fake_ultralytics.calls[-1] == {"mode": "RGB", "imgsz": 224, "verbose": False, "task": "classify"}


def test_local_rejects_output_that_is_not_probability(fake_ultralytics, monkeypatch, tmp_path):
    model_file = tmp_path / "best.pt"
    model_file.write_bytes(b"dummy")
    monkeypatch.setattr(fake_ultralytics, "output", [2.5, -1.0, 0.3, 4.0])  # logits, bukan softmax
    service = LocalMLService(model_file, 224, LABELS)
    service.load()

    with pytest.raises(MLServiceError):
        service.predict(make_image_bytes(), "wajah")


def test_remote_sends_multipart_and_sorts_predictions():
    captured: dict[str, bytes | str] = {}

    def handler(request: httpx.Request) -> httpx.Response:
        captured["content_type"] = request.headers["content-type"]
        captured["body"] = request.content
        return httpx.Response(
            200, json={"predictions": [{"label": "dry", "confidence": 0.2}, {"label": "oily", "confidence": 0.8}]}
        )

    service = RemoteMLService("http://ml.test/predict", 5, transport=httpx.MockTransport(handler))
    service.load()

    predictions = service.predict(make_image_bytes(), "tangan")
    service.close()

    assert [prediction.label for prediction in predictions] == ["oily", "dry"]
    assert str(captured["content_type"]).startswith("multipart/form-data")
    body = bytes(captured["body"])
    assert b'name="image"' in body and b'name="body_area"' in body and b"tangan" in body


@pytest.mark.parametrize(
    "response",
    [
        httpx.Response(500),
        httpx.Response(200, text="bukan json"),
        httpx.Response(200, json={"hasil": []}),
        httpx.Response(200, json={"predictions": [{"label": "oily", "confidence": 1.7}]}),
    ],
    ids=["server-error", "bukan-json", "format-salah", "confidence-di-luar-0-1"],
)
def test_remote_invalid_response_raises_ml_error(response):
    service = RemoteMLService("http://ml.test/predict", 5, transport=httpx.MockTransport(lambda request: response))
    service.load()

    with pytest.raises(MLServiceError):
        service.predict(make_image_bytes(), "wajah")
