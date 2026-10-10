"""Skema awal SkinSight

Revision ID: 0001
Revises:
Create Date: 2026-10-10

Tabel: users, skin_conditions, ingredients, products, condition_ingredients,
product_ingredients, quiz_responses, scans, education_articles.
"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = "0001"
down_revision: Union[str, Sequence[str], None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def _timestamps() -> list[sa.Column]:
    return [
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    ]


def upgrade() -> None:
    """Upgrade schema."""
    op.create_table(
        "users",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("name", sa.String(length=100), nullable=False),
        sa.Column("email", sa.String(length=255), nullable=False),
        sa.Column("phone", sa.String(length=20), nullable=True),
        sa.Column("password_hash", sa.String(length=255), nullable=False),
        sa.Column("is_active", sa.Boolean(), server_default=sa.true(), nullable=False),
        *_timestamps(),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_users")),
    )
    op.create_index(op.f("ix_users_email"), "users", ["email"], unique=True)

    op.create_table(
        "skin_conditions",
        sa.Column("id", sa.Integer(), nullable=False),
        sa.Column("code", sa.String(length=50), nullable=False),
        sa.Column("name", sa.String(length=100), nullable=False),
        sa.Column("description", sa.Text(), nullable=False),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_skin_conditions")),
    )
    op.create_index(op.f("ix_skin_conditions_code"), "skin_conditions", ["code"], unique=True)

    op.create_table(
        "ingredients",
        sa.Column("id", sa.Integer(), nullable=False),
        sa.Column("name", sa.String(length=150), nullable=False),
        sa.Column("slug", sa.String(length=150), nullable=False),
        sa.Column("aliases", postgresql.JSONB(astext_type=sa.Text()), nullable=False),
        sa.Column("description", sa.Text(), nullable=False),
        sa.Column("caution", sa.Text(), nullable=True),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_ingredients")),
        sa.UniqueConstraint("name", name=op.f("uq_ingredients_name")),
    )
    op.create_index(op.f("ix_ingredients_slug"), "ingredients", ["slug"], unique=True)

    op.create_table(
        "products",
        sa.Column("id", sa.Integer(), nullable=False),
        sa.Column("name", sa.String(length=255), nullable=False),
        sa.Column("brand", sa.String(length=150), nullable=False),
        sa.Column("category", sa.String(length=100), nullable=False),
        sa.Column("price", sa.Integer(), nullable=False),
        sa.Column("description", sa.Text(), nullable=True),
        sa.Column("image_url", sa.String(length=500), nullable=True),
        sa.Column("ingredients_text", sa.Text(), nullable=True),
        *_timestamps(),
        sa.CheckConstraint("price >= 0", name=op.f("ck_products_price_non_negative")),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_products")),
        sa.UniqueConstraint("brand", "name", name="uq_products_brand_name"),
    )
    op.create_index("ix_products_price", "products", ["price"], unique=False)
    op.create_index("ix_products_category_price", "products", ["category", "price"], unique=False)

    op.create_table(
        "condition_ingredients",
        sa.Column("condition_id", sa.Integer(), nullable=False),
        sa.Column("ingredient_id", sa.Integer(), nullable=False),
        sa.Column("priority", sa.Integer(), nullable=False),
        sa.Column("note", sa.Text(), nullable=True),
        sa.ForeignKeyConstraint(
            ["condition_id"],
            ["skin_conditions.id"],
            name=op.f("fk_condition_ingredients_condition_id_skin_conditions"),
            ondelete="CASCADE",
        ),
        sa.ForeignKeyConstraint(
            ["ingredient_id"],
            ["ingredients.id"],
            name=op.f("fk_condition_ingredients_ingredient_id_ingredients"),
            ondelete="CASCADE",
        ),
        sa.PrimaryKeyConstraint("condition_id", "ingredient_id", name=op.f("pk_condition_ingredients")),
    )
    op.create_index(
        op.f("ix_condition_ingredients_ingredient_id"), "condition_ingredients", ["ingredient_id"], unique=False
    )

    op.create_table(
        "product_ingredients",
        sa.Column("product_id", sa.Integer(), nullable=False),
        sa.Column("ingredient_id", sa.Integer(), nullable=False),
        sa.ForeignKeyConstraint(
            ["ingredient_id"],
            ["ingredients.id"],
            name=op.f("fk_product_ingredients_ingredient_id_ingredients"),
            ondelete="CASCADE",
        ),
        sa.ForeignKeyConstraint(
            ["product_id"],
            ["products.id"],
            name=op.f("fk_product_ingredients_product_id_products"),
            ondelete="CASCADE",
        ),
        sa.PrimaryKeyConstraint("product_id", "ingredient_id", name=op.f("pk_product_ingredients")),
    )
    op.create_index(
        "ix_product_ingredients_ingredient_id", "product_ingredients", ["ingredient_id"], unique=False
    )

    op.create_table(
        "quiz_responses",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("user_id", sa.Uuid(), nullable=False),
        sa.Column("skin_feel", sa.String(length=30), nullable=False),
        sa.Column("sensitivity", sa.String(length=30), nullable=False),
        sa.Column("pore_visibility", sa.String(length=30), nullable=False),
        sa.Column("main_concern", sa.String(length=30), nullable=False),
        sa.Column("outdoor_exposure", sa.String(length=30), nullable=False),
        sa.Column("allergies", postgresql.JSONB(astext_type=sa.Text()), nullable=False),
        sa.Column("diet_pattern", sa.String(length=500), nullable=True),
        sa.Column("habits", postgresql.JSONB(astext_type=sa.Text()), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.ForeignKeyConstraint(
            ["user_id"], ["users.id"], name=op.f("fk_quiz_responses_user_id_users"), ondelete="CASCADE"
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_quiz_responses")),
    )
    op.create_index(
        "ix_quiz_responses_user_id_created_at", "quiz_responses", ["user_id", "created_at"], unique=False
    )

    op.create_table(
        "scans",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("user_id", sa.Uuid(), nullable=False),
        sa.Column("condition_id", sa.Integer(), nullable=True),
        sa.Column("body_area", sa.String(length=20), nullable=False),
        sa.Column("label", sa.String(length=50), nullable=False),
        sa.Column("confidence", sa.Double(), nullable=False),
        sa.Column("predictions", postgresql.JSONB(astext_type=sa.Text()), nullable=False),
        sa.Column("model_version", sa.String(length=100), nullable=True),
        sa.Column("image_path", sa.String(length=500), nullable=True),
        sa.Column("analyzed_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.CheckConstraint("confidence >= 0 AND confidence <= 1", name=op.f("ck_scans_confidence_range")),
        sa.ForeignKeyConstraint(
            ["condition_id"],
            ["skin_conditions.id"],
            name=op.f("fk_scans_condition_id_skin_conditions"),
            ondelete="SET NULL",
        ),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], name=op.f("fk_scans_user_id_users"), ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_scans")),
    )
    op.create_index("ix_scans_user_id_analyzed_at", "scans", ["user_id", "analyzed_at"], unique=False)

    op.create_table(
        "education_articles",
        sa.Column("id", sa.Integer(), nullable=False),
        sa.Column("article_type", sa.String(length=20), nullable=False),
        sa.Column("title", sa.String(length=200), nullable=False),
        sa.Column("summary", sa.String(length=300), nullable=False),
        sa.Column("content", sa.Text(), nullable=False),
        sa.Column("condition_id", sa.Integer(), nullable=True),
        *_timestamps(),
        sa.ForeignKeyConstraint(
            ["condition_id"],
            ["skin_conditions.id"],
            name=op.f("fk_education_articles_condition_id_skin_conditions"),
            ondelete="CASCADE",
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_education_articles")),
        sa.UniqueConstraint("article_type", "title", name="uq_education_articles_type_title"),
    )
    op.create_index(
        "ix_education_articles_type_condition_id",
        "education_articles",
        ["article_type", "condition_id"],
        unique=False,
    )


def downgrade() -> None:
    """Downgrade schema."""
    op.drop_index("ix_education_articles_type_condition_id", table_name="education_articles")
    op.drop_table("education_articles")
    op.drop_index("ix_scans_user_id_analyzed_at", table_name="scans")
    op.drop_table("scans")
    op.drop_index("ix_quiz_responses_user_id_created_at", table_name="quiz_responses")
    op.drop_table("quiz_responses")
    op.drop_index("ix_product_ingredients_ingredient_id", table_name="product_ingredients")
    op.drop_table("product_ingredients")
    op.drop_index(op.f("ix_condition_ingredients_ingredient_id"), table_name="condition_ingredients")
    op.drop_table("condition_ingredients")
    op.drop_index("ix_products_category_price", table_name="products")
    op.drop_index("ix_products_price", table_name="products")
    op.drop_table("products")
    op.drop_index(op.f("ix_ingredients_slug"), table_name="ingredients")
    op.drop_table("ingredients")
    op.drop_index(op.f("ix_skin_conditions_code"), table_name="skin_conditions")
    op.drop_table("skin_conditions")
    op.drop_index(op.f("ix_users_email"), table_name="users")
    op.drop_table("users")
