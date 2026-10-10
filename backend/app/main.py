"""Entry point FastAPI SkinSight.

Jalankan: uvicorn app.main:app --reload   (dokumentasi interaktif di /docs)
"""

from collections.abc import AsyncIterator
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import get_settings
from app.core.exceptions import register_exception_handlers
from app.core.logging_config import setup_logging
from app.core.middleware import register_middlewares
from app.routers import api_router
from app.services.ml_service import init_ml_service

API_DESCRIPTION = """
Backend aplikasi mobile **SkinSight** (PBL Polinema): kuis gaya hidup, scan kulit berbasis ML,
rekomendasi bahan aktif & produk (mengecualikan alergi), katalog produk, dan edukasi.

Endpoint terproteksi memakai header `Authorization: Bearer <access_token>`.

> Hasil analisis **bukan diagnosis medis**.
"""


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncIterator[None]:
    """Startup: model ML dimuat SEKALI di sini (bukan per request). Shutdown: lepas resource."""
    app.state.ml_service = init_ml_service(get_settings())
    yield
    app.state.ml_service.close()


def create_app() -> FastAPI:
    """Rakit aplikasi: logging, middleware, CORS, exception handler, dan router."""
    settings = get_settings()
    setup_logging(settings.log_level)

    app = FastAPI(
        title=settings.app_name,
        version=settings.app_version,
        description=API_DESCRIPTION,
        lifespan=lifespan,
    )
    register_middlewares(app)
    # CORS ditambahkan terakhir agar menjadi lapisan terluar (header CORS ikut ada di respons error).
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.cors_origin_list,
        allow_credentials=False,  # token dikirim lewat header Authorization, bukan cookie
        allow_methods=["*"],
        allow_headers=["*"],
        expose_headers=["X-Request-ID", "Retry-After"],
    )
    register_exception_handlers(app)
    app.include_router(api_router, prefix=settings.api_v1_prefix)
    return app


app = create_app()
