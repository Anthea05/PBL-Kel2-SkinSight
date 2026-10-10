"""Impor produk skincare dari file CSV (mis. dataset Female Daily) ke database.

Contoh (jalankan dari folder backend/):
    python scripts/import_products.py --csv data/female_daily.csv
    python scripts/import_products.py --csv data/female_daily.csv --column name="Product Name" --column price=Harga
    python scripts/import_products.py --csv data/female_daily.csv --dry-run

Jalankan `python -m app.db.seed` lebih dulu agar tabel ingredients terisi
(dibutuhkan untuk menautkan teks komposisi produk ke ingredients).

TODO(tim data): header CSV Female Daily yang asli belum diverifikasi. Jika kolom tidak dikenali,
skrip berhenti dan menampilkan daftar header CSV; petakan kolomnya dengan opsi --column.
"""

import argparse
import sys
from pathlib import Path

# Agar `import app` berhasil walaupun skrip dijalankan dari folder lain.
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from app.core.config import get_settings  # noqa: E402
from app.core.logging_config import setup_logging  # noqa: E402
from app.db.session import SessionLocal  # noqa: E402
from app.services.product_import_service import COLUMN_CANDIDATES, ProductImportService  # noqa: E402

MAX_ERRORS_SHOWN = 50


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Impor produk skincare dari file CSV.")
    parser.add_argument("--csv", required=True, type=Path, help="Path file CSV")
    parser.add_argument(
        "--column",
        action="append",
        default=[],
        metavar="FIELD=KOLOM",
        help=f"Petakan field ke nama kolom CSV (boleh diulang). Field: {', '.join(COLUMN_CANDIDATES)}",
    )
    parser.add_argument("--delimiter", default=",", help="Pemisah kolom: ',' (default), ';', atau 'tab'")
    parser.add_argument("--encoding", default="utf-8-sig", help="Encoding file (default utf-8-sig)")
    parser.add_argument("--dry-run", action="store_true", help="Validasi saja, tidak menyimpan ke database")
    return parser.parse_args(argv)


def parse_column_overrides(pairs: list[str]) -> dict[str, str]:
    """Ubah ['name=Product Name', 'price=Harga'] menjadi {'name': 'Product Name', 'price': 'Harga'}."""
    overrides: dict[str, str] = {}
    for pair in pairs:
        field_name, separator, column = pair.partition("=")
        if not separator or not field_name.strip() or not column.strip():
            raise SystemExit(f"Format --column salah: {pair!r}. Gunakan FIELD=NamaKolom")
        overrides[field_name.strip()] = column.strip()
    return overrides


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv)
    setup_logging(get_settings().log_level)

    if not args.csv.is_file():
        print(f"File tidak ditemukan: {args.csv}", file=sys.stderr)
        return 1
    delimiter = "\t" if args.delimiter in {"tab", "\\t"} else args.delimiter
    if len(delimiter) != 1:
        print("Delimiter harus satu karakter.", file=sys.stderr)
        return 1

    with SessionLocal() as db:
        try:
            report = ProductImportService(db).import_csv(
                args.csv,
                column_overrides=parse_column_overrides(args.column),
                dry_run=args.dry_run,
                encoding=args.encoding,
                delimiter=delimiter,
            )
        except (ValueError, UnicodeDecodeError) as exc:
            print(f"Gagal impor: {exc}", file=sys.stderr)
            return 1

    mode = " (dry run, tidak ada yang disimpan)" if args.dry_run else ""
    print(f"Selesai{mode}: {report.created} baru, {report.updated} diperbarui, {report.skipped} dilewati.")
    for error in report.errors[:MAX_ERRORS_SHOWN]:
        print(f"  - {error}")
    if len(report.errors) > MAX_ERRORS_SHOWN:
        print(f"  (+{len(report.errors) - MAX_ERRORS_SHOWN} error lain tidak ditampilkan)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
