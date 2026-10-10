"""Endpoint autentikasi: register, login, refresh (dibatasi rate limit)."""

from fastapi import APIRouter, Depends

from app.core.dependencies import AuthServiceDep
from app.core.rate_limit import rate_limit
from app.schemas.auth import AuthOut, LoginRequest, RefreshRequest, RegisterRequest, TokenOut
from app.schemas.common import AUTH_ERROR_RESPONSES, ApiResponse, ErrorResponse, ok

router = APIRouter(
    prefix="/auth",
    tags=["Auth"],
    dependencies=[Depends(rate_limit("auth"))],
    responses={429: {"model": ErrorResponse, "description": "Terlalu banyak percobaan"}},
)


@router.post(
    "/register",
    status_code=201,
    summary="Daftar akun baru (langsung mendapat token)",
    responses={409: {"model": ErrorResponse, "description": "Email sudah terdaftar"}},
)
def register(payload: RegisterRequest, service: AuthServiceDep) -> ApiResponse[AuthOut]:
    return ok(service.register(payload), "Registrasi berhasil.")


@router.post("/login", summary="Login dengan email & password", responses=AUTH_ERROR_RESPONSES)
def login(payload: LoginRequest, service: AuthServiceDep) -> ApiResponse[AuthOut]:
    return ok(service.login(payload), "Login berhasil.")


@router.post("/refresh", summary="Tukar refresh token dengan token baru", responses=AUTH_ERROR_RESPONSES)
def refresh(payload: RefreshRequest, service: AuthServiceDep) -> ApiResponse[TokenOut]:
    return ok(service.refresh(payload), "Token berhasil diperbarui.")
