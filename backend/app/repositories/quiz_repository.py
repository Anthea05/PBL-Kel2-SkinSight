"""Akses data tabel quiz_responses."""

import uuid

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.quiz import QuizResponse


class QuizRepository:
    def __init__(self, db: Session) -> None:
        self.db = db

    def add(self, quiz: QuizResponse) -> QuizResponse:
        self.db.add(quiz)
        self.db.flush()
        return quiz

    def get_latest_for_user(self, user_id: uuid.UUID) -> QuizResponse | None:
        """Kuis terbaru milik user (memakai index user_id + created_at)."""
        stmt = (
            select(QuizResponse)
            .where(QuizResponse.user_id == user_id)
            .order_by(QuizResponse.created_at.desc())
            .limit(1)
        )
        return self.db.scalar(stmt)
