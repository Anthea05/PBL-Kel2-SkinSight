# Image API SkinSight (FastAPI + Uvicorn).
# Dengan dependency ML (untuk ML_MODE=local): set INSTALL_ML=true di .env lalu docker compose up --build
FROM python:3.12-slim-bookworm

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

WORKDIR /app

COPY requirements.txt requirements-ml.txt ./
RUN pip install -r requirements.txt

# Dependency ML_MODE=local: Ultralytics + PyTorch CPU (+ library sistem yang dibutuhkan OpenCV).
ARG INSTALL_ML=false
RUN if [ "$INSTALL_ML" = "true" ]; then \
        apt-get update \
        && apt-get install -y --no-install-recommends libgl1 libglib2.0-0 \
        && rm -rf /var/lib/apt/lists/* \
        && pip install --index-url https://download.pytorch.org/whl/cpu torch==2.11.0 torchvision==0.26.0 \
        && pip install -r requirements-ml.txt; \
    fi

COPY . .

# Jalankan sebagai user non-root.
RUN useradd --create-home --uid 1000 skinsight \
    && mkdir -p /app/storage /app/ml_models \
    && chown -R skinsight:skinsight /app
USER skinsight

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8000/api/v1/health', timeout=4)" || exit 1

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
