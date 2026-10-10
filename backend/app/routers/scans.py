"""Endpoint scan kulit, riwayat, dan rekomendasi (dibatasi rate limit)."""

import uuid
from datetime import date
from typing import Annotated

from fastapi import APIRouter, Depends, File, Form, Query, UploadFile

from app.core.constants import BodyArea
from app.core.dependencies import CurrentUser, Pagination, RecommendationServiceDep, ScanServiceDep
from app.core.rate_limit import rate_limit
from app.schemas.common import AUTH_ERROR_RESPONSES, ApiResponse, ErrorResponse, Page, ok
from app.schemas.recommendation import RecommendationOut
from app.schemas.scan import ScanOut

router = APIRouter(
    prefix="/scans",
    tags=["Scans"],
    dependencies=[Depends(rate_limit("scans"))],
    responses={
        **AUTH_ERROR_RESPONSES,
        429: {"model": ErrorResponse, "description": "Terlalu banyak permintaan"},
    },
)

NOT_FOUND_RESPONSE = {404: {"model": ErrorResponse, "description": "Scan tidak ditemukan"}}


@router.post(
    "",
    status_code=201,
    summary="Scan foto kulit (multipart: image + body_area)",
    responses={
        413: {"model": ErrorResponse, "description": "File terlalu besar"},
        415: {"model": ErrorResponse, "description": "Bukan gambar JPEG/PNG"},
        503: {"model": ErrorResponse, "description": "Service ML tidak tersedia"},
    },
)
def create_scan(
    current_user: CurrentUser,
    service: ScanServiceDep,
    image: Annotated[UploadFile, File(description="Foto kulit JPEG/PNG")],
    body_area: Annotated[BodyArea, Form(description="Area tubuh: wajah, tangan, punggung, kaki")],
) -> ApiResponse[ScanOut]:
    return ok(service.create_scan(current_user, image, body_area), "Analisis kulit berhasil.")


@router.get("", summary="Riwayat scan saya (paginasi)")
def list_scans(
    current_user: CurrentUser,
    service: ScanServiceDep,
    pagination: Pagination,
    on_date: Annotated[
        date | None, Query(alias="date", description="Filter satu tanggal (YYYY-MM-DD), zona waktu APP_TIMEZONE")
    ] = None,
    newest_first: Annotated[bool, Query(description="true = terbaru dulu, false = terlama dulu")] = True,
) -> ApiResponse[Page[ScanOut]]:
    return ok(
        service.list_scans(
            current_user,
            page=pagination.page,
            page_size=pagination.page_size,
            on_date=on_date,
            newest_first=newest_first,
        )
    )


@router.get("/{scan_id}", summary="Detail satu scan", responses=NOT_FOUND_RESPONSE)
def get_scan(scan_id: uuid.UUID, current_user: CurrentUser, service: ScanServiceDep) -> ApiResponse[ScanOut]:
    return ok(service.get_scan(current_user, scan_id))


@router.delete("/{scan_id}", summary="Hapus data scan (beserta foto jika tersimpan)", responses=NOT_FOUND_RESPONSE)
def delete_scan(scan_id: uuid.UUID, current_user: CurrentUser, service: ScanServiceDep) -> ApiResponse[None]:
    service.delete_scan(current_user, scan_id)
    return ok(message="Data scan berhasil dihapus.")


@router.get(
    "/{scan_id}/recommendations",
    summary="Rekomendasi bahan aktif + produk (mengecualikan alergi dari kuis)",
    responses=NOT_FOUND_RESPONSE,
)
def get_recommendations(
    scan_id: uuid.UUID,
    current_user: CurrentUser,
    service: RecommendationServiceDep,
    min_price: Annotated[int | None, Query(ge=0, description="Harga produk minimum (Rupiah)")] = None,
    max_price: Annotated[int | None, Query(ge=0, description="Harga produk maksimum (Rupiah)")] = None,
    limit: Annotated[int, Query(ge=1, le=50, description="Jumlah produk maksimum")] = 10,
) -> ApiResponse[RecommendationOut]:
    return ok(
        service.get_for_scan(current_user, scan_id, min_price=min_price, max_price=max_price, limit=limit),
        "Rekomendasi berhasil dimuat.",
    )
