"""Konstanta & helper bersama untuk test."""

import io

from PIL import Image

from app.services.ml_service import MLService, Prediction

API = "/api/v1"

VALID_QUIZ = {
    "skin_feel": "oily_t_zone",
    "sensitivity": "sometimes",
    "pore_visibility": "visible_t_zone",
    "main_concern": "acne_blackheads",
    "outdoor_exposure": "1_to_3_hours",
}


def make_image_bytes(
    image_format: str = "JPEG", size: tuple[int, int] = (64, 64), color: tuple[int, int, int] = (210, 160, 140)
) -> bytes:
    """Gambar kecil yang valid untuk upload."""
    buffer = io.BytesIO()
    Image.new("RGB", size, color).save(buffer, format=image_format)
    return buffer.getvalue()


class FixedMLService(MLService):
    """Service ML palsu dengan hasil tetap, untuk test yang butuh label tertentu atau kondisi error."""

    mode = "mock"

    def __init__(self, label: str = "oily", *, ready: bool = True, error: Exception | None = None) -> None:
        super().__init__()
        self.version = "fixed-test"
        self.ready = ready
        self._label = label
        self._error = error

    def predict(self, image_bytes: bytes, body_area: str) -> list[Prediction]:
        if self._error is not None:
            raise self._error
        others = [label for label in ("combination", "dry", "normal", "oily") if label != self._label]
        return [Prediction(self._label, 0.91), *(Prediction(label, 0.03) for label in others)]
