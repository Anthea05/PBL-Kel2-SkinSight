"""Skema rekomendasi bahan aktif + produk untuk satu hasil scan."""

import uuid

from pydantic import BaseModel


class ConditionOut(BaseModel):
    code: str
    name: str
    description: str


class RecommendedIngredientOut(BaseModel):
    id: int
    name: str
    slug: str
    description: str
    caution: str | None
    note: str | None
    priority: int


class ExcludedIngredientOut(BaseModel):
    id: int
    name: str
    matched_allergy: str


class RecommendedProductOut(BaseModel):
    id: int
    name: str
    brand: str
    category: str
    price: int
    image_url: str | None
    matched_ingredients: list[str]


class RecommendationOut(BaseModel):
    scan_id: uuid.UUID
    condition: ConditionOut | None
    allergies: list[str]
    ingredients: list[RecommendedIngredientOut]
    excluded_ingredients: list[ExcludedIngredientOut]
    products: list[RecommendedProductOut]
    excluded_products_count: int
    disclaimer: str
