# symlinkit

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/ctrl-alt-adrian/symlinkit)
![Linux](https://img.shields.io/badge/OS-Linux-green?logo=linux)
![macOS](https://img.shields.io/badge/OS-macOS-lightgrey?logo=apple)
![WSL](https://img.shields.io/badge/OS-WSL-blue?logo=windows)

> **📚 [Visit the Wiki](https://github.com/ctrl-alt-adrian/symlinkit/wiki)** for comprehensive guides, tutorials, and API documentation.

A small command-line tool that makes working with symlinks less of a hassle.
It supports **intelligent interactive selection** (auto-detects [fzf](https://github.com/junegunn/fzf) with manual fallback), recursive linking, overwrite/merge modes, safe dry-runs, and advanced inspection tools to manage existing symlinks on your system.

Originally built to manage dotfiles, it works anywhere you need to symlink directories. **Works with or without fzf** - gracefully falls back to manual prompts when fzf isn't available.

## Table of Contents

- [Features](#features)
- [Supported Operating Systems](#supported-operating-systems)
- [Installation](#installation)
- [Flags](#flags)
- [Examples](#examples)
- [Testing](#testing)
- [Contributing](#contributing)
- [Reporting Issues](#reporting-issues)
- [Requirements](#requirements)
- [Documentation](#documentation)
- [License](#license)

---

## Features

- **Smart Interactive Selection** - Auto-detects fzf, falls back to manual prompts
- **Symlink Operations** - Create (`-c`), merge (`-m`), overwrite (`-o`), delete (`-d`)
- **Safe Workflows** - Dry-run mode, interactive prompts, explicit operation flags required
- **Inspection Tools** - List, find broken links, fix broken links, tree views
- **Multiple Output Modes** - Human-readable with colors, JSON, verbose modes
- **Cross-platform** - Linux, macOS, WSL

For complete feature documentation, see the **[wiki](https://github.com/ctrl-alt-adrian/symlinkit/wiki)**.

---

## Supported Operating Systems

- **Linux** - Works out of the box
- **macOS** - Requires GNU utilities: `brew install coreutils findutils`
- **WSL** - Full support with Windows path handling

---

## Installation

### Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/ctrl-alt-adrian/symlinkit/main/install.sh | bash
```

### Manual Install

```bash
git clone https://github.com/ctrl-alt-adrian/symlinkit.git
cd symlinkit
sudo cp symlinkit /usr/local/bin/
```

For detailed installation options, see the **[Installation Guide](https://github.com/ctrl-alt-adrian/symlinkit/wiki/Installation)** on the wiki.

---

## Flags

```
-c → create mode (safe creation, fails if exists)
-o → overwrite mode
-m → merge mode (recursive)
-d → delete mode (remove symlink)
-r, --recursive → recursive mode (use with -c, -o, or -d)
  -cr → create recursive (same as -m)
  -or → overwrite recursive with prompts
  -dr → delete symlinks in directory interactively
--dry-run → preview, skip conflicts
--dry-run-overwrite → preview, overwrite conflicts
--fzf → force fzf usage (error if not installed)
--no-fzf → disable fzf, use manual prompts only
--tree [DIR] → minimal tree view (symlink arrows only; standalone or after linking)
--tree-verbose [DIR] → verbose tree view (permissions + symlink arrows; standalone or after linking)
--list [DIR] → list symlinks (default: $HOME if DIR not provided)
--broken [DIR] → list broken symlinks (default: $HOME if DIR not provided)
--fix-broken [DIR] → interactively fix broken symlinks (delete, update, skip; default $HOME)
--depth N → tree/fix-broken depth (default 3)
--count-only [DIR] → count symlinks only
--sort path|target → sort results
--json → JSON output mode (defaults to list if no other mode specified)
-h, --help → colorized help text
-v, --version → version info
```

---

## Examples

```bash
# Create a new symlink
symlinkit -c ~/dotfiles/config ~/.config

# Merge directory contents recursively
symlinkit -m ~/dotfiles/scripts ~/bin

# Delete a symlink
symlinkit -d ~/.config/nvim

# Preview changes before applying (dry-run)
symlinkit --dry-run -m ~/src/project ~/deploy

# Disable fzf interactive selection
symlinkit --no-fzf -c ~/dotfiles/.bashrc ~
```

For more examples and advanced usage, see the **[Usage Examples](https://github.com/ctrl-alt-adrian/symlinkit/wiki/Usage-Examples)** wiki page.

---

## Testing

Run the test suite to verify functionality:

```bash
./tests/simple_test.sh
```

For detailed testing documentation, see the **[Testing Framework](https://github.com/ctrl-alt-adrian/symlinkit/wiki/Testing-Framework)** wiki page.

---

## Contributing

Contributions are welcome!

```bash
# Fork and clone
git clone https://github.com/YOUR-USERNAME/symlinkit.git
cd symlinkit

# Test your changes
./tests/simple_test.sh
```

CI/CD runs tests on every pull request and all tests must pass before merging.

For detailed contributing guidelines, see the **[Contributing Guide](https://github.com/ctrl-alt-adrian/symlinkit/wiki/Contributing)** on the wiki.

---

## Reporting Issues

Found a bug or have a feature request?

- 🐛 [Report Bug](https://github.com/ctrl-alt-adrian/symlinkit/issues/new?labels=bug)
- ✨ [Request Feature](https://github.com/ctrl-alt-adrian/symlinkit/issues/new?labels=enhancement)
- 📚 [Ask Question](https://github.com/ctrl-alt-adrian/symlinkit/discussions)

When reporting, include your OS, symlinkit version (`./symlinkit --version`), and steps to reproduce.

---

## Requirements

**Required:** None - symlinkit works out of the box

**Optional:**
- `fzf` - Enhanced interactive selection
- `tree` - Tree view modes
- `jq` - JSON output formatting

**macOS:** Install GNU utilities via Homebrew:
```bash
brew install coreutils findutils
```

---

## Documentation

For comprehensive guides and detailed documentation, visit the **[symlinkit Wiki](https://github.com/ctrl-alt-adrian/symlinkit/wiki)**.

---

## License

Licensed under the [MIT License](LICENSE).
