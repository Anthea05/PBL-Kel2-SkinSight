"""Logika bisnis profil pengguna."""

from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.core.exceptions import ConflictError
from app.models.user import User
from app.repositories.user_repository import UserRepository
from app.schemas.user import UserOut, UserUpdate

EMAIL_TAKEN_MESSAGE = "Email sudah digunakan akun lain."


class UserService:
    def __init__(self, db: Session) -> None:
        self.db = db
        self.users = UserRepository(db)

    def get_profile(self, user: User) -> UserOut:
        return UserOut.model_validate(user)

    def update_profile(self, user: User, data: UserUpdate) -> UserOut:
        """Ubah hanya field yang dikirim klien (name, phone, email)."""
        changes = data.model_dump(exclude_unset=True)
        if "email" in changes:
            changes["email"] = changes["email"].lower()
            owner = self.users.get_by_email(changes["email"])
            if owner is not None and owner.id != user.id:
                raise ConflictError(EMAIL_TAKEN_MESSAGE, code="EMAIL_ALREADY_REGISTERED")

        for field_name, value in changes.items():
            setattr(user, field_name, value)
        try:
            self.db.commit()
        except IntegrityError as exc:
            self.db.rollback()
            raise ConflictError(EMAIL_TAKEN_MESSAGE, code="EMAIL_ALREADY_REGISTERED") from exc
        return UserOut.model_validate(user)
