"""Skema bahan aktif (ingredients)."""

from app.schemas.common import ORMModel


class IngredientBrief(ORMModel):
    id: int
    name: str
    slug: str


class IngredientOut(ORMModel):
    id: int
    name: str
    slug: str
    aliases: list[str]
    description: str
    caution: str | None


class IngredientConditionOut(ORMModel):
    code: str
    name: str
    note: str | None


class IngredientDetailOut(IngredientOut):
    conditions: list[IngredientConditionOut]
