"""Rate limiter sederhana (fixed window, disimpan di memori).

Cukup untuk satu proses/instance. Jika API dijalankan dengan banyak worker atau
banyak instance, pindahkan penyimpanan hitungan ke Redis agar dibagi bersama.
"""

import math
import threading
import time
from collections.abc import Callable
from typing import Literal

from fastapi import Request

from app.core.config import get_settings
from app.core.exceptions import RateLimitError

RateLimitScope = Literal["auth", "scans"]

_MAX_TRACKED_KEYS = 10_000


class InMemoryRateLimiter:
    """Menghitung jumlah request per kunci (scope + IP) dalam jendela waktu tetap."""

    def __init__(self) -> None:
        # key -> (waktu mulai jendela, jumlah request, panjang jendela)
        self._windows: dict[str, tuple[float, int, int]] = {}
        self._lock = threading.Lock()

    def hit(self, key: str, limit: int, window_seconds: int) -> float | None:
        """Catat satu request. Return None jika masih boleh, atau sisa detik tunggu jika melebihi batas."""
        now = time.monotonic()
        with self._lock:
            started, count, _ = self._windows.get(key, (now, 0, window_seconds))
            if now - started >= window_seconds:
                started, count = now, 0
            count += 1
            self._windows[key] = (started, count, window_seconds)
            if len(self._windows) > _MAX_TRACKED_KEYS:
                self._remove_expired(now)
            if count > limit:
                return window_seconds - (now - started)
        return None

    def reset(self) -> None:
        """Hapus semua hitungan (dipakai di test)."""
        with self._lock:
            self._windows.clear()

    def _remove_expired(self, now: float) -> None:
        expired = [key for key, (started, _, window) in self._windows.items() if now - started >= window]
        for key in expired:
            del self._windows[key]


limiter = InMemoryRateLimiter()


def rate_limit(scope: RateLimitScope) -> Callable[[Request], None]:
    """Buat dependency FastAPI yang membatasi jumlah request per IP untuk satu kelompok endpoint."""

    def dependency(request: Request) -> None:
        settings = get_settings()
        if not settings.rate_limit_enabled:
            return
        if scope == "auth":
            limit, window = settings.rate_limit_auth_requests, settings.rate_limit_auth_window_seconds
        else:
            limit, window = settings.rate_limit_scans_requests, settings.rate_limit_scans_window_seconds

        client_ip = request.client.host if request.client else "unknown"
        retry_after = limiter.hit(f"{scope}:{client_ip}", limit, window)
        if retry_after is not None:
            seconds = max(1, math.ceil(retry_after))
            raise RateLimitError(
                f"Terlalu banyak permintaan. Coba lagi dalam {seconds} detik.",
                headers={"Retry-After": str(seconds)},
            )

    return dependency
