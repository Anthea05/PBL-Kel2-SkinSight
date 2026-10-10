"""Validasi foto scan dan penyimpanan opsional.

Kebijakan privasi: secara default foto TIDAK disimpan (SAVE_SCAN_IMAGES=false).
Foto hanya diproses di memori untuk prediksi lalu dibuang; yang disimpan hanya hasil & metadata.
"""

import io
import logging
import uuid
from dataclasses import dataclass

from fastapi import UploadFile
from PIL import Image, UnidentifiedImageError

from app.core.config import get_settings
from app.core.exceptions import PayloadTooLargeError, UnsupportedMediaTypeError, ValidationAppError

logger = logging.getLogger(__name__)

ALLOWED_CONTENT_TYPES = {"image/jpeg", "image/jpg", "image/png"}
FORMAT_EXTENSIONS = {"JPEG": "jpg", "PNG": "png"}
MAX_IMAGE_PIXELS = 25_000_000  # 25 MP; mencegah "decompression bomb" yang menghabiskan memori


@dataclass(frozen=True)
class ValidatedImage:
    data: bytes
    format: str
    extension: str
    width: int
    height: int


def read_upload(upload: UploadFile, max_bytes: int) -> bytes:
    """Baca isi file upload (maks. `max_bytes`) lalu langsung tutup file sementaranya."""
    try:
        data = upload.file.read(max_bytes + 1)
    finally:
        upload.file.close()  # file sementara milik server (jika ada) ikut terhapus
    if len(data) > max_bytes:
        raise PayloadTooLargeError(f"Ukuran gambar maksimal {max_bytes / (1024 * 1024):g} MB.")
    if not data:
        raise ValidationAppError("File gambar kosong.", code="EMPTY_FILE")
    return data


def validate_image(data: bytes, content_type: str | None) -> ValidatedImage:
    """Pastikan file benar-benar gambar JPEG/PNG: cek header Content-Type DAN isi file-nya."""
    if (content_type or "").lower() not in ALLOWED_CONTENT_TYPES:
        raise UnsupportedMediaTypeError(
            "Format file harus JPEG atau PNG (Content-Type image/jpeg atau image/png)."
        )
    try:
        with Image.open(io.BytesIO(data)) as image:
            image_format = image.format or ""
            width, height = image.size
            if image_format not in FORMAT_EXTENSIONS:
                raise UnsupportedMediaTypeError("Isi file bukan gambar JPEG atau PNG.")
            if width * height > MAX_IMAGE_PIXELS:
                raise PayloadTooLargeError("Resolusi gambar terlalu besar.")
            image.verify()  # cek struktur file
        with Image.open(io.BytesIO(data)) as image:
            image.load()  # decode penuh: mendeteksi file terpotong/rusak
    except (UnidentifiedImageError, OSError, SyntaxError, ValueError, Image.DecompressionBombError) as exc:
        raise UnsupportedMediaTypeError("File yang diunggah bukan gambar yang valid.") from exc
    return ValidatedImage(
        data=data,
        format=image_format,
        extension=FORMAT_EXTENSIONS[image_format],
        width=width,
        height=height,
    )


def save_scan_image(image: ValidatedImage, user_id: uuid.UUID, scan_id: uuid.UUID) -> str:
    """Simpan foto ke SCAN_IMAGE_DIR/<user_id>/<scan_id>.<ext>. Hanya dipakai jika SAVE_SCAN_IMAGES=true.

    Return path relatif terhadap SCAN_IMAGE_DIR (yang disimpan di database).
    """
    base_dir = get_settings().scan_image_path
    relative_path = f"{user_id}/{scan_id}.{image.extension}"
    target = base_dir / relative_path
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_bytes(image.data)
    return relative_path


def delete_scan_image(relative_path: str) -> None:
    """Hapus foto scan dari disk (dipanggil saat scan dihapus). Aman jika file sudah tidak ada."""
    base_dir = get_settings().scan_image_path.resolve()
    target = (base_dir / relative_path).resolve()
    if not target.is_relative_to(base_dir):
        logger.warning("Path foto di luar folder penyimpanan, diabaikan: %s", relative_path)
        return
    try:
        target.unlink(missing_ok=True)
        if target.parent != base_dir and not any(target.parent.iterdir()):
            target.parent.rmdir()
    except OSError:
        logger.exception("Gagal menghapus foto scan %s", relative_path)
