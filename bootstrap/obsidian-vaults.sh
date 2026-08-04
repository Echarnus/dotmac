#!/usr/bin/env bash
#
# Register the iCloud note vaults with Obsidian. Run once on a fresh machine:
#
#   ~/dotfiles/bootstrap/obsidian-vaults.sh
#
# The vaults themselves are *not* created here — they live in iCloud Drive and
# arrive with their own `.obsidian/` (themes, plugins, hotkeys) already synced.
# The one thing iCloud does not carry is Obsidian's own list of known vaults,
# which is machine-local state in
#
#   ~/Library/Application Support/obsidian/obsidian.json
#
# Without it a fresh install opens the "no vaults yet" picker and you have to
# hunt down the `com~apple~CloudDocs` path by hand, three times.
#
# NIX-FIRST NOTE: per AGENTS.md this is interim scaffolding like the other
# bootstrap scripts. It is a shell script rather than home-manager config
# because obsidian.json is *not* a config file — Obsidian rewrites it on every
# quit (window geometry, which vault was last open), so it can be seeded but
# never symlinked from a read-only store.
#
# Idempotent: a vault already listed keeps its existing id and timestamp.

set -euo pipefail

NOTES_DIR="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Notes"
CONFIG="$HOME/Library/Application Support/obsidian/obsidian.json"

# Obsidian rewrites obsidian.json wholesale when it exits, so anything written
# underneath a running instance is discarded on quit — silently, and long after
# this script reported success.
if pgrep -qx Obsidian; then
  echo "✗ Obsidian is running; it would overwrite these changes on quit." >&2
  echo "  Quit Obsidian and re-run this script." >&2
  exit 1
fi

if [[ ! -d "$NOTES_DIR" ]]; then
  echo "✗ $NOTES_DIR not found — is iCloud Drive signed in and synced?" >&2
  exit 1
fi

# A vault is any directory under Notes/ that already carries a .obsidian folder,
# so adding a fourth vault in iCloud needs no change here.
vaults=()
for dir in "$NOTES_DIR"/*/; do
  [[ -d "$dir.obsidian" ]] && vaults+=("${dir%/}")
done

if [[ ${#vaults[@]} -eq 0 ]]; then
  echo "✗ No vaults (directories containing .obsidian) found in $NOTES_DIR." >&2
  exit 1
fi

mkdir -p "$(dirname "$CONFIG")"

# Merge rather than overwrite: obsidian.json also holds window frame state and
# update preferences that are none of this script's business.
python3 - "$CONFIG" "${vaults[@]}" <<'PY'
import hashlib, json, os, sys, time

config_path, *vault_paths = sys.argv[1:]

try:
    with open(config_path) as fh:
        config = json.load(fh)
except (FileNotFoundError, json.JSONDecodeError):
    config = {}

vaults = config.setdefault("vaults", {})
by_path = {entry.get("path"): vid for vid, entry in vaults.items()}
now = int(time.time() * 1000)

for path in vault_paths:
    name = os.path.basename(path)
    if path in by_path:
        print(f"  = {name} (already registered)")
        continue
    # Obsidian only needs the id to be unique; deriving it from the path keeps
    # re-runs on a rebuilt machine stable instead of accumulating duplicates.
    vault_id = hashlib.md5(path.encode()).hexdigest()[:16]
    vaults[vault_id] = {"path": path, "ts": now}
    print(f"  + {name}")

with open(config_path, "w") as fh:
    json.dump(config, fh, indent=2)
PY

echo "✓ Obsidian vaults registered in $CONFIG"
