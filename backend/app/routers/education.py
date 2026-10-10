"""Endpoint edukasi pola hidup (publik, tanpa login)."""

from typing import Annotated

from fastapi import APIRouter, Query

from app.core.dependencies import EducationServiceDep
from app.schemas.common import ApiResponse, ErrorResponse, ok
from app.schemas.education import ArticleOut

router = APIRouter(
    prefix="/education",
    tags=["Education"],
    responses={404: {"model": ErrorResponse, "description": "Kode kondisi tidak dikenal"}},
)

ConditionQuery = Annotated[
    str | None,
    Query(max_length=50, description="Kode kondisi kulit, mis. 'oily'. Kosong = semua artikel."),
]


@router.get("/tips", summary="Tips perawatan harian")
def list_tips(service: EducationServiceDep, condition: ConditionQuery = None) -> ApiResponse[list[ArticleOut]]:
    return ok(service.list_tips(condition))


@router.get("/nutrition", summary="Saran nutrisi per kondisi kulit")
def list_nutrition(service: EducationServiceDep, condition: ConditionQuery = None) -> ApiResponse[list[ArticleOut]]:
    return ok(service.list_nutrition(condition))
