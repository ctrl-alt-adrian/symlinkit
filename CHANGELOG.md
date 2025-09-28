# Changelog

All notable changes to this project will be documented in this file.  
This project adheres to [Conventional Commits](https://www.conventionalcommits.org).

## [1.1.1] - 2025-09-28

### ✨ Features

- `--list` and `--broken` now default to **$HOME** when no directory is specified.
- Users can explicitly pass `/` or any directory to scan system-wide or in specific locations.

### 📝 Documentation

- Updated manpage to explicitly state that `--list` and `--broken` default to $HOME.
- README usage section updated with clearer examples for `--list`, `--broken`, and scanning `/`.

---

## [1.1] - 2025-09-28

### ✨ Features

- **symlink inspection tools**: added `--list`, `--broken`, `--overview`, `--count-only`, `--sort`, and `--json` flags
- **help improvements**: added colorized `--help` output
- **flag parser**: improved parsing logic for new flags

### 📝 Documentation

- Updated **README.md** with new flags, examples, and usage notes
- Updated **manpage** with new options, VERSION section, and REPORTING BUGS footer

### 🛠 Chores

- Added `CHANGELOG.md` for version tracking

### 🐛 Fixes

- Switched README version badge from **GitHub releases** to **GitHub tags** for correct display

---

## [1.0] - 2025-09-20

- Initial release with core functionality:
  - Overwrite mode (`-o`)
  - Merge mode (`-m`)
  - Dry-run support (`--dry-run`, `--dry-run-overwrite`)
  - Optional tree view (`--tree`)
  - Interactive selection via `fzf`
