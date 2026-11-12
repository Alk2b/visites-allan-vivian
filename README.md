[![CI](https://github.com/Alk2b/visites-allan-vivian/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/Alk2b/visites-allan-vivian/actions/workflows/ci.yml)

# Visites - API de comptage de visites (Allan et Vivian)

Application fil rouge du module Intro DevOps : une API FastAPI qui compte les visites dans Redis.

## Routes

| Route | Rôle |
|---|---|
| `GET /` | Incrémente et renvoie le compteur, avec l'en-tête `X-Visites-Version` |
| `POST /reset` | Remet le compteur à zéro |
| `GET /health` | Indique l'état de l'API et de Redis |
| `GET /metrics` | Expose les métriques Prometheus |

## Lancer en local

```bash
python3 -m venv .venv && source .venv/bin/activate
pip install -e ".[dev]"
docker run -d --name redis -p 6379:6379 redis:8-alpine
uvicorn app.main:app --reload
```

## Tests

```bash
pytest -q
```
