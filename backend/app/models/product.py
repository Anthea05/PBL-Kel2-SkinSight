"""Model produk skincare dan relasinya ke ingredients."""

from typing import TYPE_CHECKING

from sqlalchemy import CheckConstraint, Column, ForeignKey, Index, Integer, String, Table, Text, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base
from app.models.mixins import TimestampMixin

if TYPE_CHECKING:
    from app.models.ingredient import Ingredient

# Tabel relasi many-to-many produk <-> ingredient.
product_ingredients = Table(
    "product_ingredients",
    Base.metadata,
    Column("product_id", ForeignKey("products.id", ondelete="CASCADE"), primary_key=True),
    Column("ingredient_id", ForeignKey("ingredients.id", ondelete="CASCADE"), primary_key=True),
    Index("ix_product_ingredients_ingredient_id", "ingredient_id"),
)


class Product(TimestampMixin, Base):
    """Produk skincare. Harga dalam Rupiah (integer)."""

    __tablename__ = "products"
    __table_args__ = (
        UniqueConstraint("brand", "name", name="uq_products_brand_name"),
        CheckConstraint("price >= 0", name="price_non_negative"),
        Index("ix_products_price", "price"),
        Index("ix_products_category_price", "category", "price"),
    )

    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str] = mapped_column(String(255))
    brand: Mapped[str] = mapped_column(String(150))
    category: Mapped[str] = mapped_column(String(100))  # disimpan huruf kecil, mis. "serum"
    price: Mapped[int] = mapped_column(Integer)
    description: Mapped[str | None] = mapped_column(Text)
    image_url: Mapped[str | None] = mapped_column(String(500))
    ingredients_text: Mapped[str | None] = mapped_column(Text)  # komposisi lengkap dari dataset

    ingredients: Mapped[list["Ingredient"]] = relationship(
        secondary=product_ingredients, order_by="Ingredient.name"
    )
