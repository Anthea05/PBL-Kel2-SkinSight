"""Akses data tabel scans. Semua query selalu difilter dengan user_id (data milik sendiri saja)."""

import uuid
from datetime import datetime

from sqlalchemy import func, select
from sqlalchemy.orm import Session, joinedload

from app.models.scan import Scan


class ScanRepository:
    def __init__(self, db: Session) -> None:
        self.db = db

    def add(self, scan: Scan) -> Scan:
        self.db.add(scan)
        self.db.flush()
        return scan

    def get_for_user(self, scan_id: uuid.UUID, user_id: uuid.UUID) -> Scan | None:
        stmt = (
            select(Scan)
            .options(joinedload(Scan.condition))
            .where(Scan.id == scan_id, Scan.user_id == user_id)
        )
        return self.db.scalar(stmt)

    def list_for_user(
        self,
        user_id: uuid.UUID,
        *,
        offset: int,
        limit: int,
        start: datetime | None = None,
        end: datetime | None = None,
        newest_first: bool = True,
    ) -> tuple[list[Scan], int]:
        """Riwayat scan user + total data (untuk paginasi). start/end membatasi analyzed_at."""
        filters = [Scan.user_id == user_id]
        if start is not None:
            filters.append(Scan.analyzed_at >= start)
        if end is not None:
            filters.append(Scan.analyzed_at < end)

        total = self.db.scalar(select(func.count()).select_from(Scan).where(*filters)) or 0
        order_by = (
            (Scan.analyzed_at.desc(), Scan.id.desc()) if newest_first else (Scan.analyzed_at.asc(), Scan.id.asc())
        )
        stmt = (
            select(Scan)
            .options(joinedload(Scan.condition))
            .where(*filters)
            .order_by(*order_by)
            .offset(offset)
            .limit(limit)
        )
        return list(self.db.scalars(stmt).all()), total

    def delete(self, scan: Scan) -> None:
        self.db.delete(scan)
        self.db.flush()
