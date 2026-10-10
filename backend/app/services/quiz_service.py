"""Logika bisnis kuis kondisi kulit & gaya hidup."""

from sqlalchemy.orm import Session

from app.core.exceptions import NotFoundError
from app.models.quiz import QuizResponse
from app.models.user import User
from app.repositories.quiz_repository import QuizRepository
from app.schemas.quiz import QuizCreate, QuizOut


class QuizService:
    def __init__(self, db: Session) -> None:
        self.db = db
        self.quizzes = QuizRepository(db)

    def submit(self, user: User, data: QuizCreate) -> QuizOut:
        """Simpan jawaban kuis baru. Riwayat lama tetap disimpan; yang dipakai adalah yang terbaru."""
        quiz = self.quizzes.add(QuizResponse(user_id=user.id, **data.model_dump()))
        self.db.commit()
        return QuizOut.model_validate(quiz)

    def get_latest(self, user: User) -> QuizOut:
        quiz = self.quizzes.get_latest_for_user(user.id)
        if quiz is None:
            raise NotFoundError("Kamu belum mengisi kuis.", code="QUIZ_NOT_FOUND")
        return QuizOut.model_validate(quiz)
