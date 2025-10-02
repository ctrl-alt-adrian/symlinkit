# symlinkit

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/ctrl-alt-adrian/symlinkit)
![Linux](https://img.shields.io/badge/OS-Linux-green?logo=linux)
![macOS](https://img.shields.io/badge/OS-macOS-lightgrey?logo=apple)
![WSL](https://img.shields.io/badge/OS-WSL-blue?logo=windows)

> **📚 [Visit the Wiki](https://github.com/ctrl-alt-adrian/symlinkit/wiki)** for comprehensive guides and tutorials.

**A focused CRUD tool for managing symlinks.** Fast, secure, simple, and **zero dependencies**.

Create, read, update, and delete symlinks with confidence. Built for managing dotfiles and configuration, symlinkit handles the tedious parts of symlink management while keeping things straightforward.

**Interactive prompts** for paths when arguments aren't provided - no external tools required.

## Table of Contents

- [Features](#features)
- [Supported Operating Systems](#supported-operating-systems)
- [Installation](#installation)
- [Uninstall](#uninstall)
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

- **Core CRUD Operations** - Create (`-c`), overwrite (`-o`), merge (`-m`), delete (`-d`)
- **Safe by Default** - Dry-run mode, interactive prompts, security hardening
- **Zero Dependencies** - No external tools required (no fzf, no jq, no tree)
- **Interactive Prompts** - Manual path entry when arguments aren't provided
- **Link Management** - List symlinks (`--list`), find broken links (`--broken`), fix broken links (`--fix-broken`)
- **Cross-platform** - Linux, macOS, WSL

For detailed documentation, see the **[wiki](https://github.com/ctrl-alt-adrian/symlinkit/wiki)**.

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
chmod +x symlinkit
sudo cp symlinkit /usr/local/bin/
```

**Note:** The `chmod +x symlinkit` step is required to make the script executable before copying it.

---

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/ctrl-alt-adrian/symlinkit/main/uninstall.sh | bash
```

This removes `symlinkit`, the man page, and completion scripts.  
Your shell config entries (e.g. `~/.bashrc`, `~/.zshrc`) won’t be auto-edited — remove those lines manually if desired.

For detailed installation and uninstall options, see the **[Installation Guide](https://github.com/ctrl-alt-adrian/symlinkit/wiki/Installation)** on the wiki.

---

## Flags

```
-c, --create           Create mode (safe creation, fails if destination exists)
-o, --overwrite        Overwrite mode (removes existing file/directory, replaces with symlink)
-m, --merge            Merge mode (recursively creates symlinks for source directory contents)
-d, --delete           Delete mode (removes symlink only, does not affect target)
-r, --recursive        Recursive mode (use with -c, -o, or -d)
  -cr                  Create recursive (same as -m)
  -or                  Overwrite recursive with prompts
  -dr                  Delete symlinks in directory interactively
--dry-run              Preview actions without making changes
--list [DIR]           List symlinks in directory (prompts for DIR if not provided)
--broken [DIR]         List broken symlinks (prompts for DIR if not provided)
--fix-broken [DIR]     Interactively fix broken symlinks (delete, update, or skip)
-h, --help             Show help message
-v, --version          Show version info
```

---

## Examples

```bash
# Create a new symlink (fails if ~/.config already exists)
symlinkit -c ~/dotfiles/config ~/.config

# Merge directory contents recursively (creates symlinks inside destination)
symlinkit -m ~/dotfiles/scripts ~/bin

# Delete a symlink (only removes the link, not what it points to)
symlinkit -d ~/.config/nvim

# Preview changes before applying
symlinkit --dry-run -m ~/src/project ~/deploy

# List all symlinks in a directory
symlinkit --list ~/

# Find and fix broken symlinks
symlinkit --fix-broken ~/
```

For more examples, see the **[Usage Examples](https://github.com/ctrl-alt-adrian/symlinkit/wiki/Usage-Examples)** wiki page.

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

When reporting, include your OS, symlinkit version (`./symlinkit -v`), and steps to reproduce.

---

## Requirements

**Required:** None - symlinkit has **zero dependencies** and works out of the box

**macOS:** Install GNU utilities via Homebrew:

```bash
brew install coreutils findutils
```

That's it. No fzf, no jq, no tree, no external tools. Just bash.

---

## Documentation

For comprehensive guides and detailed documentation, visit the **[symlinkit Wiki](https://github.com/ctrl-alt-adrian/symlinkit/wiki)**.

---

## License

Licensed under the [MIT License](LICENSE).
