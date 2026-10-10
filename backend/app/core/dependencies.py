"""Dependency FastAPI: sesi database, user yang sedang login, paginasi, dan pembuatan service."""

import uuid
from typing import Annotated

from fastapi import Depends, Query, Request
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.orm import Session

from app.core.exceptions import UnauthorizedError
from app.core.security import ACCESS_TOKEN_TYPE, decode_token
from app.db.session import get_db
from app.models.user import User
from app.repositories.user_repository import UserRepository
from app.services.auth_service import AuthService
from app.services.education_service import EducationService
from app.services.health_service import HealthService
from app.services.ingredient_service import IngredientService
from app.services.ml_service import MLService
from app.services.product_service import ProductService
from app.services.quiz_service import QuizService
from app.services.recommendation_service import RecommendationService
from app.services.scan_service import ScanService
from app.services.user_service import UserService

DbSession = Annotated[Session, Depends(get_db)]

# auto_error=False: header kosong ditangani sendiri agar balasannya 401 dengan format error aplikasi.
bearer_scheme = HTTPBearer(auto_error=False, description="Access token dari /auth/login atau /auth/register")


def get_current_user(
    db: DbSession,
    credentials: Annotated[HTTPAuthorizationCredentials | None, Depends(bearer_scheme)],
) -> User:
    """Ambil user dari header `Authorization: Bearer <access_token>`. Gagal -> 401."""
    if credentials is None:
        raise UnauthorizedError("Token akses diperlukan. Kirim header 'Authorization: Bearer <access_token>'.")
    payload = decode_token(credentials.credentials, expected_type=ACCESS_TOKEN_TYPE)
    try:
        user_id = uuid.UUID(str(payload["sub"]))
    except ValueError as exc:
        raise UnauthorizedError("Token tidak valid.", code="INVALID_TOKEN") from exc
    user = UserRepository(db).get_by_id(user_id)
    if user is None or not user.is_active:
        raise UnauthorizedError("Akun tidak ditemukan atau tidak aktif.", code="INVALID_TOKEN")
    return user


CurrentUser = Annotated[User, Depends(get_current_user)]


class PageParams:
    """Parameter paginasi standar: ?page=1&page_size=20."""

    def __init__(
        self,
        page: Annotated[int, Query(ge=1, description="Nomor halaman, mulai dari 1")] = 1,
        page_size: Annotated[int, Query(ge=1, le=100, description="Jumlah data per halaman (maks. 100)")] = 20,
    ) -> None:
        self.page = page
        self.page_size = page_size


Pagination = Annotated[PageParams, Depends()]


def get_ml_service(request: Request) -> MLService:
    """Service ML yang sudah dimuat sekali saat startup (lihat lifespan di main.py)."""
    return request.app.state.ml_service


MLServiceDep = Annotated[MLService, Depends(get_ml_service)]


def get_auth_service(db: DbSession) -> AuthService:
    return AuthService(db)


def get_user_service(db: DbSession) -> UserService:
    return UserService(db)


def get_quiz_service(db: DbSession) -> QuizService:
    return QuizService(db)


def get_scan_service(db: DbSession, ml_service: MLServiceDep) -> ScanService:
    return ScanService(db, ml_service)


def get_recommendation_service(db: DbSession) -> RecommendationService:
    return RecommendationService(db)


def get_product_service(db: DbSession) -> ProductService:
    return ProductService(db)


def get_ingredient_service(db: DbSession) -> IngredientService:
    return IngredientService(db)


def get_education_service(db: DbSession) -> EducationService:
    return EducationService(db)


def get_health_service(db: DbSession, ml_service: MLServiceDep) -> HealthService:
    return HealthService(db, ml_service)


AuthServiceDep = Annotated[AuthService, Depends(get_auth_service)]
UserServiceDep = Annotated[UserService, Depends(get_user_service)]
QuizServiceDep = Annotated[QuizService, Depends(get_quiz_service)]
ScanServiceDep = Annotated[ScanService, Depends(get_scan_service)]
RecommendationServiceDep = Annotated[RecommendationService, Depends(get_recommendation_service)]
ProductServiceDep = Annotated[ProductService, Depends(get_product_service)]
IngredientServiceDep = Annotated[IngredientService, Depends(get_ingredient_service)]
EducationServiceDep = Annotated[EducationService, Depends(get_education_service)]
HealthServiceDep = Annotated[HealthService, Depends(get_health_service)]
