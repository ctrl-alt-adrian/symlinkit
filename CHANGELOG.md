# Changelog

All notable changes to this project will be documented in this file.
This project adheres to [Conventional Commits](https://www.conventionalcommits.org).

## [1.4.1] - 2025-09-29

### 📝 Documentation

- Added **Contributing** section to README:
  - Development setup instructions
  - Testing workflow
  - Submitting changes (branching, commits, PRs)
  - Contribution categories (bug fixes, features, docs, tests, refactoring)

## [1.4.0] - 2025-09-29

### 🚀 Major Features

- **Enhanced JSON support**: `--json` flag now works with all inspection modes (`--list`, `--broken`, `--count-only`).
- **Smart JSON defaults**: `symlinkit --json [DIR]` automatically enables list mode for read-only JSON output.
- **JSON fallback formatting**: Works without `jq` dependency using built-in formatting.
- **Test generation system**: Added `generate-tests.sh` to create comprehensive test suites locally without cluttering the repository.

### 🔧 Improvements

- **Consistent permission handling**: Added `check_permission_errors()`, `safe_find()`, and `safe_find_print0()` helper functions.
- **Enhanced error reporting**: All modes now consistently handle and report permission errors.
- **DRY code principles**: Unified permission handling across all operations.
- **Better helper organization**: All helper functions properly documented and organized.

### 🐛 Fixes

- **Critical JSON behavior**: Fixed `--json` flag incorrectly triggering symlink creation instead of read-only listing.
- **Interactive mode logic**: Fixed `--json` with directory arguments no longer prompting for directory selection.
- **Path resolution**: Fixed `realpath_wrap()` backslash replacement pattern for better cross-platform support.
- **Permission handling**: Unified error handling patterns across all inspection modes.

### 🗑️ Removed

- **`--overview` flag**: Removed in favor of `--tree` and `--tree-verbose` modes.

### 📝 Documentation

- Updated **README.md** with new JSON functionality and removed `--overview` references.
- Enhanced **examples section** with proper JSON usage patterns.
- Updated **dependencies** to reflect optional `jq` requirement.

---

## [1.3.0] - 2025-09-28

### Added

- New `--tree-verbose` mode: shows permissions + symlink arrows, works standalone or after linking.
- `--tree` is now minimal by default (symlink arrows only), also usable standalone.
- `--depth` now applies to `--fix-broken` interactive picker (fzf search limited by depth).
- OS detection for Linux, macOS, and WSL. Added graceful fallbacks for `realpath` and `find` (macOS/WSL).
- README: Added **Supported Operating Systems** section.
- README: Added **compatibility badges** (Linux, macOS, WSL).
- README: Added **Table of Contents** for easier navigation.

### Changed

- `--tree` behavior clarified: no longer only a post-link display, can be run standalone (`symlinkit --tree DIR`).
- `--depth` description updated to reflect usage across overview, tree, and fix-broken.
- README: Expanded **Requirements** section with OS-specific installation notes.

### Fixed

- More portable path resolution with `realpath_wrap` and `find_wrap`.
- Safer handling of broken symlink targets during fix/update.
- Unified dry-run output consistency across overwrite/merge/fix-broken.

---

## [1.2.0] - 2025-09-28

### ✨ Features

- Added **`--fix-broken [DIR]`**: interactively fix broken symlinks (delete, update, or skip).
  - Defaults to `$HOME` if no directory is passed.
  - Supports `fzf` for selecting new targets.
  - Includes a summary of deleted, updated, and skipped links.
  - Supports `--dry-run` mode.
- Refined **`--overview`**:
  - Now shows **only symlinks** in tree mode (filters out non-symlinks).
  - Falls back to a flat symlink list if `tree` is not installed.
- Colorized outputs across `--list`, `--broken`, and `--overview` fallback:
  - **Path** → Cyan
  - **Target** → Magenta
- Sorting by `--sort path|target` supported across listings.

### 📝 Documentation

- Updated **README** with new usage examples for `--fix-broken` and `--overview`.
- Updated **man page** (`symlinkit.1`) with new flags and version bump.
- Clarified default behavior: `$HOME` is used if no directory is specified.

---

## [1.1.2] - 2025-09-28

### ✨ Features

- Added colorized output for `--list`, `--broken`, and `--overview` (fallback mode):
  - Symlink **path** → cyan
  - Arrow (`->`) → neutral
  - Symlink **target** → magenta
- Simplified `--list` and `--broken` output to `path -> target` format (replacing verbose `ls -l` style).
- `--overview` now prefers `tree` for symlink visualization by default, falling back to `find` only if `tree` is not installed.

### 📝 Documentation

- Updated manpage version to **1.1.2**.
- README examples clarified with default `$HOME` behavior and symlink listing examples.

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
