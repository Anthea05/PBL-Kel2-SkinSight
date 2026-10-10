"""Middleware HTTP: request id, log setiap request, batas ukuran body, dan penangkap error tak terduga."""

import logging
import re
import time
import uuid
from collections.abc import Awaitable, Callable

from fastapi import FastAPI, Request, Response
from fastapi.responses import JSONResponse

from app.core.config import get_settings
from app.core.exceptions import INTERNAL_ERROR_MESSAGE, error_payload

logger = logging.getLogger("app.request")

# Ruang tambahan di atas MAX_UPLOAD_SIZE_MB untuk field form lain & header multipart.
MULTIPART_OVERHEAD_BYTES = 512 * 1024
_REQUEST_ID_PATTERN = re.compile(r"^[A-Za-z0-9\-]{1,64}$")


def register_middlewares(app: FastAPI) -> None:
    """Pasang middleware request ke aplikasi."""

    @app.middleware("http")
    async def request_context(
        request: Request, call_next: Callable[[Request], Awaitable[Response]]
    ) -> Response:
        incoming_id = request.headers.get("x-request-id", "")
        request_id = incoming_id if _REQUEST_ID_PATTERN.match(incoming_id) else uuid.uuid4().hex[:12]
        started = time.perf_counter()

        response = _reject_if_body_too_large(request)
        if response is None:
            try:
                response = await call_next(request)
            except Exception:
                # Detail error hanya masuk log server; klien menerima pesan umum.
                logger.exception("Error tak terduga [%s] %s %s", request_id, request.method, request.url.path)
                response = JSONResponse(
                    status_code=500,
                    content=error_payload("INTERNAL_SERVER_ERROR", INTERNAL_ERROR_MESSAGE),
                )

        duration_ms = (time.perf_counter() - started) * 1000
        response.headers["X-Request-ID"] = request_id
        logger.info(
            "%s %s -> %s (%.1f ms) [%s]",
            request.method,
            request.url.path,
            response.status_code,
            duration_ms,
            request_id,
        )
        return response


def _reject_if_body_too_large(request: Request) -> JSONResponse | None:
    """Tolak lebih awal request yang Content-Length-nya melebihi batas upload."""
    settings = get_settings()
    content_length = request.headers.get("content-length", "")
    limit = settings.max_upload_size_bytes + MULTIPART_OVERHEAD_BYTES
    if content_length.isdigit() and int(content_length) > limit:
        return JSONResponse(
            status_code=413,
            content=error_payload(
                "FILE_TOO_LARGE", f"Ukuran request melebihi batas {settings.max_upload_size_mb:g} MB."
            ),
        )
    return None
