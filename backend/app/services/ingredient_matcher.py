"""Pencocokan nama bahan (ingredient) dengan teks bebas.

Dipakai untuk:
1. Mengecualikan bahan & produk yang cocok dengan alergi pengguna (rekomendasi).
2. Menautkan produk hasil impor CSV ke tabel ingredients (dari teks komposisi).

Aturan pencocokan (sengaja konservatif demi keamanan pengguna):
- Teks dinormalisasi: huruf kecil, tanda baca diganti spasi.
- Dicocokkan per KATA/FRASA utuh, bukan potongan huruf:
  alergi "salicylic" cocok dengan "Salicylic Acid", tetapi alergi "ac" TIDAK cocok dengan "acid".
- Alergi yang cocok dengan sebuah ingredient diperluas ke semua aliasnya:
  alergi "fragrance" juga mengecualikan produk yang komposisinya menulis "Parfum".
"""

import re
from collections.abc import Iterable, Sequence
from typing import Protocol, TypeVar

_NON_ALPHANUMERIC = re.compile(r"[^0-9a-z]+")


class IngredientLike(Protocol):
    name: str
    slug: str
    aliases: list[str]


IngredientT = TypeVar("IngredientT", bound=IngredientLike)


def normalize(text: str) -> str:
    """Contoh: 'Alcohol Denat.' -> 'alcohol denat'."""
    return _NON_ALPHANUMERIC.sub(" ", text.lower()).strip()


def contains_phrase(text: str, phrase: str) -> bool:
    """True jika `phrase` muncul sebagai kata/frasa utuh di `text` (keduanya sudah dinormalisasi)."""
    if not phrase:
        return False
    return f" {phrase} " in f" {text} "


def ingredient_terms(ingredient: IngredientLike) -> list[str]:
    """Nama, slug, dan alias ingredient dalam bentuk ternormalisasi (tanpa duplikat)."""
    raw_terms = [ingredient.name, ingredient.slug, *(ingredient.aliases or [])]
    return list(dict.fromkeys(term for term in (normalize(raw) for raw in raw_terms) if term))


def _terms_match_allergy(terms: Iterable[str], allergy: str) -> bool:
    """Cocok dua arah: teks alergi ada di dalam nama bahan, atau nama bahan ada di dalam teks alergi."""
    return any(contains_phrase(term, allergy) or contains_phrase(allergy, term) for term in terms)


def find_ingredients_in_text(text: str, ingredients: Sequence[IngredientT]) -> list[IngredientT]:
    """Ingredient yang nama/aliasnya muncul di teks komposisi produk."""
    text_norm = normalize(text)
    return [
        ingredient
        for ingredient in ingredients
        if any(contains_phrase(text_norm, term) for term in ingredient_terms(ingredient))
    ]


class AllergyMatcher:
    """Mengecek apakah ingredient atau produk mengandung bahan pemicu alergi pengguna."""

    def __init__(self, allergies: Sequence[str], known_ingredients: Sequence[IngredientLike]) -> None:
        self._allergies = [(allergy, normalize(allergy)) for allergy in allergies if normalize(allergy)]
        # Alergi -> semua istilah (nama + alias) dari ingredient yang cocok dengan alergi tersebut.
        self._expanded_terms: dict[str, set[str]] = {}
        for original, normalized in self._allergies:
            terms = {normalized}
            for ingredient in known_ingredients:
                candidate_terms = ingredient_terms(ingredient)
                if _terms_match_allergy(candidate_terms, normalized):
                    terms.update(candidate_terms)
            self._expanded_terms[original] = terms

    def match_ingredient(self, ingredient: IngredientLike) -> str | None:
        """Return teks alergi yang cocok dengan ingredient, atau None."""
        terms = ingredient_terms(ingredient)
        for original, normalized in self._allergies:
            if _terms_match_allergy(terms, normalized):
                return original
        return None

    def match_text(self, text: str | None) -> str | None:
        """Return teks alergi yang disebut di teks komposisi, atau None."""
        if not text:
            return None
        text_norm = normalize(text)
        for original, terms in self._expanded_terms.items():
            if any(contains_phrase(text_norm, term) for term in terms):
                return original
        return None

    def match_product(self, ingredients: Iterable[IngredientLike], ingredients_text: str | None) -> str | None:
        """Produk dikecualikan jika salah satu ingredient-nya ATAU teks komposisinya cocok dengan alergi."""
        for ingredient in ingredients:
            matched = self.match_ingredient(ingredient)
            if matched:
                return matched
        return self.match_text(ingredients_text)
