"""Logika bisnis daftar bahan aktif."""

from sqlalchemy.orm import Session

from app.core.exceptions import NotFoundError
from app.repositories.ingredient_repository import IngredientRepository
from app.schemas.common import Page
from app.schemas.ingredient import IngredientConditionOut, IngredientDetailOut, IngredientOut


class IngredientService:
    def __init__(self, db: Session) -> None:
        self.ingredients = IngredientRepository(db)

    def list_ingredients(self, *, page: int, page_size: int, q: str | None) -> Page[IngredientOut]:
        query = q.strip() if q else None
        items, total = self.ingredients.search(offset=(page - 1) * page_size, limit=page_size, q=query or None)
        return Page.create(
            [IngredientOut.model_validate(item) for item in items], page=page, page_size=page_size, total=total
        )

    def get_ingredient(self, ingredient_id: int) -> IngredientDetailOut:
        """Detail bahan + daftar kondisi kulit yang direkomendasikan memakai bahan ini."""
        ingredient = self.ingredients.get_by_id(ingredient_id)
        if ingredient is None:
            raise NotFoundError("Ingredient tidak ditemukan.", code="INGREDIENT_NOT_FOUND")
        conditions = [
            IngredientConditionOut(code=link.condition.code, name=link.condition.name, note=link.note)
            for link in sorted(ingredient.condition_links, key=lambda link: link.condition.code)
        ]
        return IngredientDetailOut(
            id=ingredient.id,
            name=ingredient.name,
            slug=ingredient.slug,
            aliases=ingredient.aliases,
            description=ingredient.description,
            caution=ingredient.caution,
            conditions=conditions,
        )
