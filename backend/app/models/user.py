"""Model pengguna aplikasi."""

import uuid
from typing import TYPE_CHECKING

from sqlalchemy import Boolean, String, Uuid, true
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base
from app.models.mixins import TimestampMixin

if TYPE_CHECKING:
    from app.models.quiz import QuizResponse
    from app.models.scan import Scan


class User(TimestampMixin, Base):
    """Akun pengguna. Field mengikuti ProfileData di Flutter (name, email, phone)."""

    __tablename__ = "users"

    id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True, default=uuid.uuid4)
    name: Mapped[str] = mapped_column(String(100))
    email: Mapped[str] = mapped_column(String(255), unique=True, index=True)
    phone: Mapped[str | None] = mapped_column(String(20))
    password_hash: Mapped[str] = mapped_column(String(255))
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, server_default=true())

    quiz_responses: Mapped[list["QuizResponse"]] = relationship(
        back_populates="user", cascade="all, delete-orphan", passive_deletes=True
    )
    scans: Mapped[list["Scan"]] = relationship(
        back_populates="user", cascade="all, delete-orphan", passive_deletes=True
    )
