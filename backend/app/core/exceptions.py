"""Exception aplikasi dan handler-nya.

Semua error dikembalikan dengan format yang sama:
    {"success": false, "error": {"code": "...", "message": "...", "details": [...]}}
Stack trace hanya dicatat di log server dan tidak pernah dikirim ke klien.
"""

import logging
from typing import Any

from fastapi import FastAPI, Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from starlette.exceptions import HTTPException as StarletteHTTPException

logger = logging.getLogger("app.errors")

INTERNAL_ERROR_MESSAGE = "Terjadi kesalahan pada server. Silakan coba lagi."

# Pesan standar untuk HTTPException bawaan FastAPI/Starlette (mis. route tidak ada).
_HTTP_ERRORS: dict[int, tuple[str, str]] = {
    400: ("BAD_REQUEST", "Permintaan tidak valid."),
    401: ("UNAUTHORIZED", "Autentikasi diperlukan."),
    403: ("FORBIDDEN", "Akses ditolak."),
    404: ("NOT_FOUND", "Endpoint tidak ditemukan."),
    405: ("METHOD_NOT_ALLOWED", "Metode HTTP tidak diizinkan untuk endpoint ini."),
    413: ("FILE_TOO_LARGE", "Ukuran request terlalu besar."),
}


class AppError(Exception):
    """Error yang sudah diantisipasi; otomatis diubah menjadi respons JSON yang rapi."""

    status_code: int = 400
    code: str = "BAD_REQUEST"
    message: str = "Permintaan tidak valid."

    def __init__(
        self,
        message: str | None = None,
        *,
        code: str | None = None,
        details: list[dict[str, Any]] | None = None,
        headers: dict[str, str] | None = None,
    ) -> None:
        self.message = message or self.message
        self.code = code or self.code
        self.details = details
        self.headers = headers
        super().__init__(self.message)


class BadRequestError(AppError):
    status_code = 400
    code = "BAD_REQUEST"
    message = "Permintaan tidak valid."


class ValidationAppError(AppError):
    status_code = 422
    code = "VALIDATION_ERROR"
    message = "Data yang dikirim tidak valid."


class UnauthorizedError(AppError):
    status_code = 401
    code = "UNAUTHORIZED"
    message = "Autentikasi diperlukan."

    def __init__(self, message: str | None = None, *, code: str | None = None) -> None:
        super().__init__(message, code=code, headers={"WWW-Authenticate": "Bearer"})


class NotFoundError(AppError):
    status_code = 404
    code = "NOT_FOUND"
    message = "Data tidak ditemukan."


class ConflictError(AppError):
    status_code = 409
    code = "CONFLICT"
    message = "Data sudah ada."


class PayloadTooLargeError(AppError):
    status_code = 413
    code = "FILE_TOO_LARGE"
    message = "Ukuran file terlalu besar."


class UnsupportedMediaTypeError(AppError):
    status_code = 415
    code = "UNSUPPORTED_MEDIA_TYPE"
    message = "Format file tidak didukung."


class RateLimitError(AppError):
    status_code = 429
    code = "RATE_LIMITED"
    message = "Terlalu banyak permintaan. Coba lagi nanti."


class ServiceUnavailableError(AppError):
    status_code = 503
    code = "SERVICE_UNAVAILABLE"
    message = "Layanan sedang tidak tersedia."


def error_payload(code: str, message: str, details: list[dict[str, Any]] | None = None) -> dict[str, Any]:
    """Bentuk body JSON standar untuk error."""
    error: dict[str, Any] = {"code": code, "message": message}
    if details:
        error["details"] = details
    return {"success": False, "error": error}


def _format_validation_errors(exc: RequestValidationError) -> list[dict[str, Any]]:
    """Ubah error validasi Pydantic menjadi daftar {field, message} yang mudah dibaca klien."""
    details = []
    for err in exc.errors():
        location = [str(part) for part in err.get("loc", ()) if part != "body"]
        message = str(err.get("msg", "Nilai tidak valid.")).removeprefix("Value error, ")
        details.append({"field": ".".join(location) or None, "message": message})
    return details


def register_exception_handlers(app: FastAPI) -> None:
    """Daftarkan semua exception handler ke aplikasi."""

    @app.exception_handler(AppError)
    async def handle_app_error(_: Request, exc: AppError) -> JSONResponse:
        return JSONResponse(
            status_code=exc.status_code,
            content=error_payload(exc.code, exc.message, exc.details),
            headers=exc.headers,
        )

    @app.exception_handler(RequestValidationError)
    async def handle_validation_error(_: Request, exc: RequestValidationError) -> JSONResponse:
        return JSONResponse(
            status_code=422,
            content=error_payload("VALIDATION_ERROR", "Data yang dikirim tidak valid.", _format_validation_errors(exc)),
        )

    @app.exception_handler(StarletteHTTPException)
    async def handle_http_error(_: Request, exc: StarletteHTTPException) -> JSONResponse:
        code, message = _HTTP_ERRORS.get(exc.status_code, ("HTTP_ERROR", "Permintaan gagal diproses."))
        return JSONResponse(
            status_code=exc.status_code,
            content=error_payload(code, message),
            headers=getattr(exc, "headers", None),
        )

    @app.exception_handler(Exception)
    async def handle_unexpected_error(request: Request, exc: Exception) -> JSONResponse:
        # Cadangan terakhir; normalnya error tak terduga sudah ditangkap di middleware.
        logger.error("Error tak terduga pada %s %s", request.method, request.url.path, exc_info=exc)
        return JSONResponse(status_code=500, content=error_payload("INTERNAL_SERVER_ERROR", INTERNAL_ERROR_MESSAGE))
