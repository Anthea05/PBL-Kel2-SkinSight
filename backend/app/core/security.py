"""Hash password (Argon2) serta pembuatan dan verifikasi JWT (access & refresh token)."""

import uuid
from datetime import UTC, datetime, timedelta
from typing import Any

import jwt
from argon2 import PasswordHasher
from argon2.exceptions import InvalidHashError, VerificationError

from app.core.config import get_settings
from app.core.exceptions import UnauthorizedError

ACCESS_TOKEN_TYPE = "access"
REFRESH_TOKEN_TYPE = "refresh"

_password_hasher = PasswordHasher()


def hash_password(password: str) -> str:
    """Hash password dengan Argon2id (salt acak dibuat otomatis)."""
    return _password_hasher.hash(password)


def verify_password(password: str, password_hash: str) -> bool:
    """True jika password cocok dengan hash."""
    try:
        return _password_hasher.verify(password_hash, password)
    except (VerificationError, InvalidHashError):
        return False


def _create_token(subject: str, token_type: str, expires_delta: timedelta) -> str:
    settings = get_settings()
    now = datetime.now(UTC)
    payload = {
        "sub": subject,
        "type": token_type,
        "iat": now,
        "exp": now + expires_delta,
        "jti": uuid.uuid4().hex,
    }
    return jwt.encode(payload, settings.jwt_secret_key, algorithm=settings.jwt_algorithm)


def create_access_token(user_id: str) -> str:
    """Token berumur pendek untuk mengakses endpoint terproteksi."""
    minutes = get_settings().access_token_expire_minutes
    return _create_token(user_id, ACCESS_TOKEN_TYPE, timedelta(minutes=minutes))


def create_refresh_token(user_id: str) -> str:
    """Token berumur panjang, hanya untuk meminta access token baru di /auth/refresh."""
    days = get_settings().refresh_token_expire_days
    return _create_token(user_id, REFRESH_TOKEN_TYPE, timedelta(days=days))


def decode_token(token: str, expected_type: str) -> dict[str, Any]:
    """Verifikasi tanda tangan, masa berlaku, dan jenis token. Gagal -> UnauthorizedError (401)."""
    settings = get_settings()
    try:
        payload = jwt.decode(
            token,
            settings.jwt_secret_key,
            algorithms=[settings.jwt_algorithm],
            options={"require": ["exp", "iat", "sub", "type"]},
        )
    except jwt.ExpiredSignatureError as exc:
        raise UnauthorizedError("Token sudah kedaluwarsa.", code="TOKEN_EXPIRED") from exc
    except jwt.InvalidTokenError as exc:
        raise UnauthorizedError("Token tidak valid.", code="INVALID_TOKEN") from exc

    if payload.get("type") != expected_type:
        raise UnauthorizedError("Jenis token tidak sesuai.", code="INVALID_TOKEN")
    return payload
