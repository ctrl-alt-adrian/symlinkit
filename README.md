# symlinkit

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A small command-line tool that makes working with symlinks less of a hassle.  
It supports interactive directory picking (via [fzf](https://github.com/junegunn/fzf)), recursive linking, overwrite/merge modes, and safe dry-runs so you can preview before touching your files.

I originally built this to manage my dotfiles, but it works anywhere you need to symlink directories.

---

## Features

- Interactive source/destination picking with `fzf`
- Merge mode → recursively symlink contents of a directory
- Overwrite mode → replace existing files/folders
- Dry-run support → see what _would_ happen before committing
- Optional `tree` output to show the result
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

--tree → show final directory tree

-h, --help → help text

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
```

Requirements

- fzf → for interactive selection
- tree (optional, for --tree)
- realpath (from coreutils)
