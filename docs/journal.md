# Journal

## TP01

**Q1. Délai entre le premier commit et sa fusion sur main :** 159 minutes pour `feat/version-header` (PR #2). C'est notre premier délai de changement.

**Q2. Ce qui ne dépend pas de GitHub :** Git (branches, commits, rebase, tags), les signatures SSH, pre-commit, ruff, pytest et Docker fonctionneraient tels quels sur GitLab, Gitea ou Forgejo. Il faudrait changer les commandes `gh`, la création depuis un modèle, l'invitation des collaborateurs et les règles de revue et de fusion, propres à chaque forge.

**Q3. Pourquoi signer si la forge vérifie qui pousse ?** La forge sait qui pousse, pas qui a écrit le commit. La signature reste attachée au commit : elle prouve son auteur même si un autre le pousse, ou si le dépôt migre vers une autre forge.

**Ce qui a pris le plus de temps :** la mise en place de la VM, et l'absence d'organisation pour le dépôt modèle.
