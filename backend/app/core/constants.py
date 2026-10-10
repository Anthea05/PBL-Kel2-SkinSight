"""Konstanta yang dipakai lintas modul."""

from typing import Literal

# Area tubuh yang bisa di-scan (sesuai fitur "Smart Skin Scan" di README proyek).
BodyArea = Literal["wajah", "tangan", "punggung", "kaki"]

# Jenis artikel edukasi.
ArticleType = Literal["tip", "nutrition"]

# Disclaimer wajib pada setiap respons hasil scan dan rekomendasi.
MEDICAL_DISCLAIMER = (
    "Hasil analisis SkinSight bukan diagnosis medis dan tidak menggantikan pemeriksaan "
    "oleh dokter spesialis kulit (dermatolog). Segera konsultasikan ke tenaga medis jika "
    "keluhan berlanjut, terasa nyeri, atau memburuk."
)
