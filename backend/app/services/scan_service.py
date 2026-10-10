"""Logika bisnis scan kulit: validasi foto, prediksi ML, simpan hasil, riwayat, dan hapus."""

import logging
import uuid
from dataclasses import asdict
from datetime import UTC, date, datetime, time, timedelta
from zoneinfo import ZoneInfo

from fastapi import UploadFile
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.core.constants import MEDICAL_DISCLAIMER
from app.core.exceptions import NotFoundError, ServiceUnavailableError
from app.models.scan import Scan
from app.models.user import User
from app.repositories.scan_repository import ScanRepository
from app.repositories.skin_condition_repository import SkinConditionRepository
from app.schemas.common import Page
from app.schemas.scan import ScanOut
from app.services.image_service import delete_scan_image, read_upload, save_scan_image, validate_image
from app.services.ml_service import MLService, Prediction

logger = logging.getLogger(__name__)


def to_scan_out(scan: Scan) -> ScanOut:
    """Ubah model Scan menjadi respons API (selalu menyertakan disclaimer medis)."""
    display_name = scan.condition.name if scan.condition else scan.label
    return ScanOut(
        id=scan.id,
        body_area=scan.body_area,
        label=scan.label,
        confidence=scan.confidence,
        title=display_name,
        skin_type=display_name,
        predictions=scan.predictions,
        model_version=scan.model_version,
        image_stored=scan.image_path is not None,
        analyzed_at=scan.analyzed_at,
        disclaimer=MEDICAL_DISCLAIMER,
    )


class ScanService:
    def __init__(self, db: Session, ml_service: MLService) -> None:
        self.db = db
        self.ml = ml_service
        self.settings = get_settings()
        self.scans = ScanRepository(db)
        self.conditions = SkinConditionRepository(db)

    def create_scan(self, user: User, upload: UploadFile, body_area: str) -> ScanOut:
        """Validasi foto -> prediksi ML -> simpan HASIL saja (foto dibuang kecuali SAVE_SCAN_IMAGES=true)."""
        data = read_upload(upload, self.settings.max_upload_size_bytes)
        image = validate_image(data, upload.content_type)
        predictions = self._predict(image.data, body_area)

        top = predictions[0]
        scan = Scan(
            id=uuid.uuid4(),
            user_id=user.id,
            condition=self.conditions.get_by_code(top.label),
            body_area=body_area,
            label=top.label,
            confidence=top.confidence,
            predictions=[asdict(prediction) for prediction in predictions],
            model_version=self.ml.version,
        )
        saved_path: str | None = None
        try:
            if self.settings.save_scan_images:
                saved_path = save_scan_image(image, user.id, scan.id)
                scan.image_path = saved_path
            self.scans.add(scan)
            self.db.commit()
        except Exception:
            self.db.rollback()
            if saved_path:
                delete_scan_image(saved_path)
            raise
        return to_scan_out(scan)

    def list_scans(
        self, user: User, *, page: int, page_size: int, on_date: date | None, newest_first: bool
    ) -> Page[ScanOut]:
        """Riwayat scan milik user (filter tanggal & urutan mengikuti SkinHistoryRepository di Flutter)."""
        start = end = None
        if on_date is not None:
            start, end = _day_range_utc(on_date, self.settings.app_timezone)
        scans, total = self.scans.list_for_user(
            user.id,
            offset=(page - 1) * page_size,
            limit=page_size,
            start=start,
            end=end,
            newest_first=newest_first,
        )
        return Page.create([to_scan_out(scan) for scan in scans], page=page, page_size=page_size, total=total)

    def get_scan(self, user: User, scan_id: uuid.UUID) -> ScanOut:
        return to_scan_out(self._get_owned_scan(user, scan_id))

    def delete_scan(self, user: User, scan_id: uuid.UUID) -> None:
        """Hapus data scan milik user beserta fotonya (jika pernah disimpan)."""
        scan = self._get_owned_scan(user, scan_id)
        image_path = scan.image_path
        self.scans.delete(scan)
        self.db.commit()
        if image_path:
            delete_scan_image(image_path)

    def _get_owned_scan(self, user: User, scan_id: uuid.UUID) -> Scan:
        # Scan milik user lain juga dibalas 404 agar keberadaannya tidak bocor.
        scan = self.scans.get_for_user(scan_id, user.id)
        if scan is None:
            raise NotFoundError("Data scan tidak ditemukan.", code="SCAN_NOT_FOUND")
        return scan

    def _predict(self, image_bytes: bytes, body_area: str) -> list[Prediction]:
        if not self.ml.ready:
            raise ServiceUnavailableError("Layanan analisis kulit belum siap. Coba lagi nanti.", code="ML_UNAVAILABLE")
        try:
            predictions = self.ml.predict(image_bytes, body_area)
        except Exception as exc:
            logger.exception("Prediksi ML gagal (mode=%s)", self.ml.mode)
            raise ServiceUnavailableError(
                "Layanan analisis kulit sedang bermasalah. Coba lagi nanti.", code="ML_UNAVAILABLE"
            ) from exc
        if not predictions:
            raise ServiceUnavailableError("Model tidak mengembalikan hasil.", code="ML_UNAVAILABLE")
        return predictions


def _day_range_utc(day: date, timezone_name: str) -> tuple[datetime, datetime]:
    """Rentang [00:00, 24:00) pada zona waktu aplikasi (default WIB), dikonversi ke UTC."""
    start = datetime.combine(day, time.min, tzinfo=ZoneInfo(timezone_name))
    return start.astimezone(UTC), (start + timedelta(days=1)).astimezone(UTC)
