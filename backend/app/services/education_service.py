"""Logika bisnis edukasi: tips harian & saran nutrisi (umum atau per kondisi kulit)."""

from sqlalchemy.orm import Session

from app.core.constants import ArticleType
from app.core.exceptions import NotFoundError
from app.models.education import EducationArticle
from app.repositories.education_repository import EducationRepository
from app.repositories.skin_condition_repository import SkinConditionRepository
from app.schemas.education import ArticleOut


def _to_article_out(article: EducationArticle) -> ArticleOut:
    return ArticleOut(
        id=article.id,
        type=article.article_type,
        title=article.title,
        summary=article.summary,
        content=article.content,
        condition=article.condition.code if article.condition else None,
    )


class EducationService:
    def __init__(self, db: Session) -> None:
        self.articles = EducationRepository(db)
        self.conditions = SkinConditionRepository(db)

    def list_tips(self, condition_code: str | None = None) -> list[ArticleOut]:
        return self._list("tip", condition_code)

    def list_nutrition(self, condition_code: str | None = None) -> list[ArticleOut]:
        return self._list("nutrition", condition_code)

    def _list(self, article_type: ArticleType, condition_code: str | None) -> list[ArticleOut]:
        """Tanpa kondisi: semua artikel jenis tsb. Dengan kondisi: artikel kondisi itu + artikel umum."""
        condition_id = None
        code = condition_code.strip().lower() if condition_code else ""
        if code:
            condition = self.conditions.get_by_code(code)
            if condition is None:
                raise NotFoundError(f"Kondisi kulit '{condition_code}' tidak ditemukan.", code="CONDITION_NOT_FOUND")
            condition_id = condition.id
        articles = self.articles.list_by_type(article_type=article_type, condition_id=condition_id)
        return [_to_article_out(article) for article in articles]
