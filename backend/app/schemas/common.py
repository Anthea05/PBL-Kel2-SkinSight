"""Format respons standar API.

Sukses : {"success": true,  "data": ..., "message": "..."}
Error  : {"success": false, "error": {"code": "...", "message": "...", "details": [...]}}
Paginasi (di dalam data): {"items": [...], "page": 1, "page_size": 20, "total": 42, "total_pages": 3}
"""

from math import ceil
from typing import Any, Generic, TypeVar

from pydantic import BaseModel, ConfigDict

T = TypeVar("T")


class ORMModel(BaseModel):
    """Base schema yang bisa dibuat langsung dari objek SQLAlchemy."""

    model_config = ConfigDict(from_attributes=True)


class ApiResponse(BaseModel, Generic[T]):
    success: bool = True
    data: T | None = None
    message: str | None = None


class Page(BaseModel, Generic[T]):
    items: list[T]
    page: int
    page_size: int
    total: int
    total_pages: int

    @classmethod
    def create(cls, items: list[Any], *, page: int, page_size: int, total: int) -> "Page[Any]":
        return cls(
            items=items,
            page=page,
            page_size=page_size,
            total=total,
            total_pages=ceil(total / page_size) if total else 0,
        )


class ErrorDetail(BaseModel):
    field: str | None = None
    message: str


class ErrorInfo(BaseModel):
    code: str
    message: str
    details: list[ErrorDetail] | None = None


class ErrorResponse(BaseModel):
    success: bool = False
    error: ErrorInfo


def ok(data: Any = None, message: str | None = None) -> ApiResponse[Any]:
    """Bungkus data ke format respons sukses."""
    return ApiResponse(data=data, message=message)


# Dokumentasi OpenAPI untuk error yang umum.
AUTH_ERROR_RESPONSES: dict[int | str, dict[str, Any]] = {
    401: {"model": ErrorResponse, "description": "Token tidak ada, tidak valid, atau kedaluwarsa"},
}
COMMON_ERROR_RESPONSES: dict[int | str, dict[str, Any]] = {
    422: {"model": ErrorResponse, "description": "Data request tidak valid"},
    500: {"model": ErrorResponse, "description": "Kesalahan server"},
}
