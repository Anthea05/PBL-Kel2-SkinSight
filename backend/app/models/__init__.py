"""Model SQLAlchemy.

Semua model di-import di sini agar terdaftar di Base.metadata (dibutuhkan Alembic & test).
"""

from app.models.education import EducationArticle
from app.models.ingredient import ConditionIngredient, Ingredient
from app.models.product import Product, product_ingredients
from app.models.quiz import QuizResponse
from app.models.scan import Scan
from app.models.skin_condition import SkinCondition
from app.models.user import User

__all__ = [
    "ConditionIngredient",
    "EducationArticle",
    "Ingredient",
    "Product",
    "QuizResponse",
    "Scan",
    "SkinCondition",
    "User",
    "product_ingredients",
]
