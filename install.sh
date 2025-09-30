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

# Install
[[ -d "$INSTALL_DIR" ]] || mkdir -p "$INSTALL_DIR"
chmod +x "$TEMP_DIR/symlinkit"
cp "$TEMP_DIR/symlinkit" "$INSTALL_DIR/symlinkit" || die "Install failed"

echo "Installed to $INSTALL_DIR/symlinkit"

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
echo "Downloading man page..."
download "$RAW_URL/man/symlinkit.1" "$TEMP_DIR/symlinkit.1"

MAN_DIR="$HOME/.local/share/man/man1"
mkdir -p "$MAN_DIR" 2>/dev/null || true
cp "$TEMP_DIR/symlinkit.1" "$MAN_DIR/symlinkit.1" && echo "Man page installed"

echo ""
echo "Done! Run 'symlinkit --help' to get started."