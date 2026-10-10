"""Endpoint profil pengguna yang sedang login."""

from fastapi import APIRouter

from app.core.dependencies import CurrentUser, UserServiceDep
from app.schemas.common import AUTH_ERROR_RESPONSES, ApiResponse, ErrorResponse, ok
from app.schemas.user import UserOut, UserUpdate

router = APIRouter(prefix="/users", tags=["Users"], responses=AUTH_ERROR_RESPONSES)


@router.get("/me", summary="Profil saya")
def get_me(current_user: CurrentUser, service: UserServiceDep) -> ApiResponse[UserOut]:
    return ok(service.get_profile(current_user))


@router.patch(
    "/me",
    summary="Ubah profil (name, phone, email)",
    responses={409: {"model": ErrorResponse, "description": "Email sudah dipakai akun lain"}},
)
def update_me(payload: UserUpdate, current_user: CurrentUser, service: UserServiceDep) -> ApiResponse[UserOut]:
    return ok(service.update_profile(current_user, payload), "Profil berhasil diperbarui.")
