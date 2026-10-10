"""Endpoint kuis kondisi kulit & gaya hidup."""

from fastapi import APIRouter

from app.core.dependencies import CurrentUser, QuizServiceDep
from app.schemas.common import AUTH_ERROR_RESPONSES, ApiResponse, ErrorResponse, ok
from app.schemas.quiz import QuizCreate, QuizOut

router = APIRouter(prefix="/quiz", tags=["Quiz"], responses=AUTH_ERROR_RESPONSES)


@router.post("", status_code=201, summary="Kirim jawaban kuis")
def submit_quiz(payload: QuizCreate, current_user: CurrentUser, service: QuizServiceDep) -> ApiResponse[QuizOut]:
    return ok(service.submit(current_user, payload), "Jawaban kuis tersimpan.")


@router.get(
    "/latest",
    summary="Jawaban kuis terbaru",
    responses={404: {"model": ErrorResponse, "description": "Belum pernah mengisi kuis"}},
)
def get_latest_quiz(current_user: CurrentUser, service: QuizServiceDep) -> ApiResponse[QuizOut]:
    return ok(service.get_latest(current_user))
