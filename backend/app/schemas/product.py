"""Skema katalog produk skincare."""

from typing import Literal

from pydantic import BaseModel, Field, field_validator, model_validator

from app.schemas.common import ORMModel
from app.schemas.ingredient import IngredientBrief

ProductSort = Literal["price_asc", "price_desc", "name_asc", "newest"]


class ProductQuery(BaseModel):
    """Query parameter GET /products."""

    min_price: int | None = Field(default=None, ge=0, description="Harga minimum (Rupiah)")
    max_price: int | None = Field(default=None, ge=0, description="Harga maksimum (Rupiah)")
    category: str | None = Field(default=None, max_length=100, description="Kategori, mis. 'serum'")
    concern: str | None = Field(default=None, max_length=50, description="Kode kondisi kulit, mis. 'oily'")
    q: str | None = Field(default=None, max_length=100, description="Cari di nama produk / brand")
    sort: ProductSort = "price_asc"
    page: int = Field(default=1, ge=1)
    page_size: int = Field(default=20, ge=1, le=100)

    @field_validator("category", "concern", "q")
    @classmethod
    def _blank_to_none(cls, value: str | None) -> str | None:
        if value is None:
            return None
        value = value.strip()
        return value or None

    @model_validator(mode="after")
    def _check_price_range(self) -> "ProductQuery":
        if self.min_price is not None and self.max_price is not None and self.min_price > self.max_price:
            raise ValueError("min_price tidak boleh lebih besar dari max_price")
        return self


class ProductOut(ORMModel):
    id: int
    name: str
    brand: str
    category: str
    price: int
    description: str | None
    image_url: str | None


class ProductDetailOut(ProductOut):
    ingredients_text: str | None
    ingredients: list[IngredientBrief]
