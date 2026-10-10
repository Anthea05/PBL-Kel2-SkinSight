"""Impor produk dari file CSV (dataset Female Daily atau data contoh) ke tabel products.

- Upsert berdasarkan (brand, name): aman dijalankan berulang (idempotent).
- Kolom CSV dikenali otomatis dari beberapa nama umum (COLUMN_CANDIDATES) atau dipaksa lewat
  `column_overrides`, mis. {"name": "Nama Produk", "price": "Harga"}.
- Teks komposisi dicocokkan ke tabel ingredients untuk mengisi product_ingredients.

TODO(tim data): nama kolom dataset Female Daily yang asli BELUM diverifikasi karena file dataset
tidak ada di repo. Cek header CSV-nya, lalu sesuaikan COLUMN_CANDIDATES atau pakai opsi --column.
"""

import csv
import logging
import re
from dataclasses import dataclass, field
from pathlib import Path

from sqlalchemy.orm import Session

from app.models.ingredient import Ingredient
from app.models.product import Product
from app.repositories.ingredient_repository import IngredientRepository
from app.repositories.product_repository import ProductRepository
from app.services.ingredient_matcher import find_ingredients_in_text
from app.services.product_service import normalize_category

logger = logging.getLogger(__name__)

COLUMN_CANDIDATES: dict[str, list[str]] = {
    "name": ["name", "product_name", "nama_produk", "nama produk", "product"],
    "brand": ["brand", "brand_name", "merek", "merk"],
    "category": ["category", "kategori", "product_category", "type"],
    "price": ["price", "harga", "price_idr"],
    "description": ["description", "deskripsi", "desc"],
    "image_url": ["image_url", "image", "img_url", "gambar"],
    "ingredients": ["ingredients", "komposisi", "bahan", "ingredient"],
}
REQUIRED_FIELDS = ("name", "brand", "category", "price")
MAX_LENGTHS = {"name": 255, "brand": 150, "category": 100, "image_url": 500}
_NUMBER_PATTERN = re.compile(r"\d[\d.,]*")


class RowError(ValueError):
    """Satu baris CSV tidak valid (dilewati, impor tetap berjalan)."""


@dataclass
class ImportReport:
    created: int = 0
    updated: int = 0
    skipped: int = 0
    errors: list[str] = field(default_factory=list)


def parse_price(raw: str) -> int | None:
    """Ubah teks harga menjadi integer Rupiah.

    'Rp 125.000' -> 125000, '89,900' -> 89900, '125000.00' -> 125000, '125.000,50' -> 125000,
    'Rp 50.000 - Rp 75.000' -> 50000 (diambil harga pertama/terendah).
    """
    match = _NUMBER_PATTERN.search(raw or "")
    if not match:
        return None
    number = match.group().rstrip(".,")
    if "." in number and "," in number:
        decimal_separator = "," if number.rfind(",") > number.rfind(".") else "."
        thousands_separator = "." if decimal_separator == "," else ","
        integer_part = number.split(decimal_separator)[0].replace(thousands_separator, "")
    elif "." in number or "," in number:
        separator = "." if "." in number else ","
        parts = number.split(separator)
        is_thousands = all(len(part) == 3 for part in parts[1:])
        integer_part = "".join(parts) if is_thousands else parts[0]
    else:
        integer_part = number
    return int(integer_part) if integer_part.isdigit() else None


def resolve_columns(headers: list[str], overrides: dict[str, str] | None = None) -> dict[str, str | None]:
    """Petakan field internal -> nama kolom di CSV. Gagal jika kolom wajib tidak ditemukan."""
    overrides = overrides or {}
    unknown = sorted(set(overrides) - set(COLUMN_CANDIDATES))
    if unknown:
        raise ValueError(f"Field tidak dikenal di --column: {', '.join(unknown)}")

    by_lowercase = {header.strip().lower(): header for header in headers}
    mapping: dict[str, str | None] = {}
    for field_name, candidates in COLUMN_CANDIDATES.items():
        if field_name in overrides:
            column = overrides[field_name]
            if column not in headers:
                raise ValueError(f"Kolom '{column}' (untuk {field_name}) tidak ada di CSV.")
            mapping[field_name] = column
        else:
            mapping[field_name] = next((by_lowercase[name] for name in candidates if name in by_lowercase), None)

    missing = [field_name for field_name in REQUIRED_FIELDS if mapping[field_name] is None]
    if missing:
        raise ValueError(
            f"Kolom wajib tidak ditemukan: {', '.join(missing)}. Header CSV: {headers}. "
            "Gunakan --column field=NamaKolom."
        )
    return mapping


class ProductImportService:
    def __init__(self, db: Session) -> None:
        self.db = db
        self.products = ProductRepository(db)
        self.ingredients = IngredientRepository(db)

    def import_csv(
        self,
        csv_path: Path,
        *,
        column_overrides: dict[str, str] | None = None,
        dry_run: bool = False,
        encoding: str = "utf-8-sig",
        delimiter: str = ",",
    ) -> ImportReport:
        """Impor/perbarui produk dari CSV. dry_run=True hanya memvalidasi tanpa menyimpan."""
        report = ImportReport()
        known_ingredients = self.ingredients.list_all()
        with csv_path.open(newline="", encoding=encoding) as handle:
            reader = csv.DictReader(handle, delimiter=delimiter)
            mapping = resolve_columns(list(reader.fieldnames or []), column_overrides)
            for line_number, row in enumerate(reader, start=2):
                try:
                    created = self._upsert_row(row, mapping, known_ingredients)
                except RowError as exc:
                    report.skipped += 1
                    report.errors.append(f"Baris {line_number}: {exc}")
                    continue
                if created:
                    report.created += 1
                else:
                    report.updated += 1

        if dry_run:
            self.db.rollback()
        else:
            self.db.commit()
        logger.info(
            "Impor %s selesai: %d baru, %d diperbarui, %d dilewati%s",
            csv_path.name,
            report.created,
            report.updated,
            report.skipped,
            " (dry run)" if dry_run else "",
        )
        return report

    def _upsert_row(
        self, row: dict[str, str | None], mapping: dict[str, str | None], known_ingredients: list[Ingredient]
    ) -> bool:
        """Simpan satu baris. Return True jika produk baru, False jika memperbarui produk lama."""
        values = {field_name: _clean(row.get(column)) if column else "" for field_name, column in mapping.items()}
        for field_name in ("name", "brand", "category"):
            if not values[field_name]:
                raise RowError(f"kolom {field_name} kosong")
        for field_name, max_length in MAX_LENGTHS.items():
            if len(values[field_name]) > max_length:
                raise RowError(f"kolom {field_name} lebih dari {max_length} karakter")
        price = parse_price(values["price"])
        if price is None or price <= 0:
            raise RowError(f"harga tidak valid: {values['price']!r}")

        product = self.products.get_by_brand_and_name(values["brand"], values["name"])
        created = product is None
        if product is None:
            product = Product(name=values["name"], brand=values["brand"])

        product.category = normalize_category(values["category"])
        product.price = price
        product.description = values["description"] or None
        product.image_url = values["image_url"] if values["image_url"].startswith(("http://", "https://")) else None
        product.ingredients_text = values["ingredients"] or None
        product.ingredients = (
            find_ingredients_in_text(values["ingredients"], known_ingredients) if values["ingredients"] else []
        )
        if created:
            self.products.add(product)
        return created


def _clean(value: str | None) -> str:
    """Rapikan spasi berlebih."""
    return " ".join((value or "").split())
