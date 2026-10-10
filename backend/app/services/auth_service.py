"""Logika bisnis autentikasi: registrasi, login, dan refresh token."""

import uuid
from functools import lru_cache

from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.core.exceptions import ConflictError, UnauthorizedError
from app.core.security import (
    REFRESH_TOKEN_TYPE,
    create_access_token,
    create_refresh_token,
    decode_token,
    hash_password,
    verify_password,
)
from app.models.user import User
from app.repositories.user_repository import UserRepository
from app.schemas.auth import AuthOut, LoginRequest, RefreshRequest, RegisterRequest, TokenOut
from app.schemas.user import UserOut

INVALID_CREDENTIALS_MESSAGE = "Email atau password salah."


@lru_cache
def _dummy_password_hash() -> str:
    """Hash palsu agar waktu respons login tetap sama walaupun email tidak terdaftar."""
    return hash_password("skinsight-dummy-password")


class AuthService:
    def __init__(self, db: Session) -> None:
        self.db = db
        self.users = UserRepository(db)

    def register(self, data: RegisterRequest) -> AuthOut:
        """Daftarkan user baru lalu langsung kembalikan token (user otomatis login)."""
        email = data.email.lower()
        if self.users.get_by_email(email) is not None:
            raise ConflictError("Email sudah terdaftar.", code="EMAIL_ALREADY_REGISTERED")
        user = User(name=data.name, email=email, phone=data.phone, password_hash=hash_password(data.password))
        try:
            self.users.add(user)
            self.db.commit()
        except IntegrityError as exc:  # dua registrasi bersamaan dengan email yang sama
            self.db.rollback()
            raise ConflictError("Email sudah terdaftar.", code="EMAIL_ALREADY_REGISTERED") from exc
        return self._auth_response(user)

    def login(self, data: LoginRequest) -> AuthOut:
        """Cek email & password. Pesan error dibuat sama agar tidak membocorkan email yang terdaftar."""
        user = self.users.get_by_email(data.email.lower())
        if user is None:
            verify_password(data.password, _dummy_password_hash())
            raise UnauthorizedError(INVALID_CREDENTIALS_MESSAGE, code="INVALID_CREDENTIALS")
        if not verify_password(data.password, user.password_hash):
            raise UnauthorizedError(INVALID_CREDENTIALS_MESSAGE, code="INVALID_CREDENTIALS")
        if not user.is_active:
            raise UnauthorizedError("Akun tidak aktif.", code="ACCOUNT_INACTIVE")
        return self._auth_response(user)

    def refresh(self, data: RefreshRequest) -> TokenOut:
        """Tukar refresh token yang masih berlaku dengan pasangan token baru."""
        payload = decode_token(data.refresh_token, expected_type=REFRESH_TOKEN_TYPE)
        try:
            user_id = uuid.UUID(str(payload["sub"]))
        except ValueError as exc:
            raise UnauthorizedError("Token tidak valid.", code="INVALID_TOKEN") from exc
        user = self.users.get_by_id(user_id)
        if user is None or not user.is_active:
            raise UnauthorizedError("Akun tidak ditemukan atau tidak aktif.", code="INVALID_TOKEN")
        return self._issue_tokens(user)

    def _auth_response(self, user: User) -> AuthOut:
        tokens = self._issue_tokens(user)
        return AuthOut(**tokens.model_dump(), user=UserOut.model_validate(user))

    @staticmethod
    def _issue_tokens(user: User) -> TokenOut:
        subject = str(user.id)
        return TokenOut(
            access_token=create_access_token(subject),
            refresh_token=create_refresh_token(subject),
            expires_in=get_settings().access_token_expire_minutes * 60,
        )
