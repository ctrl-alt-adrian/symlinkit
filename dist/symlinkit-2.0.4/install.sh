#!/usr/bin/env bash
# symlinkit installer
# Usage: curl -fsSL https://raw.githubusercontent.com/ctrl-alt-adrian/symlinkit/main/scripts/install.sh | bash

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

  if [[ "$verify" == "script" ]]; then
    head -1 "$output" | grep -q "^#!/.*bash" || die "Downloaded file doesn't look like a bash script"
  fi
}

echo "Installing symlinkit to ~/bin..."

if [[ "$(uname -s)" == "Darwin" ]]; then
  if ! has_cmd grealpath || ! has_cmd gfind; then
    echo "Warning: macOS requires GNU utilities"
    echo "Install with: brew install coreutils findutils"
  fi
fi

INSTALL_DIR="$HOME/bin"

TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TEMP_DIR"' EXIT

echo "Downloading..."
download "$RAW_URL/scripts/symlinkit" "$TEMP_DIR/symlinkit" "script"

[[ -d "$INSTALL_DIR" ]] || mkdir -p -- "$INSTALL_DIR"
chmod +x "$TEMP_DIR/symlinkit"

if [[ -f "$INSTALL_DIR/symlinkit" ]]; then
  cp "$TEMP_DIR/symlinkit" "$INSTALL_DIR/symlinkit" || die "Reinstall failed"
  echo "Updated existing installation at $INSTALL_DIR/symlinkit"
else
  cp "$TEMP_DIR/symlinkit" "$INSTALL_DIR/symlinkit" || die "Install failed"
  echo "Installed to $INSTALL_DIR/symlinkit"
fi

if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
  PATH_EXPORT="export PATH='$HOME/bin:$PATH'"
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

download "$RAW_URL/man/symlinkit.1" "$TEMP_DIR/symlinkit.1" >/dev/null 2>&1 || true

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
mkdir -p -- "$MAN_DIR" || true
cp "$TEMP_DIR/symlinkit.1" "$MAN_DIR/symlinkit.1" 2>/dev/null || true

if [[ "$(uname -s)" == "Darwin" ]]; then
  makewhatis "$MAN_DIR" >/dev/null 2>&1 || true
else
  mandb "$MAN_DIR" >/dev/null 2>&1 || true
fi

if has_cmd bash; then
  download "$RAW_URL/completions/symlinkit.bash" "$TEMP_DIR/symlinkit.bash" >/dev/null 2>&1 || true
  if [[ "$(uname -s)" == "Darwin" ]]; then
    BASH_COMPLETION_DIR="$(brew --prefix 2>/dev/null || echo /usr/local)/etc/bash_completion.d"
  else
    BASH_COMPLETION_DIR="$HOME/.local/share/bash-completion/completions"
  fi
  mkdir -p -- "$BASH_COMPLETION_DIR" || true
  cp "$TEMP_DIR/symlinkit.bash" "$BASH_COMPLETION_DIR/symlinkit" 2>/dev/null || true
fi

if has_cmd zsh; then
  download "$RAW_URL/completions/_symlinkit" "$TEMP_DIR/_symlinkit" >/dev/null 2>&1 || true
  if [[ "$(uname -s)" == "Darwin" ]]; then
    ZSH_COMPLETION_DIR="$(brew --prefix 2>/dev/null || echo /usr/local)/share/zsh/site-functions"
  else
    ZSH_COMPLETION_DIR="$HOME/.local/share/zsh/site-functions"
  fi
  mkdir -p -- "$ZSH_COMPLETION_DIR" || true
  cp "$TEMP_DIR/_symlinkit" "$ZSH_COMPLETION_DIR/_symlinkit" 2>/dev/null || true
fi

echo ""
echo "Done! Run 'symlinkit --help' to get started."
echo ""

if command -v symlinkit >/dev/null 2>&1; then
  echo "Installed version: $(symlinkit --version)"
else
  echo "Note: You may need to restart your shell or run: source ~/.bashrc"
fi

echo ""
echo "=== Completion setup hints ==="
if [[ "$(uname -s)" == "Darwin" ]]; then
  echo "Bash:"
  echo "  brew install bash-completion"
  echo "  echo \"[[ -r \$(brew --prefix)/etc/profile.d/bash_completion.sh ]] && . \$(brew --prefix)/etc/profile.d/bash_completion.sh\" >> ~/.bashrc"
  echo ""
  echo "Zsh:"
  echo "  autoload -Uz compinit && compinit"
  echo "  export FPATH=\"\$(brew --prefix)/share/zsh/site-functions:\$FPATH\""
else
  echo "Bash:"
  echo "  completions are in ~/.local/share/bash-completion/completions/symlinkit"
  echo "  should load automatically if bash-completion is installed"
  echo ""
  echo "Zsh:"
  echo "  autoload -Uz compinit && compinit"
  echo "  export FPATH=\"\$HOME/.local/share/zsh/site-functions:\$FPATH\""
fi
echo "=============================="

