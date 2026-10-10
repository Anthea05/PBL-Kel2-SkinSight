"""Akses data tabel skin_conditions."""

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.skin_condition import SkinCondition


class SkinConditionRepository:
    def __init__(self, db: Session) -> None:
        self.db = db

    def get_by_code(self, code: str) -> SkinCondition | None:
        return self.db.scalar(select(SkinCondition).where(SkinCondition.code == code))

    def list_all(self) -> list[SkinCondition]:
        return list(self.db.scalars(select(SkinCondition).order_by(SkinCondition.code)).all())
