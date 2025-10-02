#!/usr/bin/env bash
# symlinkit installer
# Usage: curl -fsSL https://raw.githubusercontent.com/ctrl-alt-adrian/symlinkit/main/install.sh | bash

set -euo pipefail

RAW_URL="https://raw.githubusercontent.com/ctrl-alt-adrian/symlinkit/main"

die() {
  echo "Error: $*" >&2
  exit 1
}

has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

download() {
  local url="$1" output="$2" verify="${3:-}"

  if has_cmd curl; then
    curl -fsSL "$url" -o "$output" || die "Download failed: $url"
  elif has_cmd wget; then
    wget -q "$url" -O "$output" || die "Download failed: $url"
  else
    die "Need curl or wget to download"
  fi

  [[ -s "$output" ]] || die "Downloaded file is empty"

  # Verify bash script if requested
  if [[ "$verify" == "script" ]]; then
    head -1 "$output" | grep -q "^#!/.*bash" || die "Downloaded file doesn't look like a bash script"
  fi
}

echo "Installing symlinkit to ~/bin..."

# Warn on macOS if missing dependencies
if [[ "$(uname -s)" == "Darwin" ]]; then
  if ! has_cmd grealpath || ! has_cmd gfind; then
    echo "Warning: macOS requires GNU utilities"
    echo "Install with: brew install coreutils findutils"
  fi
fi

INSTALL_DIR="$HOME/bin"

# Create temp dir and download
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

echo "Downloading..."
download "$RAW_URL/symlinkit" "$TEMP_DIR/symlinkit" "script"

# Install (silently reinstall if already exists)
[[ -d "$INSTALL_DIR" ]] || mkdir -p "$INSTALL_DIR"
chmod +x "$TEMP_DIR/symlinkit"

if [[ -f "$INSTALL_DIR/symlinkit" ]]; then
  # Reinstall silently
  cp "$TEMP_DIR/symlinkit" "$INSTALL_DIR/symlinkit" || die "Reinstall failed"
  echo "Updated existing installation at $INSTALL_DIR/symlinkit"
else
  # Fresh install
  cp "$TEMP_DIR/symlinkit" "$INSTALL_DIR/symlinkit" || die "Install failed"
  echo "Installed to $INSTALL_DIR/symlinkit"
fi

# Update shell rc files
if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
  # shellcheck disable=SC2016
  PATH_EXPORT='export PATH="$HOME/bin:$PATH"'

  for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [[ -f "$rc" ]] && ! grep -qF "$PATH_EXPORT" "$rc"; then
      {
        echo ""
        echo "# symlinkit"
        echo "$PATH_EXPORT"
      } >> "$rc"
      echo "Updated $rc"
    fi
  done

  echo "Restart your shell or run: source ~/.bashrc"
fi

# Install man page
download "$RAW_URL/man/symlinkit.1" "$TEMP_DIR/symlinkit.1" >/dev/null 2>&1

# Detect appropriate man page directory
if [[ "$(uname -s)" == "Darwin" ]]; then
  MAN_DIR="/usr/local/share/man/man1"  # macOS user applications
else
  MAN_DIR="$HOME/.local/share/man/man1"  # Linux user-local
fi

mkdir -p "$MAN_DIR" 2>/dev/null || true
cp "$TEMP_DIR/symlinkit.1" "$MAN_DIR/symlinkit.1" 2>/dev/null || true

# Install completions only for shells that exist
# Bash completion
if has_cmd bash; then
  download "$RAW_URL/completions/symlinkit.bash" "$TEMP_DIR/symlinkit.bash" >/dev/null 2>&1

  if [[ "$(uname -s)" == "Darwin" ]]; then
    BASH_COMPLETION_DIR="/usr/local/etc/bash_completion.d"
  else
    BASH_COMPLETION_DIR="$HOME/.local/share/bash-completion/completions"
  fi
  mkdir -p "$BASH_COMPLETION_DIR" 2>/dev/null || true
  cp "$TEMP_DIR/symlinkit.bash" "$BASH_COMPLETION_DIR/symlinkit" 2>/dev/null || true
fi

# Zsh completion
if has_cmd zsh; then
  download "$RAW_URL/completions/_symlinkit" "$TEMP_DIR/_symlinkit" >/dev/null 2>&1

  if [[ "$(uname -s)" == "Darwin" ]]; then
    ZSH_COMPLETION_DIR="/usr/local/share/zsh/site-functions"
  else
    ZSH_COMPLETION_DIR="$HOME/.local/share/zsh/site-functions"
  fi
  mkdir -p "$ZSH_COMPLETION_DIR" 2>/dev/null || true
  cp "$TEMP_DIR/_symlinkit" "$ZSH_COMPLETION_DIR/_symlinkit" 2>/dev/null || true
fi

echo ""
echo "Done! Run 'symlinkit --help' to get started."
echo ""

# Show installed version
if command -v symlinkit >/dev/null 2>&1; then
  echo "Installed version: $(symlinkit --version)"
else
  echo "Note: You may need to restart your shell or run: source ~/.bashrc"
fi