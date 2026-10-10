"""Model hasil scan kulit. Foto TIDAK disimpan kecuali SAVE_SCAN_IMAGES=true."""

import uuid
from datetime import datetime
from typing import TYPE_CHECKING, Any

from sqlalchemy import CheckConstraint, DateTime, Double, ForeignKey, Index, String, Uuid, func
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base
from app.models.mixins import utcnow

if TYPE_CHECKING:
    from app.models.skin_condition import SkinCondition
    from app.models.user import User


class Scan(Base):
    """Hasil prediksi + metadata satu kali scan."""

    __tablename__ = "scans"
    __table_args__ = (
        Index("ix_scans_user_id_analyzed_at", "user_id", "analyzed_at"),
        CheckConstraint("confidence >= 0 AND confidence <= 1", name="confidence_range"),
    )

    id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"))
    condition_id: Mapped[int | None] = mapped_column(ForeignKey("skin_conditions.id", ondelete="SET NULL"))

    body_area: Mapped[str] = mapped_column(String(20))
    label: Mapped[str] = mapped_column(String(50))  # label teratas dari model ML
    confidence: Mapped[float] = mapped_column(Double)  # 0..1
    predictions: Mapped[list[dict[str, Any]]] = mapped_column(JSONB, default=list)  # semua kelas, urut tertinggi
    model_version: Mapped[str | None] = mapped_column(String(100))
    image_path: Mapped[str | None] = mapped_column(String(500))  # hanya terisi jika SAVE_SCAN_IMAGES=true

    # Nama mengikuti model Dart SkinAnalysis.analyzedAt
    analyzed_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=utcnow, server_default=func.now()
    )

    user: Mapped["User"] = relationship(back_populates="scans")
    condition: Mapped["SkinCondition | None"] = relationship()
