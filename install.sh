#!/usr/bin/env bash
# Installe ou met à jour les skills du bundle dans ~/.claude/skills.
# Utilisé par le setup script cloud et par la tâche planifiée du Mac :
#   curl -fsSL https://raw.githubusercontent.com/JUNITY-SH/claude-skills-bundle/main/install.sh | bash
# Passe par raw.githubusercontent.com, autorisé dans les sessions cloud (le proxy GitHub y bloque les clones).
set -u

BASE="${BUNDLE_BASE:-https://raw.githubusercontent.com/JUNITY-SH/claude-skills-bundle/main}"
DEST="$HOME/.claude/skills"
STATE="$DEST/.bundle-managed"
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

if ! curl -fsSL --retry 3 "$BASE/MANIFEST.txt" -o "$STAGE/MANIFEST.txt"; then
  echo "Skills : manifeste injoignable, rien n'est modifié" >&2; exit 0
fi

mkdir -p "$STAGE/skills"
tr '\n' '\0' < "$STAGE/MANIFEST.txt" | BASE="$BASE" S="$STAGE/skills" xargs -0 -P 16 -n 1 sh -c '
  [ -n "$0" ] || exit 0
  mkdir -p "$S/$(dirname "$0")"
  curl -fsSL --retry 3 -o "$S/$0" "$BASE/skills/$0" || { echo "Échec : $0" >&2; exit 255; }
'
if [ $? -ne 0 ]; then echo "Skills : téléchargement incomplet, rien n'est modifié" >&2; exit 0; fi

# raw ne conserve pas les droits d'exécution
grep -rlI --exclude='*.md' '^#!' "$STAGE/skills" 2>/dev/null | xargs chmod +x 2>/dev/null

mkdir -p "$DEST"
ls "$STAGE/skills" > "$STAGE/new"
# Supprime les skills du bundle qui ont disparu des sources
if [ -f "$STATE" ]; then
  while read -r n; do
    [ -n "$n" ] && ! grep -qxF "$n" "$STAGE/new" && rm -rf "${DEST:?}/$n"
  done < "$STATE"
fi
while read -r n; do
  rm -rf "${DEST:?}/$n"
  mv "$STAGE/skills/$n" "$DEST/$n"
done < "$STAGE/new"
cp "$STAGE/new" "$STATE"

echo "Skills à jour : $(wc -l < "$STAGE/new" | tr -d ' ') skills du bundle"
exit 0
