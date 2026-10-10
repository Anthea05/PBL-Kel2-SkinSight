"""Endpoint health check."""

from fastapi import APIRouter

from app.core.dependencies import HealthServiceDep
from app.schemas.common import ApiResponse, ok
from app.schemas.health import HealthOut

router = APIRouter(tags=["Health"])


@router.get("/health", summary="Cek status API, database, dan service ML")
def health_check(service: HealthServiceDep) -> ApiResponse[HealthOut]:
    return ok(service.check())
