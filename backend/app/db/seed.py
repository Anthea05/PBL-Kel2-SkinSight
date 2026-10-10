"""Seed data awal dari folder data/ (idempotent: aman dijalankan berulang kali).

Jalankan:  python -m app.db.seed
Urutan  :  kondisi kulit -> ingredients -> mapping kondisi-ingredient -> artikel edukasi -> produk (CSV)
"""

import json
import logging
from typing import Any

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.config import BASE_DIR, get_settings
from app.core.logging_config import setup_logging
from app.db.session import SessionLocal
from app.models.education import EducationArticle
from app.models.ingredient import ConditionIngredient, Ingredient
from app.models.skin_condition import SkinCondition
from app.services.product_import_service import ProductImportService

logger = logging.getLogger(__name__)

DATA_DIR = BASE_DIR / "data"
ARTICLE_TYPES = {"tip", "nutrition"}


def _load_json(filename: str) -> list[dict[str, Any]]:
    with (DATA_DIR / filename).open(encoding="utf-8") as handle:
        return json.load(handle)


def _lookup(items: dict[str, Any], key: str, label: str) -> Any:
    if key not in items:
        raise ValueError(f"{label} '{key}' tidak ditemukan. Periksa file seed di folder data/.")
    return items[key]


def seed_skin_conditions(db: Session) -> int:
    rows = _load_json("skin_conditions.json")
    for row in rows:
        condition = db.scalar(select(SkinCondition).where(SkinCondition.code == row["code"]))
        if condition is None:
            condition = SkinCondition(code=row["code"])
            db.add(condition)
        condition.name = row["name"]
        condition.description = row["description"]
    db.flush()
    return len(rows)


def seed_ingredients(db: Session) -> int:
    rows = _load_json("ingredients.json")
    for row in rows:
        ingredient = db.scalar(select(Ingredient).where(Ingredient.slug == row["slug"]))
        if ingredient is None:
            ingredient = Ingredient(slug=row["slug"])
            db.add(ingredient)
        ingredient.name = row["name"]
        ingredient.aliases = row.get("aliases", [])
        ingredient.description = row["description"]
        ingredient.caution = row.get("caution")
    db.flush()
    return len(rows)


def seed_condition_ingredients(db: Session) -> int:
    rows = _load_json("condition_ingredients.json")
    conditions = {condition.code: condition for condition in db.scalars(select(SkinCondition))}
    ingredients = {ingredient.slug: ingredient for ingredient in db.scalars(select(Ingredient))}
    for row in rows:
        condition = _lookup(conditions, row["condition"], "Kondisi")
        ingredient = _lookup(ingredients, row["ingredient"], "Ingredient")
        link = db.get(ConditionIngredient, (condition.id, ingredient.id))
        if link is None:
            link = ConditionIngredient(condition_id=condition.id, ingredient_id=ingredient.id)
            db.add(link)
        link.priority = row["priority"]
        link.note = row.get("note")
    db.flush()
    return len(rows)


def seed_education_articles(db: Session) -> int:
    rows = _load_json("education_articles.json")
    conditions = {condition.code: condition for condition in db.scalars(select(SkinCondition))}
    for row in rows:
        if row["type"] not in ARTICLE_TYPES:
            raise ValueError(f"Jenis artikel '{row['type']}' tidak valid (harus tip atau nutrition).")
        article = db.scalar(
            select(EducationArticle).where(
                EducationArticle.article_type == row["type"], EducationArticle.title == row["title"]
            )
        )
        if article is None:
            article = EducationArticle(article_type=row["type"], title=row["title"])
            db.add(article)
        article.summary = row["summary"]
        article.content = row["content"]
        article.condition = _lookup(conditions, row["condition"], "Kondisi") if row.get("condition") else None
    db.flush()
    return len(rows)


def seed_all(db: Session) -> dict[str, int]:
    """Isi semua data referensi + produk contoh. Return jumlah baris per tabel."""
    summary = {
        "skin_conditions": seed_skin_conditions(db),
        "ingredients": seed_ingredients(db),
        "condition_ingredients": seed_condition_ingredients(db),
        "education_articles": seed_education_articles(db),
    }
    db.commit()

    report = ProductImportService(db).import_csv(DATA_DIR / "products.csv")
    for error in report.errors:
        logger.warning("Seed produk: %s", error)
    summary["products"] = report.created + report.updated
    return summary


def main() -> None:
    setup_logging(get_settings().log_level)
    with SessionLocal() as db:
        summary = seed_all(db)
    for table, count in summary.items():
        logger.info("Seed %-22s : %d baris", table, count)


if __name__ == "__main__":
    main()
