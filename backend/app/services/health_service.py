"""Health check: status database dan service ML."""

import logging

from sqlalchemy import text
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.schemas.health import HealthOut, MLStatusOut
from app.services.ml_service import MLService

logger = logging.getLogger(__name__)


class HealthService:
    def __init__(self, db: Session, ml_service: MLService) -> None:
        self.db = db
        self.ml = ml_service

    def check(self) -> HealthOut:
        try:
            self.db.execute(text("SELECT 1"))
            database = "ok"
        except SQLAlchemyError:
            logger.exception("Health check: database tidak bisa diakses")
            database = "error"

        ml_status = MLStatusOut(**self.ml.status())
        return HealthOut(
            status="ok" if database == "ok" and ml_status.ready else "degraded",
            version=get_settings().app_version,
            database=database,
            ml=ml_status,
        )
