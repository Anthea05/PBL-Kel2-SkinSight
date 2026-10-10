"""Logika bisnis katalog produk."""

from sqlalchemy.orm import Session

from app.core.exceptions import NotFoundError
from app.repositories.product_repository import ProductFilter, ProductRepository
from app.repositories.skin_condition_repository import SkinConditionRepository
from app.schemas.common import Page
from app.schemas.product import ProductDetailOut, ProductOut, ProductQuery


def normalize_category(value: str) -> str:
    """Kategori disimpan & dicari dalam huruf kecil dengan spasi tunggal, mis. 'Facial Wash' -> 'facial wash'."""
    return " ".join(value.lower().split())


class ProductService:
    def __init__(self, db: Session) -> None:
        self.products = ProductRepository(db)
        self.conditions = SkinConditionRepository(db)

    def list_products(self, query: ProductQuery) -> Page[ProductOut]:
        """Katalog dengan filter harga/kategori/kondisi/pencarian + paginasi."""
        condition_id = None
        if query.concern:
            condition = self.conditions.get_by_code(query.concern.lower())
            if condition is None:
                raise NotFoundError(f"Kondisi kulit '{query.concern}' tidak ditemukan.", code="CONDITION_NOT_FOUND")
            condition_id = condition.id

        filters = ProductFilter(
            min_price=query.min_price,
            max_price=query.max_price,
            category=normalize_category(query.category) if query.category else None,
            condition_id=condition_id,
            q=query.q,
            sort=query.sort,
        )
        items, total = self.products.search(
            filters, offset=(query.page - 1) * query.page_size, limit=query.page_size
        )
        return Page.create(
            [ProductOut.model_validate(item) for item in items],
            page=query.page,
            page_size=query.page_size,
            total=total,
        )

    def get_product(self, product_id: int) -> ProductDetailOut:
        product = self.products.get_by_id(product_id)
        if product is None:
            raise NotFoundError("Produk tidak ditemukan.", code="PRODUCT_NOT_FOUND")
        return ProductDetailOut.model_validate(product)
