"""Model bahan aktif (ingredient) dan mapping kondisi kulit -> bahan aktif."""

from typing import TYPE_CHECKING

from sqlalchemy import ForeignKey, Integer, String, Text
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base

if TYPE_CHECKING:
    from app.models.skin_condition import SkinCondition


class Ingredient(Base):
    """Bahan skincare. `aliases` = nama lain (INCI/bahasa Indonesia) untuk pencocokan alergi & komposisi."""

    __tablename__ = "ingredients"

    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str] = mapped_column(String(150), unique=True)
    slug: Mapped[str] = mapped_column(String(150), unique=True, index=True)
    aliases: Mapped[list[str]] = mapped_column(JSONB, default=list)
    description: Mapped[str] = mapped_column(Text, default="")
    caution: Mapped[str | None] = mapped_column(Text)

    condition_links: Mapped[list["ConditionIngredient"]] = relationship(
        back_populates="ingredient", cascade="all, delete-orphan"
    )


class ConditionIngredient(Base):
    """Bahan aktif yang direkomendasikan untuk satu kondisi kulit (priority kecil = lebih utama)."""

    __tablename__ = "condition_ingredients"

    condition_id: Mapped[int] = mapped_column(
        ForeignKey("skin_conditions.id", ondelete="CASCADE"), primary_key=True
    )
    ingredient_id: Mapped[int] = mapped_column(
        ForeignKey("ingredients.id", ondelete="CASCADE"), primary_key=True, index=True
    )
    priority: Mapped[int] = mapped_column(Integer, default=0)
    note: Mapped[str | None] = mapped_column(Text)

    condition: Mapped["SkinCondition"] = relationship(back_populates="ingredient_links")
    ingredient: Mapped["Ingredient"] = relationship(back_populates="condition_links")
