# syntax=docker/dockerfile:1

# Étape 1 : installer les dépendances dans un environnement virtuel
FROM python:3.15-slim@sha256:65a65fc7b30b06cb6df4930fd4650697cb23f4c2698ab81fc87e4b031bc36928 AS builder
ENV PIP_NO_CACHE_DIR=1 PIP_DISABLE_PIP_VERSION_CHECK=1
RUN python -m venv /opt/venv
ENV PATH=/opt/venv/bin:$PATH
WORKDIR /build
# Dépendances d'abord : cette couche reste en cache tant que pyproject.toml ne change pas
COPY pyproject.toml ./
RUN mkdir app && touch app/__init__.py && pip install .
# Code ensuite : seule cette partie est rejouée quand le code change
COPY app/ ./app/
RUN pip install --no-deps --force-reinstall .

# Étape 2 : image finale, sans outils de construction
FROM python:3.15-slim@sha256:65a65fc7b30b06cb6df4930fd4650697cb23f4c2698ab81fc87e4b031bc36928
ENV PATH=/opt/venv/bin:$PATH PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
RUN useradd --uid 10001 --no-create-home --shell /usr/sbin/nologin app \
    && install -d -o 10001 -g 10001 /app
WORKDIR /app
COPY --from=builder /opt/venv /opt/venv
COPY app/ ./app/
USER 10001
EXPOSE 8000
HEALTHCHECK --interval=10s --timeout=3s --retries=3 \
    CMD ["python", "-c", "import urllib.request, sys; sys.exit(0 if urllib.request.urlopen('http://127.0.0.1:8000/health', timeout=2).status == 200 else 1)"]
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
