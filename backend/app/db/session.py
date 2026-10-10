"""Engine & session SQLAlchemy (mode sync, driver psycopg 3)."""

from collections.abc import Iterator

from sqlalchemy import create_engine
from sqlalchemy.orm import Session, sessionmaker

from app.core.config import get_settings

engine = create_engine(
    get_settings().database_url,
    pool_pre_ping=True,
    # Semua timestamp dikembalikan dalam UTC agar konsisten di JSON.
    connect_args={"options": "-c timezone=UTC"},
)

SessionLocal = sessionmaker(bind=engine, autoflush=False, expire_on_commit=False)


def get_db() -> Iterator[Session]:
    """Dependency FastAPI: satu session per request, selalu ditutup di akhir."""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
