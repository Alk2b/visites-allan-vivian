# Journal

## TP01

**Q1. Délai entre le premier commit et sa fusion sur main :** 159 minutes pour `feat/version-header` (PR #2). C'est notre premier délai de changement.

**Q2. Ce qui ne dépend pas de GitHub :** Git (branches, commits, rebase, tags), les signatures SSH, pre-commit, ruff, pytest et Docker fonctionneraient tels quels sur GitLab, Gitea ou Forgejo. Il faudrait changer les commandes `gh`, la création depuis un modèle, l'invitation des collaborateurs et les règles de revue et de fusion, propres à chaque forge.

**Q3. Pourquoi signer si la forge vérifie qui pousse ?** La forge sait qui pousse, pas qui a écrit le commit. La signature reste attachée au commit : elle prouve son auteur même si un autre le pousse, ou si le dépôt migre vers une autre forge.

**Ce qui a pris le plus de temps :** la mise en place de la VM, et l'absence d'organisation pour le dépôt modèle.

## TP02

### Secret historique et rotation

- Secret trouvé par `gitleaks git --verbose --redact .` : règle `github-pat`, fichier `app/old_settings.py` ligne 2,
  commit `707161a` (« chore: paramètres temporaires »), auteur Allan Khebab, 12/11/2026 07:35 UTC.
- Rotation : le jeton a été poussé sur une forge publique, il est donc considéré comme compromis.
  Un vrai jeton aurait été révoqué dans GitHub (Settings → Developer settings → Personal access tokens),
  recréé avec le moindre privilège et stocké dans un secret de dépôt, jamais dans le code.
- Historique non réécrit : le dépôt est déjà partagé et le secret déjà exposé ; réécrire n'annule pas la fuite.
  Fichier supprimé et empreinte ajoutée à `.gitleaksignore`.
- Notre dépôt modèle a été créé à partir des fichiers fournis, sans l'historique du formateur : le faux jeton n'y était pas. Nous l'avons planté nous-mêmes (commit 707161a) avant de poser les règles de protection.

### Questions des étapes

- Dismiss stale approvals : une approbation est annulée si de nouveaux commits arrivent ; on évite
  qu'une PR approuvée soit ensuite modifiée puis fusionnée sans relecture du nouveau code.
- CODEOWNERS : si le seul propriétaire est absent, la PR est bloquée. Il faut au moins deux propriétaires
  par zone (ou une équipe) et une procédure de contournement encadrée par un administrateur.
- Dependabot : sa PR est ouverte par un robot, elle doit être approuvée par un membre du binôme comme
  n'importe quelle PR ; une mise à jour de dépendance peut casser l'application ou introduire du code malveillant.
- gitleaks (étape 4) : la clé d'exemple AWS de la documentation (« …EXAMPLEKEY ») est ignorée par gitleaks ;
  une valeur réaliste a été refusée (règle `generic-api-key`, entropie 5,3). Renommée en `MA_VARIABLE`,
  la même valeur passe : la détection repose sur le nom de la variable (mot-clé) et l'entropie de la valeur.

### Questions d'observation

- Q1. Auraient bloqué le secret : la revue obligatoire (humaine), gitleaks en pre-commit, gitleaks en CI
  comme contrôle requis et la push protection GitHub (automatiques). Le plus fiable : le contrôle côté serveur,
  qui ne dépend pas du poste du développeur.
- Q2. Non : pre-commit est local et peut ne pas être installé ou être contourné (`--no-verify`).
  Il faut lancer gitleaks dans le pipeline et rendre ce check obligatoire dans le ruleset.
- Q3. Quelques secondes à quelques minutes : des robots scrutent les dépôts publics en continu.
  GitHub Secret Scanning prévient les fournisseurs partenaires, qui révoquent certains jetons automatiquement
  (jetons GitHub, AWS, Slack, Stripe…).

## TP03

### Pipeline
- Durées du job py3.13 : 49 s avant la matrice, puis 56 s (cache absent) et 46 s (cache restauré). Job py3.12 : 1 min 0 s, puis 1 min 2 s.
- Le cache pip fait peu gagner, car `pip install` ne prend que 6 à 10 s. L'étape la plus longue est pre-commit (30 à 40 s), qui réinstalle ses hooks à chaque exécution.
- Checks requis dans le ruleset : `test (py3.12)` et `test (py3.13)`.
- act 0.2.89, avec l'image `catthehacker/ubuntu:act-24.04` épinglée : le job passe jusqu'à pytest. `upload-artifact` échoue faute de `ACTIONS_RUNTIME_TOKEN`, car le service d'artefacts de GitHub n'existe pas en local.
- Le cache pip n'est jamais trouvé avec act (« pip cache is not found ») : sans échec, mais sans gain.

### Questions d'observation
- Q1. Environ 1 min par job, les deux versions tournant en parallèle. Le plus long est pre-commit (installation des hooks), puis `pip install` et le démarrage de l'exécuteur. Le cache pip n'a fait gagner que quelques secondes : mettre en cache les hooks de pre-commit serait plus efficace.
- Q2. Le ruleset : PR obligatoire, checks `test (py3.12)` et `test (py3.13)` requis, aucune exception (bypass list vide). Sans lui, le pipeline n'est qu'un avis.
- Q3. Pour Gitea Actions, presque rien : même syntaxe, le fichier peut aller dans `.gitea/workflows`. Pour GitLab CI, tout le fichier est à réécrire en `.gitlab-ci.yml` (stages, image, script, cache, artifacts), mais avec les mêmes concepts.

## TP04

### Mesures avant / après

| Mesure | Image naïve | Image optimisée |
| --- | --- | --- |
| Taille décompressée | 1,3 Go | 184 Mo |
| Taille compressée | 489 Mo | 61 Mo |
| Couches (`docker history`) | 17 | 19 |
| Utilisateur | root | `app` (UID 10001) |
| Contenu de `/app` | tout le projet, dont `.git` et `tests` | `app/` uniquement |
| Base | `python:3.13`, non épinglée | `python:3.13-slim`, épinglée par digest |
| Construction initiale | 33 s | 55 s |
| Reconstruction après un changement de code | 34 s | 7 s |

Digest de l'image 0.1.1 (tags `0.1.1` et `sha-b4aa2dc`) :
`sha256:8bc944092691fbbf6f0904756d9511d7e85cc674d23a2bdb0c1f1c531b25370d`

### Questions d'observation
- Q1. L'image est passée de 1,3 Go à 184 Mo (−86 %). C'est la base `slim` qui a eu le plus d'effet : l'image complète apporte à elle seule environ 1 Go d'outils de compilation. Le multi-étapes et le `.dockerignore` retirent ensuite le reste (`.git`, `.venv`, tests, caches).
- Q2. Le tag `sha-xxxxxxx` relie l'image au commit qui l'a produite, et le tag `0.1.1` à la version publiée : ils racontent l'histoire de l'image. Mais un tag peut être déplacé vers une autre image, alors que le digest est l'empreinte du contenu : c'est la seule référence immuable. Déployer par digest garantit de lancer exactement l'image testée.
- Q3. Une image ne doit jamais contenir de secrets, ni `.git`, ni d'outils de construction, ni de tests, ni de shell ou de paquets inutiles : tout ce qui s'y trouve peut être lu ou exploité. Les Docker Hardened Images vont plus loin en supprimant même le shell et le gestionnaire de paquets, ce qui réduit encore la surface d'attaque.
