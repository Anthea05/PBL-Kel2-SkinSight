"""Model jawaban kuis kondisi kulit & gaya hidup."""

import uuid
from datetime import datetime
from typing import TYPE_CHECKING

from sqlalchemy import DateTime, ForeignKey, Index, String, Uuid, func
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base
from app.models.mixins import utcnow

if TYPE_CHECKING:
    from app.models.user import User


class QuizResponse(Base):
    """Satu kali pengisian kuis. Pengguna boleh mengisi berkali-kali; yang dipakai adalah yang terbaru.

    Lima field pertama = 5 pertanyaan di skin_quiz_page.dart.
    allergies/diet_pattern/habits = data gaya hidup dari rancangan proyek
    (allergies dipakai untuk mengecualikan bahan/produk di rekomendasi).
    """

    __tablename__ = "quiz_responses"
    __table_args__ = (Index("ix_quiz_responses_user_id_created_at", "user_id", "created_at"),)

    id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"))

    skin_feel: Mapped[str] = mapped_column(String(30))
    sensitivity: Mapped[str] = mapped_column(String(30))
    pore_visibility: Mapped[str] = mapped_column(String(30))
    main_concern: Mapped[str] = mapped_column(String(30))
    outdoor_exposure: Mapped[str] = mapped_column(String(30))

    allergies: Mapped[list[str]] = mapped_column(JSONB, default=list)
    diet_pattern: Mapped[str | None] = mapped_column(String(500))
    habits: Mapped[list[str]] = mapped_column(JSONB, default=list)

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=utcnow, server_default=func.now()
    )

    user: Mapped["User"] = relationship(back_populates="quiz_responses")
