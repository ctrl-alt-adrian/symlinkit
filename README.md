# symlinkit

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/ctrl-alt-adrian/symlinkit)

A small command-line tool that makes working with symlinks less of a hassle.  
It supports interactive directory picking (via [fzf](https://github.com/junegunn/fzf)), recursive linking, overwrite/merge modes, safe dry-runs, and advanced inspection tools to manage existing symlinks on your system.

Originally built to manage dotfiles, it works anywhere you need to symlink directories.

---

## Features

- Interactive source/destination picking with `fzf`
- Merge mode → recursively symlink contents of a directory
- Overwrite mode → replace existing files/folders
- Dry-run support → see what _would_ happen before committing
- `tree` output for destination structure (`--tree`)
- List symlinks (`--list [DIR]`)
- List broken symlinks (`--broken [DIR]`)
- Show symlink overview (`--overview [DIR]`, uses `tree` if available, falls back to `find`)
- Depth control for overview (`--depth N`, default 3)
- Count symlinks only (`--count-only [DIR]`)
- Sorting (`--sort path|target`)
- JSON output (`--json`) for scripting/automation
- Integrated `fzf` preview mode for browsing results interactively
- Colorized `--help` output
- Version flag (`-v`, `--version`)
- Includes a man page (`man symlinkit`)

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

Man Page

The repo includes a manual page under man/symlinkit.1.

To install it:

```bash
sudo cp man/symlinkit.1 /usr/local/share/man/man1/
sudo mandb /usr/local/share/man
```

Then

```bash
man symlinkit
```

If you don’t pass SOURCE or DESTINATION, you’ll be prompted to pick them with fzf.
If you don’t specify -o or -m, and the target exists, you’ll be asked interactively.

Flags

-o → overwrite mode

-m → merge mode (recursive)

--dry-run → preview, skip conflicts

--dry-run-overwrite → preview, overwrite conflicts

--tree → show final destination tree

--list [DIR] → list symlinks (default $HOME)

--broken [DIR] → list broken symlinks

--overview [DIR] → symlink overview (tree/find)

--depth N → overview depth (default 3)

--count-only [DIR] → count symlinks only

--sort path|target → sort results

--json → JSON output mode

-h, --help → colorized help text

-v, --version → version info

Examples

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

# Overview of symlinks in ~/bin at depth 2
symlinkit --overview ~/bin --depth 2

# Count symlinks in $HOME
symlinkit --count-only ~

# JSON output of symlinks under /usr/local/bin
symlinkit --json --list /usr/local/bin
```

Requirements

fzf → required for interactive selection
tree (optional, for --tree and --overview)
realpath (from GNU coreutils) → required
jq→ required for JSON output
