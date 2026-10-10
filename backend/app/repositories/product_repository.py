"""Akses data tabel products dan product_ingredients."""

from collections.abc import Sequence
from dataclasses import dataclass

from sqlalchemy import ColumnElement, func, or_, select
from sqlalchemy.orm import Session, selectinload

from app.models.ingredient import ConditionIngredient
from app.models.product import Product, product_ingredients
from app.repositories.helpers import LIKE_ESCAPE_CHAR, like_contains

# Pilihan urutan katalog. Ditambah id agar urutan stabil antar halaman.
SORT_OPTIONS = {
    "price_asc": (Product.price.asc(), Product.id.asc()),
    "price_desc": (Product.price.desc(), Product.id.asc()),
    "name_asc": (Product.name.asc(), Product.id.asc()),
    "newest": (Product.created_at.desc(), Product.id.desc()),
}


@dataclass(frozen=True)
class ProductFilter:
    min_price: int | None = None
    max_price: int | None = None
    category: str | None = None
    condition_id: int | None = None
    q: str | None = None
    sort: str = "price_asc"


class ProductRepository:
    def __init__(self, db: Session) -> None:
        self.db = db

    def search(self, filters: ProductFilter, *, offset: int, limit: int) -> tuple[list[Product], int]:
        """Katalog dengan filter harga, kategori, kondisi kulit, pencarian teks, dan urutan."""
        conditions = self._build_conditions(filters)
        total = self.db.scalar(select(func.count()).select_from(Product).where(*conditions)) or 0
        stmt = (
            select(Product)
            .where(*conditions)
            .order_by(*SORT_OPTIONS.get(filters.sort, SORT_OPTIONS["price_asc"]))
            .offset(offset)
            .limit(limit)
        )
        return list(self.db.scalars(stmt).all()), total

    def get_by_id(self, product_id: int) -> Product | None:
        stmt = select(Product).options(selectinload(Product.ingredients)).where(Product.id == product_id)
        return self.db.scalar(stmt)

    def get_by_brand_and_name(self, brand: str, name: str) -> Product | None:
        return self.db.scalar(select(Product).where(Product.brand == brand, Product.name == name))

    def add(self, product: Product) -> Product:
        self.db.add(product)
        self.db.flush()
        return product

    def list_recommendation_candidates(
        self,
        ingredient_ids: Sequence[int],
        *,
        min_price: int | None,
        max_price: int | None,
        max_results: int,
    ) -> list[tuple[Product, int]]:
        """Produk yang mengandung minimal satu ingredient rekomendasi.

        Diurutkan dari jumlah ingredient rekomendasi terbanyak, lalu harga termurah.
        Return list (produk, jumlah ingredient yang cocok).
        """
        if not ingredient_ids:
            return []
        match_count = func.count(product_ingredients.c.ingredient_id).label("match_count")
        stmt = (
            select(Product, match_count)
            .join(product_ingredients, product_ingredients.c.product_id == Product.id)
            .where(product_ingredients.c.ingredient_id.in_(ingredient_ids))
            .group_by(Product.id)
            .order_by(match_count.desc(), Product.price.asc(), Product.id.asc())
            .limit(max_results)
            .options(selectinload(Product.ingredients))
        )
        if min_price is not None:
            stmt = stmt.where(Product.price >= min_price)
        if max_price is not None:
            stmt = stmt.where(Product.price <= max_price)
        return [(product, count) for product, count in self.db.execute(stmt).all()]

    @staticmethod
    def _build_conditions(filters: ProductFilter) -> list[ColumnElement[bool]]:
        conditions: list[ColumnElement[bool]] = []
        if filters.min_price is not None:
            conditions.append(Product.price >= filters.min_price)
        if filters.max_price is not None:
            conditions.append(Product.price <= filters.max_price)
        if filters.category:
            conditions.append(Product.category == filters.category)
        if filters.q:
            pattern = like_contains(filters.q)
            conditions.append(
                or_(
                    Product.name.ilike(pattern, escape=LIKE_ESCAPE_CHAR),
                    Product.brand.ilike(pattern, escape=LIKE_ESCAPE_CHAR),
                )
            )
        if filters.condition_id is not None:
            # Produk "cocok untuk kondisi X" = mengandung bahan aktif yang direkomendasikan untuk X.
            recommended_ingredients = select(ConditionIngredient.ingredient_id).where(
                ConditionIngredient.condition_id == filters.condition_id
            )
            matching_products = select(product_ingredients.c.product_id).where(
                product_ingredients.c.ingredient_id.in_(recommended_ingredients)
            )
            conditions.append(Product.id.in_(matching_products))
        return conditions
