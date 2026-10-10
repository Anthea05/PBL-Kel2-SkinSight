"""Endpoint bahan aktif (publik, tanpa login)."""

from typing import Annotated

from fastapi import APIRouter, Path, Query

from app.core.dependencies import IngredientServiceDep, Pagination
from app.schemas.common import ApiResponse, ErrorResponse, Page, ok
from app.schemas.ingredient import IngredientDetailOut, IngredientOut

router = APIRouter(prefix="/ingredients", tags=["Ingredients"])


@router.get("", summary="Daftar bahan aktif (paginasi + pencarian)")
def list_ingredients(
    service: IngredientServiceDep,
    pagination: Pagination,
    q: Annotated[str | None, Query(max_length=100, description="Cari nama/alias, mis. 'parfum'")] = None,
) -> ApiResponse[Page[IngredientOut]]:
    return ok(service.list_ingredients(page=pagination.page, page_size=pagination.page_size, q=q))


@router.get(
    "/{ingredient_id}",
    summary="Detail bahan aktif + kondisi kulit yang cocok",
    responses={404: {"model": ErrorResponse, "description": "Ingredient tidak ditemukan"}},
)
def get_ingredient(
    ingredient_id: Annotated[int, Path(ge=1)], service: IngredientServiceDep
) -> ApiResponse[IngredientDetailOut]:
    return ok(service.get_ingredient(ingredient_id))
