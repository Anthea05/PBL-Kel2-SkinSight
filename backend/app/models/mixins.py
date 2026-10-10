"""Kolom bersama untuk beberapa model."""

from datetime import UTC, datetime

from sqlalchemy import DateTime, func
from sqlalchemy.orm import Mapped, mapped_column


def utcnow() -> datetime:
    """Waktu sekarang dalam UTC (timezone-aware)."""
    return datetime.now(UTC)


class TimestampMixin:
    """Menambahkan created_at dan updated_at."""

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=utcnow, server_default=func.now()
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=utcnow, onupdate=utcnow, server_default=func.now()
    )
