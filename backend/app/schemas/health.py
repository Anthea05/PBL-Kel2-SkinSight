"""Skema health check."""

from typing import Literal

from pydantic import BaseModel


class MLStatusOut(BaseModel):
    mode: str
    ready: bool
    version: str | None


class HealthOut(BaseModel):
    status: Literal["ok", "degraded"]
    version: str
    database: Literal["ok", "error"]
    ml: MLStatusOut
