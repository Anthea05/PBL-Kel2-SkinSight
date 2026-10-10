"""Skema artikel edukasi (tips harian & nutrisi)."""

from pydantic import BaseModel


class ArticleOut(BaseModel):
    id: int
    type: str
    title: str
    summary: str
    content: str
    condition: str | None  # kode kondisi kulit; null = berlaku umum
