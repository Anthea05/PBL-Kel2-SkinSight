"""Skema hasil scan kulit.

Nama field mengikuti model Dart SkinAnalysis (id, analyzedAt, title, skinType) dalam snake_case,
ditambah label/confidence/predictions dari model ML.
"""

import uuid
from datetime import datetime

from pydantic import BaseModel, Field


class PredictionOut(BaseModel):
    label: str
    confidence: float = Field(ge=0, le=1)


class ScanOut(BaseModel):
    id: uuid.UUID
    body_area: str
    label: str = Field(description="Label kelas teratas dari model ML, mis. 'oily'")
    confidence: float = Field(ge=0, le=1, description="Tingkat keyakinan model (0-1) untuk label teratas")
    title: str = Field(description="Judul hasil untuk ditampilkan (SkinAnalysis.title)")
    skin_type: str = Field(description="Jenis kulit untuk ditampilkan (SkinAnalysis.skinType)")
    predictions: list[PredictionOut] = Field(description="Semua kelas, urut dari confidence tertinggi")
    model_version: str | None
    image_stored: bool = Field(description="True hanya jika server dikonfigurasi SAVE_SCAN_IMAGES=true")
    analyzed_at: datetime
    disclaimer: str
