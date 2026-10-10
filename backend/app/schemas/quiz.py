"""Skema kuis kondisi kulit & gaya hidup.

Lima pertanyaan pertama mengikuti skin_quiz_page.dart (jawaban di Flutter berupa indeks 0-3,
di API dikirim sebagai kode di bawah dengan urutan yang sama):
1. skin_feel        : Berminyak di T-Zone | Mengilap di seluruh wajah | Kering dan ketarik | Lembap pas
2. sensitivity      : Hampir tidak pernah | Kadang-kadang | Cukup sering | Sangat sering
3. pore_visibility  : Hampir tidak terlihat | Terlihat di hidung | Terlihat di T-Zone | Terlihat di banyak area
4. main_concern     : Jerawat dan komedo | Kusam dan tidak merata | Kering dan dehidrasi | Garis halus
5. outdoor_exposure : Kurang dari 30 menit | 30 menit-1 jam | 1-3 jam | Lebih dari 3 jam
"""

import uuid
from datetime import datetime
from typing import Annotated, Literal

from pydantic import BaseModel, ConfigDict, Field, StringConstraints, field_validator

from app.schemas.common import ORMModel

SkinFeel = Literal["oily_t_zone", "oily_all_over", "dry_tight", "balanced"]
Sensitivity = Literal["rarely", "sometimes", "often", "very_often"]
PoreVisibility = Literal["barely_visible", "visible_nose", "visible_t_zone", "visible_many_areas"]
MainConcern = Literal["acne_blackheads", "dull_uneven", "dry_dehydrated", "fine_lines"]
OutdoorExposure = Literal["lt_30_min", "30_to_60_min", "1_to_3_hours", "gt_3_hours"]

ShortText = Annotated[str, StringConstraints(strip_whitespace=True, min_length=2, max_length=100)]


def _unique(values: list[str]) -> list[str]:
    return list(dict.fromkeys(values))


class QuizCreate(BaseModel):
    model_config = ConfigDict(
        extra="forbid",
        json_schema_extra={
            "example": {
                "skin_feel": "oily_t_zone",
                "sensitivity": "sometimes",
                "pore_visibility": "visible_t_zone",
                "main_concern": "acne_blackheads",
                "outdoor_exposure": "1_to_3_hours",
                "allergies": ["fragrance", "alcohol denat"],
                "diet_pattern": "Sering makan gorengan dan minuman manis",
                "habits": ["tidur kurang dari 6 jam", "jarang minum air putih"],
            }
        },
    )

    skin_feel: SkinFeel
    sensitivity: Sensitivity
    pore_visibility: PoreVisibility
    main_concern: MainConcern
    outdoor_exposure: OutdoorExposure
    allergies: list[ShortText] = Field(
        default_factory=list,
        max_length=20,
        description="Nama bahan yang membuat alergi/iritasi, mis. 'fragrance', 'niacinamide'",
    )
    diet_pattern: Annotated[str, StringConstraints(strip_whitespace=True, max_length=500)] | None = None
    habits: list[ShortText] = Field(default_factory=list, max_length=20)

    @field_validator("allergies")
    @classmethod
    def _normalize_allergies(cls, values: list[str]) -> list[str]:
        return _unique([value.lower() for value in values])

    @field_validator("habits")
    @classmethod
    def _normalize_habits(cls, values: list[str]) -> list[str]:
        return _unique(values)


class QuizOut(ORMModel):
    id: uuid.UUID
    skin_feel: str
    sensitivity: str
    pore_visibility: str
    main_concern: str
    outdoor_exposure: str
    allergies: list[str]
    diet_pattern: str | None
    habits: list[str]
    created_at: datetime
