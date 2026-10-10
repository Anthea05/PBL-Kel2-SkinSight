"""Model artikel edukasi: tips harian dan nutrisi, umum atau per kondisi kulit."""

from typing import TYPE_CHECKING

from sqlalchemy import ForeignKey, Index, String, Text, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base
from app.models.mixins import TimestampMixin

if TYPE_CHECKING:
    from app.models.skin_condition import SkinCondition


class EducationArticle(TimestampMixin, Base):
    """`article_type` = "tip" atau "nutrition". `condition_id` kosong = berlaku untuk semua kondisi."""

    __tablename__ = "education_articles"
    __table_args__ = (
        UniqueConstraint("article_type", "title", name="uq_education_articles_type_title"),
        Index("ix_education_articles_type_condition_id", "article_type", "condition_id"),
    )

    id: Mapped[int] = mapped_column(primary_key=True)
    article_type: Mapped[str] = mapped_column(String(20))
    title: Mapped[str] = mapped_column(String(200))
    summary: Mapped[str] = mapped_column(String(300))
    content: Mapped[str] = mapped_column(Text)
    condition_id: Mapped[int | None] = mapped_column(ForeignKey("skin_conditions.id", ondelete="CASCADE"))

    condition: Mapped["SkinCondition | None"] = relationship()
