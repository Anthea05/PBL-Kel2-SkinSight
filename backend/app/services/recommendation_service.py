"""Logika rekomendasi: bahan aktif + produk untuk hasil scan.

Alur:
1. Kondisi kulit diambil dari hasil scan (label model ML).
2. Bahan aktif diambil dari mapping condition_ingredients (urut prioritas).
3. Bahan yang cocok dengan ALERGI di kuis terbaru dikecualikan (dan dilaporkan di excluded_ingredients).
4. Produk dipilih dari produk yang mengandung bahan rekomendasi; produk yang mengandung bahan
   pemicu alergi (lewat relasi ingredient ATAU teks komposisi) ikut dikecualikan.
"""

import uuid

from sqlalchemy.orm import Session

from app.core.constants import MEDICAL_DISCLAIMER
from app.core.exceptions import NotFoundError, ValidationAppError
from app.models.user import User
from app.repositories.ingredient_repository import IngredientRepository
from app.repositories.product_repository import ProductRepository
from app.repositories.quiz_repository import QuizRepository
from app.repositories.scan_repository import ScanRepository
from app.schemas.recommendation import (
    ConditionOut,
    ExcludedIngredientOut,
    RecommendationOut,
    RecommendedIngredientOut,
    RecommendedProductOut,
)
from app.services.ingredient_matcher import AllergyMatcher

# Batas produk kandidat yang diperiksa per request (menjaga respons tetap cepat).
MAX_PRODUCT_CANDIDATES = 500


class RecommendationService:
    def __init__(self, db: Session) -> None:
        self.db = db
        self.scans = ScanRepository(db)
        self.quizzes = QuizRepository(db)
        self.ingredients = IngredientRepository(db)
        self.products = ProductRepository(db)

    def get_for_scan(
        self,
        user: User,
        scan_id: uuid.UUID,
        *,
        min_price: int | None = None,
        max_price: int | None = None,
        limit: int = 10,
    ) -> RecommendationOut:
        """Rekomendasi untuk satu scan milik user, sudah mengecualikan alergi dari kuis terbaru."""
        if min_price is not None and max_price is not None and min_price > max_price:
            raise ValidationAppError("min_price tidak boleh lebih besar dari max_price.")

        scan = self.scans.get_for_user(scan_id, user.id)
        if scan is None:
            raise NotFoundError("Data scan tidak ditemukan.", code="SCAN_NOT_FOUND")

        latest_quiz = self.quizzes.get_latest_for_user(user.id)
        allergies = list(latest_quiz.allergies) if latest_quiz else []
        matcher = AllergyMatcher(allergies, self.ingredients.list_all())

        condition = scan.condition
        if condition is None:  # label model belum punya data kondisi di database
            return RecommendationOut(
                scan_id=scan.id,
                condition=None,
                allergies=allergies,
                ingredients=[],
                excluded_ingredients=[],
                products=[],
                excluded_products_count=0,
                disclaimer=MEDICAL_DISCLAIMER,
            )

        ingredients, excluded_ingredients = self._split_ingredients(condition.id, matcher)
        products, excluded_products_count = self._pick_products(
            ingredients, matcher, min_price=min_price, max_price=max_price, limit=limit
        )
        return RecommendationOut(
            scan_id=scan.id,
            condition=ConditionOut(code=condition.code, name=condition.name, description=condition.description),
            allergies=allergies,
            ingredients=ingredients,
            excluded_ingredients=excluded_ingredients,
            products=products,
            excluded_products_count=excluded_products_count,
            disclaimer=MEDICAL_DISCLAIMER,
        )

    def _split_ingredients(
        self, condition_id: int, matcher: AllergyMatcher
    ) -> tuple[list[RecommendedIngredientOut], list[ExcludedIngredientOut]]:
        """Pisahkan bahan aktif kondisi menjadi: aman direkomendasikan vs dikecualikan karena alergi."""
        recommended: list[RecommendedIngredientOut] = []
        excluded: list[ExcludedIngredientOut] = []
        for link in self.ingredients.list_for_condition(condition_id):
            ingredient = link.ingredient
            matched_allergy = matcher.match_ingredient(ingredient)
            if matched_allergy:
                excluded.append(
                    ExcludedIngredientOut(id=ingredient.id, name=ingredient.name, matched_allergy=matched_allergy)
                )
                continue
            recommended.append(
                RecommendedIngredientOut(
                    id=ingredient.id,
                    name=ingredient.name,
                    slug=ingredient.slug,
                    description=ingredient.description,
                    caution=ingredient.caution,
                    note=link.note,
                    priority=link.priority,
                )
            )
        return recommended, excluded

    def _pick_products(
        self,
        ingredients: list[RecommendedIngredientOut],
        matcher: AllergyMatcher,
        *,
        min_price: int | None,
        max_price: int | None,
        limit: int,
    ) -> tuple[list[RecommendedProductOut], int]:
        """Produk yang mengandung bahan rekomendasi dan TIDAK mengandung pemicu alergi."""
        recommended_ids = {ingredient.id for ingredient in ingredients}
        candidates = self.products.list_recommendation_candidates(
            sorted(recommended_ids),
            min_price=min_price,
            max_price=max_price,
            max_results=MAX_PRODUCT_CANDIDATES,
        )
        picked: list[RecommendedProductOut] = []
        excluded_count = 0
        for product, _match_count in candidates:
            if matcher.match_product(product.ingredients, product.ingredients_text):
                excluded_count += 1
                continue
            if len(picked) < limit:
                picked.append(
                    RecommendedProductOut(
                        id=product.id,
                        name=product.name,
                        brand=product.brand,
                        category=product.category,
                        price=product.price,
                        image_url=product.image_url,
                        matched_ingredients=[item.name for item in product.ingredients if item.id in recommended_ids],
                    )
                )
        return picked, excluded_count
