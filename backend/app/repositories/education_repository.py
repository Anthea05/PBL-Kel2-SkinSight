"""Akses data tabel education_articles."""

from sqlalchemy import or_, select
from sqlalchemy.orm import Session, joinedload

from app.models.education import EducationArticle


class EducationRepository:
    def __init__(self, db: Session) -> None:
        self.db = db

    def list_by_type(self, *, article_type: str, condition_id: int | None = None) -> list[EducationArticle]:
        """Artikel satu jenis. Jika condition_id diisi: artikel kondisi tsb + artikel umum (spesifik dulu)."""
        stmt = (
            select(EducationArticle)
            .options(joinedload(EducationArticle.condition))
            .where(EducationArticle.article_type == article_type)
        )
        if condition_id is not None:
            stmt = stmt.where(
                or_(EducationArticle.condition_id == condition_id, EducationArticle.condition_id.is_(None))
            )
        stmt = stmt.order_by(EducationArticle.condition_id.is_(None), EducationArticle.id)
        return list(self.db.scalars(stmt).all())
