# symlinkit

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/ctrl-alt-adrian/symlinkit)
![Linux](https://img.shields.io/badge/OS-Linux-green?logo=linux)
![macOS](https://img.shields.io/badge/OS-macOS-lightgrey?logo=apple)
![WSL](https://img.shields.io/badge/OS-WSL-blue?logo=windows)

A small command-line tool that makes working with symlinks less of a hassle.  
It supports interactive directory picking (via [fzf](https://github.com/junegunn/fzf)), recursive linking, overwrite/merge modes, safe dry-runs, and advanced inspection tools to manage existing symlinks on your system.

Originally built to manage dotfiles, it works anywhere you need to symlink directories.

## Table of Contents

- [Features](#features)
- [Supported Operating Systems](#supported-operating-systems)
- [Installation](#installation)
- [Flags](#flags)
- [Examples](#examples)
- [Requirements](#requirements)
- [License](#license)

---

## Features

- Interactive source/destination picking with `fzf`
- Merge mode → recursively symlink directory contents
- Overwrite mode → replace existing files/folders
- Dry-run support → see what _would_ happen before committing
- `--list [DIR]` → list symlinks (default `$HOME`), with `path -> target` output
- `--broken [DIR]` → list **broken** symlinks (default `$HOME`)
- `--fix-broken [DIR]` → interactively fix broken symlinks (delete, update, skip)
- `--overview [DIR]` → symlink overview (symlinks only; tree visualization if installed, fallback to flat list)
- `--count-only [DIR]` → print only the count of symlinks
- `--depth N` → limit tree/overview/fix-broken depth (default 3)
- `--sort path|target` → sort by path or target
- `--json` → machine-friendly output for list/broken/overview
- `--tree [DIR]` → minimal tree view (symlink arrows only; standalone or after linking)
- `--tree-verbose [DIR]` → verbose tree view (permissions + symlink arrows; standalone or after linking)
- Colorized output for readability (cyan path, magenta target)
- Includes a man page (`man symlinkit`)

---

## Supported Operating Systems

- **Linux** (tested on major distros)
- **macOS**
  - May require GNU utilities via Homebrew:
    ```bash
    brew install coreutils findutils
    ```
  - Provides `grealpath` and `gfind` if the BSD versions are insufficient.
- **Windows Subsystem for Linux (WSL)**
  - Integrated with `wslpath` for handling Windows-style paths.

---

## Installation

Clone and install locally:

```bash
git clone https://github.com/YOUR-USERNAME/symlinkit.git
cd symlinkit
chmod +x symlinkit
mkdir -p ~/bin
cp symlinkit ~/bin/
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
```

Or install system-wide:

```bash
sudo cp symlinkit /usr/local/bin/
```

### Man Page

The repo includes a manual page under `man/symlinkit.1`.

To install it:

```bash
sudo cp man/symlinkit.1 /usr/local/share/man/man1/
sudo mandb /usr/local/share/man
```

Then:

```bash
man symlinkit
```

If you don’t pass SOURCE or DESTINATION, you’ll be prompted to pick them with fzf.  
If you don’t specify -o or -m, and the target exists, you’ll be asked interactively.

---

## Flags

```
-o → overwrite mode
-m → merge mode (recursive)
--dry-run → preview, skip conflicts
--dry-run-overwrite → preview, overwrite conflicts
--tree [DIR] → minimal tree view (symlink arrows only; standalone or after linking)
--tree-verbose [DIR] → verbose tree view (permissions + symlink arrows; standalone or after linking)
--list [DIR] → list symlinks (default: $HOME if DIR not provided)
--broken [DIR] → list broken symlinks (default: $HOME if DIR not provided)
--fix-broken [DIR] → interactively fix broken symlinks (delete, update, skip; default $HOME)
--overview [DIR] → symlink overview (symlinks only; tree if installed, fallback to flat)
--depth N → overview/tree/fix-broken depth (default 3)
--count-only [DIR] → count symlinks only
--sort path|target → sort results
--json → JSON output mode
-h, --help → colorized help text
-v, --version → version info
```

---

## Examples

```bash
# Overwrite ~/.config/config with ~/dotfiles/config
symlinkit -o ~/dotfiles/config ~/.config

# Merge ~/dotfiles/scripts into ~/bin/scripts
symlinkit -m ~/dotfiles/scripts ~/bin

# Preview merge, skip conflicts
symlinkit --dry-run -m ~/src/project ~/deploy

# Preview merge, overwrite conflicts, show tree
symlinkit --dry-run-overwrite -m --tree ~/dotfiles/custom ~/.custom

# List symlinks under $HOME
symlinkit --list

# List broken symlinks in /etc
symlinkit --broken /etc

# Interactively fix broken symlinks under $HOME
symlinkit --fix-broken

# Overview of symlinks in ~/bin at depth 2 (symlinks only)
symlinkit --overview ~/bin --depth 2

# Count symlinks in $HOME
symlinkit --count-only ~

# JSON output of symlinks under /usr/local/bin
symlinkit --json --list /usr/local/bin

# Minimal tree of ~/.config
symlinkit --tree ~/.config

# Verbose tree (permissions + symlinks) of ~/.config
symlinkit --tree-verbose ~/.config
```

---

## Requirements

- fzf → required for interactive selection
- realpath → required (`grealpath` on macOS via Homebrew)
- tree → optional, for `--tree`, `--tree-verbose`, and `--overview`
- jq → optional, only for `--json`

**OS Notes:**

- Linux → usually preinstalled; install missing tools via your package manager
- macOS → install GNU utilities:
  ```bash
  brew install coreutils findutils tree jq fzf
  ```
- WSL → same as Linux; Windows paths handled via `wslpath`

---

## License

Licensed under the [MIT License](LICENSE).
