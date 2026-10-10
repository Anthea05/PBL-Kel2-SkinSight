"""Helper query bersama."""

LIKE_ESCAPE_CHAR = "\\"


def like_contains(value: str) -> str:
    """Pola ILIKE '%value%' dengan karakter wildcard (% dan _) di-escape agar dicari apa adanya."""
    escaped = (
        value.replace(LIKE_ESCAPE_CHAR, LIKE_ESCAPE_CHAR * 2)
        .replace("%", f"{LIKE_ESCAPE_CHAR}%")
        .replace("_", f"{LIKE_ESCAPE_CHAR}_")
    )
    return f"%{escaped}%"
