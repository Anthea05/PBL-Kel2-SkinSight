"""Konfigurasi logging terpusat (format rapi, level dari env LOG_LEVEL)."""

import logging

LOG_FORMAT = "%(asctime)s | %(levelname)-8s | %(name)s | %(message)s"


def setup_logging(level: str = "INFO") -> None:
    """Atur format & level log untuk seluruh aplikasi."""
    logging.basicConfig(level=level.upper(), format=LOG_FORMAT, force=True)
    # Access log bawaan uvicorn dimatikan karena middleware sudah mencatat setiap request
    # lengkap dengan durasi dan request id.
    logging.getLogger("uvicorn.access").disabled = True
    for noisy_logger in ("httpx", "httpcore", "multipart", "python_multipart", "PIL"):
        logging.getLogger(noisy_logger).setLevel(logging.WARNING)
