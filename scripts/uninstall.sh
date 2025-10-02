#!/usr/bin/env bash
# symlinkit uninstaller
# Usage: curl -fsSL https://raw.githubusercontent.com/ctrl-alt-adrian/symlinkit/main/scripts/uninstall.sh | bash

set -euo pipefail

die() {
  echo "Error: $*" >&2
  exit 1
}

has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

echo "Uninstalling symlinkit..."

INSTALL_DIR="$HOME/bin"
removed_any=false

# Remove binary
if [[ -f "$INSTALL_DIR/symlinkit" ]]; then
  rm -f -- "$INSTALL_DIR/symlinkit" || die "Failed to remove binary"
  echo "Removed binary: $INSTALL_DIR/symlinkit"
  removed_any=true
fi

# Detect prefix and man dir
if [[ "$(uname -s)" == "Darwin" ]]; then
  if has_cmd brew && [[ -n "$(brew --prefix 2>/dev/null)" ]]; then
    PREFIX="$(brew --prefix)"
  else
    PREFIX="/usr/local"
  fi
else
  PREFIX="$HOME/.local"
fi

MAN_DIR="$PREFIX/share/man/man1"
if [[ -f "$MAN_DIR/symlinkit.1" ]]; then
  rm -f -- "$MAN_DIR/symlinkit.1" || die "Failed to remove man page"
  echo "Removed man page: $MAN_DIR/symlinkit.1"
  removed_any=true
  if [[ "$(uname -s)" == "Darwin" ]]; then
    makewhatis "$MAN_DIR" >/dev/null 2>&1 || true
  else
    mandb "$MAN_DIR" >/dev/null 2>&1 || true
  fi
fi

# Bash completions
if has_cmd bash; then
  if [[ "$(uname -s)" == "Darwin" ]]; then
    BASH_COMPLETION_DIR="$(brew --prefix 2>/dev/null || echo /usr/local)/etc/bash_completion.d"
  else
    BASH_COMPLETION_DIR="$HOME/.local/share/bash-completion/completions"
  fi
  if [[ -f "$BASH_COMPLETION_DIR/symlinkit" ]]; then
    rm -f -- "$BASH_COMPLETION_DIR/symlinkit" || die "Failed to remove bash completion"
    echo "Removed bash completion: $BASH_COMPLETION_DIR/symlinkit"
    removed_any=true
  fi
fi

# Zsh completions
if has_cmd zsh; then
  if [[ "$(uname -s)" == "Darwin" ]]; then
    ZSH_COMPLETION_DIR="$(brew --prefix 2>/dev/null || echo /usr/local)/share/zsh/site-functions"
  else
    ZSH_COMPLETION_DIR="$HOME/.local/share/zsh/site-functions"
  fi
  if [[ -f "$ZSH_COMPLETION_DIR/_symlinkit" ]]; then
    rm -f -- "$ZSH_COMPLETION_DIR/_symlinkit" || die "Failed to remove zsh completion"
    echo "Removed zsh completion: $ZSH_COMPLETION_DIR/_symlinkit"
    removed_any=true
  fi
fi

# Warn if PATH/MANPATH exports exist
PATH_EXPORT="export PATH='$HOME/bin:$PATH'"
for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
  if [[ -f "$rc" ]]; then
    if grep -qF "$PATH_EXPORT" "$rc"; then
      echo "⚠️  Note: symlinkit PATH entry still exists in $rc"
      echo "   You may want to remove this line manually:"
      echo "   $PATH_EXPORT"
    fi
    if grep -q "export MANPATH=" "$rc"; then
      echo "⚠️  Note: MANPATH entry exists in $rc"
      echo "   Consider removing it if only used for symlinkit."
    fi
  fi
done

if [[ "$removed_any" == false ]]; then
  echo "No symlinkit files found to remove."
else
  echo ""
  echo "Uninstall complete."
  echo "Restart your shell to apply changes."
fi

