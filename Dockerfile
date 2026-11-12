# syntax=docker/dockerfile:1

# Étape 1 : installer les dépendances dans un environnement virtuel
FROM python:3.13-slim@sha256:e48f59cdba69a3cbd9ed2cf0f348d90d45a8d350d98134cf1070bc106ee9ed90 AS builder
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
FROM python:3.13-slim@sha256:e48f59cdba69a3cbd9ed2cf0f348d90d45a8d350d98134cf1070bc106ee9ed90
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
