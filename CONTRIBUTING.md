# Contribuer

## Flux de travail

1. Partir de `main` à jour : `git switch main && git pull`.
2. Créer une branche courte : `feat/...`, `fix/...`, `docs/...` ou `chore/...`.
3. Faire de petits commits signés, puis pousser la branche.
4. Ouvrir une pull request vers `main` (quoi, pourquoi, comment tester).
5. Faire relire par l'autre membre du binôme ; corriger par un nouveau commit.
6. Fusionner par squash et supprimer la branche.

## Convention de commits

Les messages suivent Conventional Commits : `feat:`, `fix:`, `docs:`, `test:`, `chore:`.

## Lancer les tests et pre-commit

    python3 -m venv .venv && source .venv/bin/activate
    pip install -e ".[dev]"
    pytest -q
    pre-commit install
    pre-commit run --all-files
