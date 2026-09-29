#!/usr/bin/env bash
# SDD scaffold init: copy skill template into a target directory.
# Idempotent, never overwrites existing files. Git init only (first commit is
# made by the agent after customization). Usage: init.sh [target-dir]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/../assets/template"
TARGET="${1:-.}"

if [ ! -f "$TEMPLATE_DIR/AGENTS.md" ]; then
  echo "ERROR: template not found at $TEMPLATE_DIR (keep scripts/ next to assets/)" >&2
  exit 1
fi

mkdir -p "$TARGET/.agent"

created=()
skipped=()
copy_one() {
  local src="$1" dest="$2"
  if [ -e "$dest" ]; then
    skipped+=("$dest")
  else
    cp "$src" "$dest"
    created+=("$dest")
  fi
}

copy_one "$TEMPLATE_DIR/AGENTS.md" "$TARGET/AGENTS.md"
for f in "$TEMPLATE_DIR"/.agent/*.md; do
  copy_one "$f" "$TARGET/.agent/$(basename "$f")"
done

echo "Created:"
printf '  %s\n' "${created[@]:-(none)}"
if [ "${#skipped[@]}" -gt 0 ]; then
  echo "Skipped (already exist, NOT overwritten):"
  printf '  %s\n' "${skipped[@]}"
fi

if git -C "$TARGET" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Git repo already present."
else
  git -C "$TARGET" init >/dev/null
  echo "Git repo initialized."
fi

echo "Next: customize AGENTS.md placeholders, add harness rule file, write README.md, decisions.md D001, then first commit."
