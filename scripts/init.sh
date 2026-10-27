#!/usr/bin/env bash
# Copy the SDD template without overwriting files. Usage: init.sh [target-dir]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/../assets/template"
TARGET="${1:-.}"
FILES=(status.md spec.md plan.md history.md)

command -v git >/dev/null 2>&1 || { echo 'ERROR: git is not available' >&2; exit 1; }
if [ -d "$TARGET/.agent" ] && [ ! -e "$TARGET/.agent/status.md" ]; then
  echo 'ERROR: existing .agent has no status.md; inspect its existing rules or repair the incomplete initialization. No automatic migration was performed.' >&2
  exit 1
fi
for f in AGENTS.md "${FILES[@]/#/.agent/}"; do
  if [ ! -f "$TEMPLATE_DIR/$f" ]; then
    echo "ERROR: template missing: $TEMPLATE_DIR/$f" >&2
    exit 1
  fi
done

mkdir -p -- "$TARGET"
if [ "$(git -C "$TARGET" rev-parse --is-inside-work-tree 2>/dev/null || :)" = true ]; then
  echo 'Git repo already present.'
else
  if ! git -C "$TARGET" init >/dev/null; then
    echo 'ERROR: Git initialization failed.' >&2
    exit 1
  fi
  echo 'Git repo initialized.'
fi
mkdir -p -- "$TARGET/.agent"

created=()
skipped=()
copy_one() {
  local src="$1" dest="$2"
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    skipped+=("$dest")
  elif (set -o noclobber; cat -- "$src" > "$dest"); then
    created+=("$dest")
  else
    echo "ERROR: could not create $dest; existing files were not overwritten." >&2
    return 1
  fi
}

copy_one "$TEMPLATE_DIR/AGENTS.md" "$TARGET/AGENTS.md"
for f in "${FILES[@]}"; do
  copy_one "$TEMPLATE_DIR/.agent/$f" "$TARGET/.agent/$f"
done

echo 'Created:'
printf '  %s\n' "${created[@]:-(none)}"
if [ "${#skipped[@]}" -gt 0 ]; then
  echo 'Skipped (already exist, NOT overwritten):'
  printf '  %s\n' "${skipped[@]}"
fi
echo 'Next: replace [PROJECT_NAME] in AGENTS.md; backfill technology after design; add the harness rule file and README; record D001 in plan.md and history.md, then make the first commit.'
