"""Integrasi Machine Learning SkinSight.

Satu interface untuk semua mode:
    predict(image_bytes, body_area) -> list[Prediction]   (urut confidence tertinggi)

Mode dipilih lewat env ML_MODE:
- mock   : hasil dummy deterministik (DEFAULT) agar backend bisa dites tanpa model.
- local  : memuat file model dari ML_MODEL_PATH, SEKALI saat startup aplikasi.
- remote : memanggil API ML terpisah di ML_API_URL lewat httpx.

Temuan dari branch Rafazl (notebook Tr_Oilness_PBL.ipynb):
- Model : Ultralytics YOLOv8n-cls (klasifikasi gambar, PyTorch); hasil training `best.pt`.
- Input : imgsz=224.
- Kelas : combination, dry, normal, oily (indeks Ultralytics = urutan alfabet nama folder dataset).
- Preprocessing: dikerjakan otomatis oleh Ultralytics saat `model.predict(...)`.
README proyek menyebut TensorFlow/Keras, jadi jalur model .keras/.h5 juga disiapkan (lihat TODO).
"""

import hashlib
import io
import logging
import threading
from abc import ABC, abstractmethod
from collections.abc import Iterable, Sequence
from dataclasses import dataclass
from pathlib import Path
from typing import Any

import httpx
from PIL import Image, ImageOps
from pydantic import BaseModel, Field, ValidationError

from app.core.config import Settings

logger = logging.getLogger(__name__)


class MLServiceError(Exception):
    """Model belum siap atau prediksi gagal."""


@dataclass(frozen=True)
class Prediction:
    label: str
    confidence: float  # 0..1


def _sort_predictions(predictions: Iterable[Prediction]) -> list[Prediction]:
    return sorted(predictions, key=lambda prediction: prediction.confidence, reverse=True)


def _build_predictions(labels: Sequence[str], probabilities: Sequence[float]) -> list[Prediction]:
    """Gabungkan label + probabilitas output model, lalu urutkan dari yang tertinggi."""
    if len(probabilities) != len(labels):
        raise MLServiceError(f"Model mengeluarkan {len(probabilities)} nilai, tetapi ada {len(labels)} label.")
    if any(not 0 <= float(value) <= 1 for value in probabilities):
        raise MLServiceError("Output model bukan probabilitas 0-1 (pastikan layer terakhir softmax).")
    return _sort_predictions(Prediction(label, round(float(value), 4)) for label, value in zip(labels, probabilities))


class MLService(ABC):
    """Interface bersama semua mode ML."""

    mode: str = "base"

    def __init__(self) -> None:
        self.ready = False
        self.version: str = self.mode

    def load(self) -> None:
        """Dipanggil SEKALI saat startup (bukan per request)."""
        self.ready = True

    @abstractmethod
    def predict(self, image_bytes: bytes, body_area: str) -> list[Prediction]:
        """Prediksi kondisi kulit. Return daftar {label, confidence} urut tertinggi."""

    def close(self) -> None:
        """Bersihkan resource saat aplikasi berhenti."""

    def status(self) -> dict[str, Any]:
        return {"mode": self.mode, "ready": self.ready, "version": self.version}


class MockMLService(MLService):
    """Hasil dummy deterministik: gambar + area yang sama selalu menghasilkan prediksi yang sama.

    Bukan hasil model sungguhan; hanya untuk pengembangan dan testing.
    """

    mode = "mock"

    def __init__(self, labels: Sequence[str]) -> None:
        super().__init__()
        self.labels = list(labels)
        self.version = "mock-v1"

    def predict(self, image_bytes: bytes, body_area: str) -> list[Prediction]:
        digest = hashlib.sha256(body_area.encode() + b":" + image_bytes).digest()
        weights = [(digest[index % len(digest)] + 1) ** 2 for index in range(len(self.labels))]
        total = sum(weights)
        return _sort_predictions(
            Prediction(label, round(weight / total, 4)) for label, weight in zip(self.labels, weights)
        )


class LocalMLService(MLService):
    """Model dari file lokal: .pt = Ultralytics (sesuai notebook Rafazl); .keras/.h5 = TensorFlow."""

    mode = "local"

    def __init__(self, model_path: Path, image_size: int, labels: Sequence[str]) -> None:
        super().__init__()
        self.model_path = model_path
        self.image_size = image_size
        self.labels = list(labels)
        self.version = model_path.name
        self._model: Any = None
        self._backend: str | None = None
        self._lock = threading.Lock()  # objek model tidak dijamin thread-safe

    def load(self) -> None:
        # TODO(ML Engineer): salin hasil training (runs/classify/train/weights/best.pt) ke
        #   backend/ml_models/best.pt, atau ubah ML_MODEL_PATH.
        if not self.model_path.is_file():
            raise MLServiceError(f"File model tidak ditemukan: {self.model_path}")
        suffix = self.model_path.suffix.lower()
        if suffix == ".pt":
            self._load_ultralytics()
        elif suffix in {".keras", ".h5"}:
            self._load_keras()
        else:
            raise MLServiceError(f"Format model '{suffix}' belum didukung. Gunakan .pt, .keras, atau .h5.")
        self.ready = True

    def _load_ultralytics(self) -> None:
        try:
            from ultralytics import YOLO  # paket berat, hanya diimpor di mode local
        except ImportError as exc:
            raise MLServiceError("Paket 'ultralytics' belum terpasang (lihat requirements-ml.txt).") from exc
        self._model = YOLO(str(self.model_path), task="classify")
        model_labels = [self._model.names[index] for index in sorted(self._model.names)]
        if model_labels != self.labels:
            logger.warning(
                "ML_LABELS %s berbeda dengan label di file model (%d label, mis. %s); label dari file model dipakai.",
                self.labels,
                len(model_labels),
                model_labels[:5],
            )
        self.labels = model_labels
        self._backend = "ultralytics"

    def _load_keras(self) -> None:
        # TODO(ML Engineer): jalur ini untuk model TensorFlow/Keras sesuai rencana di README proyek.
        #   Branch Rafazl belum berisi model Keras, jadi preprocessing di _predict_keras() masih ASUMSI.
        #   Pastikan ML_IMAGE_SIZE, skala piksel, dan urutan ML_LABELS sama persis dengan saat training.
        try:
            import tensorflow as tf
        except ImportError as exc:
            raise MLServiceError("Paket 'tensorflow' belum terpasang (lihat requirements-ml.txt).") from exc
        self._model = tf.keras.models.load_model(self.model_path)
        self._backend = "keras"

    def predict(self, image_bytes: bytes, body_area: str) -> list[Prediction]:
        # TODO(ML Engineer): di notebook model hanya diuji dengan foto wajah (wajah-test.jpeg). Konfirmasi
        #   apakah model valid untuk tangan/punggung/kaki, atau perlu model/aturan terpisah per body_area.
        if not self.ready or self._model is None:
            raise MLServiceError("Model belum dimuat.")
        # Tegakkan foto kamera sesuai tag orientasi EXIF (gambar dataset training umumnya sudah tegak).
        image = ImageOps.exif_transpose(Image.open(io.BytesIO(image_bytes))).convert("RGB")
        with self._lock:
            if self._backend == "ultralytics":
                probabilities = self._predict_ultralytics(image)
            else:
                probabilities = self._predict_keras(image)
        return _build_predictions(self.labels, probabilities)

    def _predict_ultralytics(self, image: Image.Image) -> list[float]:
        # Resize/crop/normalisasi dilakukan Ultralytics, sama seperti pipeline saat training.
        results = self._model.predict(image, imgsz=self.image_size, verbose=False)
        return results[0].probs.data.tolist()

    def _predict_keras(self, image: Image.Image) -> list[float]:
        import numpy as np

        # ASUMSI (TODO ML Engineer): resize persegi ML_IMAGE_SIZE + skala piksel 0..1.
        resized = image.resize((self.image_size, self.image_size))
        batch = np.expand_dims(np.asarray(resized, dtype="float32") / 255.0, axis=0)
        return self._model.predict(batch, verbose=0)[0].tolist()


class _RemotePredictionItem(BaseModel):
    label: str = Field(min_length=1)
    confidence: float = Field(ge=0, le=1)


class _RemotePredictionResponse(BaseModel):
    predictions: list[_RemotePredictionItem] = Field(min_length=1)


class RemoteMLService(MLService):
    """Memanggil API ML terpisah.

    Kontrak yang diharapkan (TODO ML Engineer: implementasikan di API ML):
        POST {ML_API_URL}   multipart/form-data -> image=<file>, body_area=<teks>
        200 OK              {"predictions": [{"label": "oily", "confidence": 0.87}, ...]}
    """

    mode = "remote"

    def __init__(
        self, api_url: str, timeout_seconds: float, transport: httpx.BaseTransport | None = None
    ) -> None:
        super().__init__()
        self.api_url = api_url
        self.timeout_seconds = timeout_seconds
        self._transport = transport  # bisa diganti transport palsu saat testing
        self._client: httpx.Client | None = None

    def load(self) -> None:
        # Koneksi dibuat sekali. API ML tidak dipanggil saat startup agar backend tetap bisa jalan.
        self._client = httpx.Client(timeout=self.timeout_seconds, transport=self._transport)
        self.ready = True

    def predict(self, image_bytes: bytes, body_area: str) -> list[Prediction]:
        if self._client is None:
            raise MLServiceError("Client API ML belum diinisialisasi.")
        is_png = image_bytes.startswith(b"\x89PNG")
        files = {"image": ("scan.png" if is_png else "scan.jpg", image_bytes, "image/png" if is_png else "image/jpeg")}
        try:
            response = self._client.post(self.api_url, files=files, data={"body_area": body_area})
            response.raise_for_status()
            payload = _RemotePredictionResponse.model_validate(response.json())
        except (httpx.HTTPError, ValueError, ValidationError) as exc:
            raise MLServiceError(f"Gagal memanggil API ML: {exc}") from exc
        return _sort_predictions(Prediction(item.label, round(item.confidence, 4)) for item in payload.predictions)

    def close(self) -> None:
        if self._client is not None:
            self._client.close()


def create_ml_service(settings: Settings) -> MLService:
    """Pilih implementasi sesuai ML_MODE."""
    if settings.ml_mode == "local":
        return LocalMLService(settings.ml_model_file, settings.ml_image_size, settings.ml_label_list)
    if settings.ml_mode == "remote":
        return RemoteMLService(settings.ml_api_url or "", settings.ml_api_timeout_seconds)
    return MockMLService(settings.ml_label_list)


def init_ml_service(settings: Settings) -> MLService:
    """Buat & muat service ML saat startup. Jika gagal, API tetap jalan dan POST /scans membalas 503."""
    service = create_ml_service(settings)
    try:
        service.load()
        logger.info("Service ML siap (mode=%s, versi=%s)", service.mode, service.version)
    except Exception as exc:
        service.ready = False
        logger.error("Gagal memuat service ML (mode=%s): %s", service.mode, exc)
    return service
