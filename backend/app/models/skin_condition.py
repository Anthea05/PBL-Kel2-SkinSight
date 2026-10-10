"""Model kondisi kulit (kelas yang bisa diprediksi model ML)."""

from typing import TYPE_CHECKING

from sqlalchemy import String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base

if TYPE_CHECKING:
    from app.models.ingredient import ConditionIngredient


class SkinCondition(Base):
    """`code` harus sama persis dengan label output model ML (mis. "oily")."""

    __tablename__ = "skin_conditions"

    id: Mapped[int] = mapped_column(primary_key=True)
    code: Mapped[str] = mapped_column(String(50), unique=True, index=True)
    name: Mapped[str] = mapped_column(String(100))
    description: Mapped[str] = mapped_column(Text, default="")

    ingredient_links: Mapped[list["ConditionIngredient"]] = relationship(
        back_populates="condition",
        cascade="all, delete-orphan",
        order_by="ConditionIngredient.priority",
    )
