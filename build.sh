#!/usr/bin/env bash
# Reconstruit skills/ et MANIFEST.txt depuis les dépôts sources (lancé chaque semaine par la GitHub Action).
set -euo pipefail
cd "$(dirname "$0")"

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
rm -rf skills licenses
mkdir -p skills licenses
: > SOURCES.lock

# sources.txt : un dépôt GitHub par ligne (owner/repo), lignes # ignorées
grep -v '^\s*#' sources.txt | grep . | while read -r repo; do
  git clone -q --depth 1 "https://github.com/$repo" "$TMP/$repo"
  echo "$repo $(git -C "$TMP/$repo" rev-parse HEAD)" >> SOURCES.lock
  cp "$TMP/$repo"/LICENSE* "licenses/${repo//\//__}.txt" 2>/dev/null || true
  for d in "$TMP/$repo"/skills/*/; do
    n=$(basename "$d")
    [ -f "$d/SKILL.md" ] || continue
    if [ -e "skills/$n" ]; then echo "Doublon ignoré : $n ($repo)" >&2; continue; fi
    cp -R "$d" "skills/$n"
  done
done

(cd skills && find . -type f | sed 's#^\./##' | LC_ALL=C sort) > MANIFEST.txt
echo "$(ls skills | wc -l | tr -d ' ') skills, $(wc -l < MANIFEST.txt | tr -d ' ') fichiers"
