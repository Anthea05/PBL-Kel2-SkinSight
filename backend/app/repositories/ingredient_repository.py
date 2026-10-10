"""Akses data tabel ingredients dan condition_ingredients."""

from sqlalchemy import Text, cast, func, or_, select
from sqlalchemy.orm import Session, joinedload, selectinload

from app.models.ingredient import ConditionIngredient, Ingredient
from app.repositories.helpers import LIKE_ESCAPE_CHAR, like_contains


class IngredientRepository:
    def __init__(self, db: Session) -> None:
        self.db = db

    def search(self, *, offset: int, limit: int, q: str | None = None) -> tuple[list[Ingredient], int]:
        """Daftar ingredient (urut nama). `q` mencari di nama, slug, dan alias."""
        filters = []
        if q:
            pattern = like_contains(q)
            filters.append(
                or_(
                    Ingredient.name.ilike(pattern, escape=LIKE_ESCAPE_CHAR),
                    Ingredient.slug.ilike(pattern, escape=LIKE_ESCAPE_CHAR),
                    cast(Ingredient.aliases, Text).ilike(pattern, escape=LIKE_ESCAPE_CHAR),
                )
            )
        total = self.db.scalar(select(func.count()).select_from(Ingredient).where(*filters)) or 0
        stmt = select(Ingredient).where(*filters).order_by(Ingredient.name).offset(offset).limit(limit)
        return list(self.db.scalars(stmt).all()), total

    def get_by_id(self, ingredient_id: int) -> Ingredient | None:
        stmt = (
            select(Ingredient)
            .options(selectinload(Ingredient.condition_links).joinedload(ConditionIngredient.condition))
            .where(Ingredient.id == ingredient_id)
        )
        return self.db.scalar(stmt)

    def get_by_slug(self, slug: str) -> Ingredient | None:
        return self.db.scalar(select(Ingredient).where(Ingredient.slug == slug))

    def list_all(self) -> list[Ingredient]:
        return list(self.db.scalars(select(Ingredient).order_by(Ingredient.name)).all())

    def list_for_condition(self, condition_id: int) -> list[ConditionIngredient]:
        """Mapping bahan aktif untuk satu kondisi, urut prioritas."""
        stmt = (
            select(ConditionIngredient)
            .options(joinedload(ConditionIngredient.ingredient))
            .where(ConditionIngredient.condition_id == condition_id)
            .order_by(ConditionIngredient.priority, ConditionIngredient.ingredient_id)
        )
        return list(self.db.scalars(stmt).all())
