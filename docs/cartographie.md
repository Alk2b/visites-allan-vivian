git switch main && git pull
git switch docs/cartographie 2>/dev/null || git switch -c docs/cartographie
cat > docs/cartographie.md <<'EOF'
# Cartographie du flux de livraison

> Cartographie refaite pour le TP01 : le rendu de l'atelier A1 n'a pas été retrouvé.

| Étape | Outil | Qui | Contrôle | Automatisé |
|---|---|---|---|---|
| Développer sur une branche courte | Git | Auteur | Commits conventionnels et signés | Signature : oui |
| Tester en local | pytest, Redis en conteneur | Auteur | Tests | Non |
| Vérifier le style | pre-commit, ruff | Auteur | Hooks avant commit | Oui (étape 6) |
| Ouvrir une pull request | GitHub, gh | Auteur | Quoi, pourquoi, comment tester | Non |
| Relire | GitHub, gh | Autre membre | Revue croisée | Non |
| Fusionner | Squash sur main | Binôme | Historique linéaire | Non |
| Versionner | Tag signé | Membre A | Vérification de la signature | Non |

## Points à améliorer

- Lancer les tests automatiquement à chaque pull request.
- Mettre à jour les dépendances automatiquement (TP02).
- Corriger le Dockerfile (TP04).
- Passer le dépôt en privé (TP07).
EOF
git add docs/cartographie.md
git commit -m "docs: ajouter la cartographie du flux de livraison"
git log --show-signature -1
git push -u origin docs/cartographie
gh pr create --fill --base main
