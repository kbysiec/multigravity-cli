#!/usr/bin/env bash
set -euo pipefail

# ── helpers ───────────────────────────────────────────────────────────────────
print_step() { echo "  → $1"; }
abort()      { echo "Error: $1" >&2; exit 1; }

# ── platform check ────────────────────────────────────────────────────────────
if [ "$(uname -s)" != "Darwin" ]; then
  abort "This uninstaller is built exclusively for macOS."
fi

echo "Uninstalling Multigravity..."
echo ""

REMOVED=0

# ── binary + icon ─────────────────────────────────────────────────────────────
for dir in "/usr/local/bin" "$HOME/.local/bin"; do
  if [ -f "$dir/multigravity" ]; then
    print_step "Removing $dir/multigravity"
    rm -f "$dir/multigravity"
    REMOVED=$((REMOVED + 1))
  fi
  if [ -f "$dir/icon.icns" ]; then
    print_step "Removing $dir/icon.icns"
    rm -f "$dir/icon.icns"
  fi
done

# ── desktop / application shortcuts ───────────────────────────────────────────
for shortcut in "$HOME/Applications"/Multigravity\ *.app; do
  [ -d "$shortcut" ] || continue
  print_step "Removing shortcut: $shortcut"
  rm -rf "$shortcut"
done

# ── profile data (optional) ───────────────────────────────────────────────────
PROFILE_BASE="${MULTIGRAVITY_HOME:-$HOME/AntigravityProfiles}"
if [ -d "$PROFILE_BASE" ]; then
  echo ""
  read -r -p "Delete all profile data in '$PROFILE_BASE'? [y/N] " confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    print_step "Removing profile data: $PROFILE_BASE"
    rm -rf "$PROFILE_BASE"
  else
    echo "  Profile data kept intact."
  fi
fi

echo ""
if [ "$REMOVED" -eq 0 ]; then
  echo "No Multigravity files found to remove."
else
  echo "✓ Multigravity has been uninstalled."
fi
