"""Skema profil pengguna (mengikuti ProfileData di Flutter: name, phone, email)."""

import uuid
from datetime import datetime
from typing import Annotated

from pydantic import BaseModel, ConfigDict, EmailStr, StringConstraints, field_validator

from app.schemas.common import ORMModel

NameStr = Annotated[str, StringConstraints(strip_whitespace=True, min_length=1, max_length=100)]
PhoneStr = Annotated[
    str,
    StringConstraints(strip_whitespace=True, min_length=6, max_length=20, pattern=r"^\+?[0-9\s\-()]+$"),
]


class UserOut(ORMModel):
    id: uuid.UUID
    name: str
    email: str
    phone: str | None
    created_at: datetime


class UserUpdate(BaseModel):
    """PATCH sebagian: hanya field yang dikirim yang diubah. phone boleh null untuk menghapus."""

    model_config = ConfigDict(
        extra="forbid",
        json_schema_extra={"example": {"name": "Alea Kucing", "phone": "+62 812-3456-7890"}},
    )

    name: NameStr | None = None
    phone: PhoneStr | None = None
    email: EmailStr | None = None

    @field_validator("name", "email")
    @classmethod
    def _not_null(cls, value: str | None) -> str | None:
        if value is None:
            raise ValueError("tidak boleh null")
        return value
