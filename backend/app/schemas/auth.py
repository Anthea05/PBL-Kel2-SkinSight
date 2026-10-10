"""Skema autentikasi: register, login, refresh token."""

from pydantic import BaseModel, ConfigDict, EmailStr, Field

from app.schemas.user import NameStr, PhoneStr, UserOut


class RegisterRequest(BaseModel):
    model_config = ConfigDict(
        extra="forbid",
        json_schema_extra={
            "example": {"name": "Alea Kucing", "email": "alea@skinsight.id", "password": "skinsight123"}
        },
    )

    name: NameStr
    email: EmailStr
    password: str = Field(min_length=8, max_length=128)
    phone: PhoneStr | None = None


class LoginRequest(BaseModel):
    model_config = ConfigDict(
        extra="forbid",
        json_schema_extra={"example": {"email": "alea@skinsight.id", "password": "skinsight123"}},
    )

    email: EmailStr
    password: str = Field(min_length=1, max_length=128)


class RefreshRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    refresh_token: str = Field(min_length=1)


class TokenOut(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int = Field(description="Masa berlaku access token dalam detik")


class AuthOut(TokenOut):
    user: UserOut
