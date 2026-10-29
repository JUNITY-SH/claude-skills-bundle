# claude-skills-bundle

Regroupe les skills Claude Code de plusieurs dépôts publics en un seul endroit, reconstruit chaque lundi par une GitHub Action.

Sources : voir [`sources.txt`](sources.txt) (versions exactes dans `SOURCES.lock`). Licences d'origine dans [`licenses/`](licenses/), toutes MIT.

## Installer ou mettre à jour

```bash
curl -fsSL https://raw.githubusercontent.com/JUNITY-SH/claude-skills-bundle/main/install.sh | bash
```

Installe les skills dans `~/.claude/skills`. Sert de setup script pour les environnements cloud Claude Code et de tâche planifiée en local.

## Ajouter une source

Ajouter `owner/repo` dans `sources.txt` : le bundle est reconstruit au push.

## Mise à jour automatique sur un Mac

```bash
curl -fsSL https://raw.githubusercontent.com/JUNITY-SH/claude-skills-bundle/main/setup-mac.sh | bash
```

Programme une mise à jour chaque mardi à 10h (tâche launchd) ; le journal est dans `~/Library/Logs/claude-skills-update.log`.
