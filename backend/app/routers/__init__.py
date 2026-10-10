"""Router API v1. Router hanya menerima request, memanggil service, dan membungkus respons."""

from fastapi import APIRouter

from app.routers import auth, education, health, ingredients, products, quiz, scans, users
from app.schemas.common import COMMON_ERROR_RESPONSES

api_router = APIRouter(responses=COMMON_ERROR_RESPONSES)
api_router.include_router(health.router)
api_router.include_router(auth.router)
api_router.include_router(users.router)
api_router.include_router(quiz.router)
api_router.include_router(scans.router)
api_router.include_router(products.router)
api_router.include_router(ingredients.router)
api_router.include_router(education.router)
