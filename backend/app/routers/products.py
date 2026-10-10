"""Endpoint katalog produk (publik, tanpa login)."""

from typing import Annotated

from fastapi import APIRouter, Path, Query

from app.core.dependencies import ProductServiceDep
from app.schemas.common import ApiResponse, ErrorResponse, Page, ok
from app.schemas.product import ProductDetailOut, ProductOut, ProductQuery

router = APIRouter(prefix="/products", tags=["Products"])


@router.get(
    "",
    summary="Katalog produk (filter harga, kategori, kondisi kulit, pencarian, urutan)",
    responses={404: {"model": ErrorResponse, "description": "Kode kondisi (concern) tidak dikenal"}},
)
def list_products(query: Annotated[ProductQuery, Query()], service: ProductServiceDep) -> ApiResponse[Page[ProductOut]]:
    return ok(service.list_products(query))


@router.get(
    "/{product_id}",
    summary="Detail produk + daftar ingredient",
    responses={404: {"model": ErrorResponse, "description": "Produk tidak ditemukan"}},
)
def get_product(product_id: Annotated[int, Path(ge=1)], service: ProductServiceDep) -> ApiResponse[ProductDetailOut]:
    return ok(service.get_product(product_id))
