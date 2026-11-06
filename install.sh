#!/usr/bin/env bash
set -euo pipefail

REPO="kbysiec/multigravity-cli"
BRANCH="main"
RAW="https://raw.githubusercontent.com/$REPO/$BRANCH"
INSTALL_DIR="/usr/local/bin"

# ── helpers ──────────────────────────────────────────────────────────────────
print_step() { echo "  → $1"; }
abort()      { echo "Error: $1" >&2; exit 1; }

# ── platform check ───────────────────────────────────────────────────────────
if [ "$(uname -s)" != "Darwin" ]; then
  abort "This version of Multigravity is built exclusively for macOS."
fi

# ── preflight ────────────────────────────────────────────────────────────────
command -v curl &>/dev/null || abort "curl is required but was not found"

# Fallback to ~/.local/bin if /usr/local/bin is not writable without sudo
if [ ! -w "$INSTALL_DIR" ]; then
  INSTALL_DIR="$HOME/.local/bin"
  mkdir -p "$INSTALL_DIR"

  if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    case "${SHELL:-}" in
      */zsh)  SHELL_RC="$HOME/.zshrc" ;;
      */fish) SHELL_RC="$HOME/.config/fish/config.fish" ;;
      *)      SHELL_RC="$HOME/.bashrc" ;;
    esac

    LINE='export PATH="$HOME/.local/bin:$PATH"'

    if [ "$SHELL_RC" = "$HOME/.config/fish/config.fish" ]; then
      LINE='fish_add_path "$HOME/.local/bin"'
    fi

    if ! grep -qF "$HOME/.local/bin" "$SHELL_RC" 2>/dev/null; then
      echo "" >> "$SHELL_RC"
      echo "# Added by Multigravity installer" >> "$SHELL_RC"
      echo "$LINE" >> "$SHELL_RC"
      print_step "Added $INSTALL_DIR to PATH in $SHELL_RC"
    fi

    export PATH="$INSTALL_DIR:$PATH"
  fi
fi

echo "Installing Multigravity in $INSTALL_DIR ..."

# ── copy local or download from remote repo ──────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd || true)"

if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/multigravity" ]; then
  print_step "Copying local multigravity script..."
  cp "$SCRIPT_DIR/multigravity" "$INSTALL_DIR/multigravity"
  chmod +x "$INSTALL_DIR/multigravity"

  if [ -f "$SCRIPT_DIR/icon.icns" ]; then
    print_step "Copying application icon..."
    cp "$SCRIPT_DIR/icon.icns" "$INSTALL_DIR/icon.icns"
  fi
else
  print_step "Downloading multigravity..."
  curl -fsSL "$RAW/multigravity" -o "$INSTALL_DIR/multigravity"
  chmod +x "$INSTALL_DIR/multigravity"

  print_step "Downloading icon..."
  curl -fsSL "$RAW/icon.icns" -o "$INSTALL_DIR/icon.icns"
fi

echo ""
echo "✓ Multigravity installed successfully!"
echo ""
echo "Reload your shell to apply PATH changes:"
echo "  source ~/.zshrc   (or open a new terminal window)"
echo ""
echo "Usage:"
echo "  multigravity doctor                  # Diagnose environment"
echo "  multigravity new <profile-name>      # Create a new profile"
echo "  multigravity <profile-name>          # Launch Antigravity IDE (default)"
echo "  multigravity <profile-name> --chat   # Launch only Antigravity Desktop (Chat)"
echo "  multigravity <profile-name> --both   # Launch both IDE and Desktop simultaneously"
echo "  multigravity <profile-name> --ide    # Launch only Antigravity IDE"
