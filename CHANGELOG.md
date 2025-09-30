# Changelog

All notable changes to this project will be documented in this file.
This project adheres to [Conventional Commits](https://www.conventionalcommits.org).

## [1.8.2] - 2025-09-30

### 🐛 Fixes

- **Help output cleanup**: Fixed `--help` output showing internal code comments
  - Previously showed section headers like "--- configuration ---", "--- os detection ---", etc.
  - Now cleanly stops after the flags section
  - Help command now only displays the header comment block

## [1.8.1] - 2025-09-30

### 🚀 Features

- **Automated Install Script**: Added `install.sh` for one-command installation
  - Installs to `~/bin` automatically
  - Updates shell configuration (`.bashrc`/`.zshrc`)
  - Installs man page to `~/.local/share/man/man1/`
  - No prompts or choices - streamlined experience
  - Usage: `curl -fsSL https://raw.githubusercontent.com/ctrl-alt-adrian/symlinkit/main/install.sh | bash`

### 📚 Documentation

- **README**: Added Quick Install section with curl command
- **Wiki - Installation**: Added automated install script as recommended method
- **Wiki - Inspection Tools**: Documented `[a]ll` option for `--fix-broken`
- **Wiki - Usage Examples**: Added dry-run examples for `--fix-broken`
- **Man Page**: Updated `--fix-broken` documentation to include `[a]ll` option and dry-run support

### ✅ Verification

- Confirmed `--fix-broken` already supports `--dry-run` and `[a]ll delete` option
- All 31 tests passing (37 assertions)

## [1.8.0] - 2025-09-30

### 🚀 Major Features

- **Flag Chaining**: New shorthand syntax for combining operations with recursive mode
  - **`-cr` or `-rc`**: Create recursive (equivalent to `-m` merge mode)
  - **`-or` or `-ro`**: Overwrite recursive with interactive prompts
  - **`-dr` or `-rd`**: Delete recursive (interactively delete symlinks in directory)
  - Provides more intuitive syntax while maintaining backwards compatibility with `-m`

- **Recursive Delete Mode (`-dr`)**: Interactively delete all symlinks in a directory
  - Interactive prompts: `[d]elete / [a]ll delete / [s]kip / [q]uit`
  - Works with `--dry-run` for safe previewing
  - Source files are always preserved (only symlinks deleted)
  - Summary shows deleted/skipped counts
  - Usage: `symlinkit -dr /path/to/directory`

- **Universal `[a]ll` Option**: All interactive modes now support bulk actions
  - **Merge mode**: `[s]kip / [o]verwrite / [a]ll overwrite / [c]ancel`
  - **Fix-broken mode**: `[d]elete / [a]ll delete / [u]pdate / [s]kip`
  - **Recursive delete**: `[d]elete / [a]ll delete / [s]kip / [q]uit`
  - Press `[a]` once to apply action to all remaining items
  - Consistent UX across all interactive operations

### 🔧 Improvements

- **Enhanced Dry-Run Support**: Comprehensive dry-run verification for delete operations
  - Single delete: Shows "Would delete" without removing link
  - Recursive delete: Shows "Would delete (all)" for bulk operations
  - Fix-broken: Shows "Would delete (all)" for broken link removal
  - All delete modes thoroughly tested with dry-run

- **Better User Experience**: Improved interactive prompts and feedback
  - All modes now show consistent `[a]ll` options
  - Clear "(all)" indicators when bulk mode is active
  - Quit option `[q]uit` added to recursive delete
  - More natural workflow for managing multiple symlinks

### 🐛 Fixes

- **Empty Symlink List Bug**: Fixed false positive showing "Found 1 symlink" with empty results
  - Now correctly shows "No symlinks found in this directory"
  - Fixed in `--list`, `--broken`, `--count-only`, and `--fix-broken` modes
  - Proper empty string detection instead of relying on `wc -l`

- **Permission Error Handling**: Fixed boolean handling in permission error checks
  - Changed from `$has_permission_errors` to `[[ "$has_permission_errors" -eq 0 ]]`
  - Eliminates "command not found" errors
  - Consistent error handling across all modes

### 🧪 Testing

- **Comprehensive Test Coverage**: 37 tests now pass (up from 27)
  - Added tests for flag chaining (`-cr`, `-or`, `-dr`)
  - Added tests for `[a]ll` options across all modes
  - Added tests for dry-run with delete operations
  - Added test for empty symlink list fix
  - Enhanced existing tests for recursive operations

### 📝 Documentation

- **README.md**: Updated with new flag chaining syntax and features
- **man page**: Updated to version 1.8.0 with recursive flag documentation
- **CHANGELOG.md**: Comprehensive documentation of all changes
- **CLAUDE.md**: Updated Interactive Prompts section with all `[a]ll` options
- **Help text**: Updated with `-r, --recursive` usage examples

### 🎯 Breaking Changes

- **None**: All changes are backwards compatible
- `-m` (merge mode) still works exactly as before
- New flag chaining syntax is additive (shortcuts for existing combinations)

---

## [1.7.0] - 2025-09-29

### 🚀 Major Features

- **Create mode (`-c`)**: New safe symlink creation operation
  - Create symlinks without overwriting existing targets
  - Fails gracefully if target already exists with helpful error message
  - Suggests using `-o` (overwrite) or `-m` (merge) for existing targets
  - Supports `--dry-run` mode for safe previewing
  - Interactive selection works for source, destination, or both
  - Usage: `symlinkit -c SOURCE DESTINATION`

### 🎯 Use Cases

Create mode is perfect for:
- **Initial setup**: Creating symlinks for the first time
- **Safe operations**: When you want to ensure nothing gets overwritten
- **Validation**: Verifying targets don't already exist before linking
- **Scripts**: Automated setups that should fail on conflicts rather than overwrite

### 🐛 Fixes

- **Merge mode bug**: Fixed `safe_find` being called with incorrect `--print0` argument placement
  - Changed from `safe_find --print0 "$src" -print0` to `safe_find "$src" -print0`
  - Fixes "unknown predicate" error during merge operations
  - Resolves mapfile null byte handling issues

### 🧪 Testing

- **Comprehensive test coverage**: Added tests for all operation modes
  - Create mode: dry-run, actual operation, error handling
  - Overwrite mode: dry-run and actual operation
  - Merge mode: dry-run and actual operation
  - Delete mode: dry-run and actual operation
  - List-verbose mode: basic functionality
  - Tree modes: both regular and verbose
- **Enhanced test suite**: 25+ tests now pass including all new create mode tests
- **JSON fallback test fix**: Fixed comma separation detection in JSON output tests

### 📝 Documentation

- **README.md**: Updated with `-c` flag, examples, and use cases
- **man page**: Updated to version 1.7.0 with create mode documentation
- **Help text**: Added `-c` flag to built-in help output
- **CHANGELOG.md**: Comprehensive documentation of all changes
- **Wiki**: Updated relevant pages with create mode information

### 🔄 Complete Operation Set

symlinkit now offers a complete set of symlink operations:
- **`-c`** (create): Safe creation, fails if exists
- **`-o`** (overwrite): Replace existing target
- **`-m`** (merge): Recursively symlink contents
- **`-d`** (delete): Remove symlinks safely

---

## [1.6.0] - 2025-09-29

### 🚀 Major Features

- **Delete mode (`-d`)**: New operation to remove symlinks safely
  - Delete individual symlinks with verification
  - Shows symlink target before deletion
  - Supports `--dry-run` mode for safe previewing
  - Usage: `symlinkit -d /path/to/symlink`

### 🎯 Breaking Changes

- **Operation flags now required**: symlinkit now requires an explicit operation flag for creation/deletion
  - **Required flags**: `-o` (overwrite), `-m` (merge), or `-d` (delete)
  - **No automatic defaults**: Running `symlinkit source dest` without a flag now shows an error
  - **Helpful error messages**: Clear guidance listing all available operations and commands
  - **Inspection commands unchanged**: `--list`, `--tree`, `--broken`, etc. still work without operation flags

### 🔧 Improvements

- **Enhanced error messaging**: When no operation is specified, displays a helpful list of:
  - Available operations (`-o`, `-m`, `-d`)
  - Available commands that don't require operations (`--list`, `--broken`, `--tree`, etc.)
- **Better user guidance**: Prevents accidental operations by requiring explicit intent

### 🐛 Fixes

- Fixed shellcheck errors:
  - Removed invalid `local` keyword usage outside functions
  - Removed unused `print_zero` variable from `safe_find()`
  - Split declaration and assignment to avoid masking return values

### 📝 Documentation

- **README.md**: Updated with `-d` flag and new operation requirements
- **man page**: Updated to version 1.6.0 with delete mode documentation
- **Help text**: Added `-d` flag to built-in help output
- **Wiki**: Comprehensive wiki documentation created with 7 new pages:
  - Installation Guide
  - Quick Start
  - Interactive Selection
  - Symlink Modes
  - Inspection Tools
  - Advanced Features
  - API Reference
- **Code style**: Updated section headers from `# === SECTION ===` to `# --- section ---` for more natural appearance
- **Help text**: Removed emojis from header sections for cleaner output

---

## [1.5.1] - 2025-09-29

### 🛠 Chores

- Removed unintended test artifacts:
  - **`symlinkit.backup`**
  - **`symlinkit.original`**
- These files were created during local testing and are not part of the project.
- Updated `.gitignore` to prevent re-adding them in the future.

---

## [1.5.0] - 2025-09-29

### 🚀 Major Features

- **Intelligent fzf Fallback System**: symlinkit now works seamlessly with or without fzf
  - **Auto-detection**: Automatically detects fzf availability and uses it when present
  - **Manual fallback**: Graceful fallback to text input prompts when fzf is unavailable
  - **Smart prompts**: Changes from "Select..." to "Specify..." for manual input modes
  - **Universal compatibility**: All interactive modes work with both fzf and manual input

- **fzf Control Flags**: New flags for fine-grained control over interactive behavior
  - **`--fzf`**: Force fzf usage, error if not installed (for scripts requiring consistent UX)
  - **`--no-fzf`**: Disable fzf even if available, force manual prompts (for minimal environments)
  - **Backwards compatibility**: Default behavior unchanged for existing users

### 🔧 Improvements

- **Robust path resolution**: Fixed potential issues with relative symlink target resolution
  - Relative targets now resolve correctly relative to their symlink directory
  - Prevents incorrect `/root` path prefixes in symlink target display
  - Maintains absolute path handling for existing functionality

- **Better error handling**: Enhanced input validation for manual selection modes
  - EOF detection prevents infinite loops when stdin is exhausted
  - Clear error messages for invalid directory paths
  - Tilde expansion works correctly in manual input mode

- **Enhanced user experience**: Improved prompts and feedback
  - Manual selection prompts are more intuitive and informative
  - Better error recovery and retry mechanisms
  - Consistent behavior across all interactive modes

### 🐛 Fixes

- **Critical path resolution**: Fixed symlink target display incorrectly showing `/root` prefixes
- **Input handling**: Fixed infinite loops in manual selection when input is piped
- **EOF detection**: Manual prompts now properly handle end-of-input scenarios
- **Relative path resolution**: Symlink targets resolve relative to correct base directory

### 📝 Documentation

- **README.md**: Updated with new fzf fallback features and control flags
- **Requirements**: Updated to reflect that fzf is now optional, not required
- **Examples**: Added examples showing `--fzf` and `--no-fzf` usage patterns

### 🎯 Breaking Changes

- **None**: All changes are backwards compatible
- **Requirements**: fzf is now optional instead of required (reduces barrier to entry)

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
