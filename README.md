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

- **Smart Interactive Selection** → Auto-detects fzf, falls back to manual prompts if not available
- **fzf Control** → Force fzf usage (`--fzf`) or disable it (`--no-fzf`) as needed
- **Create mode** → safely create new symlinks without overwriting existing files
- **Delete mode** → safely remove symlinks with verification
- **Merge mode** → recursively symlink directory contents
- **Overwrite mode** → replace existing files/folders
- **Dry-run support** → see what _would_ happen before committing
- **Operation flags required** → explicit `-c`, `-o`, `-m`, or `-d` required for creation/deletion operations
- `--list [DIR]` → list symlinks (default `$HOME`), with `path -> target` output
- `--broken [DIR]` → list **broken** symlinks (default `$HOME`)
- `--fix-broken [DIR]` → interactively fix broken symlinks (delete, update, skip)
- `--count-only [DIR]` → print only the count of symlinks
- `--depth N` → limit tree/fix-broken depth (default 3)
- `--sort path|target` → sort by path or target
- `--json` → JSON output for list/broken/count modes (defaults to list if no mode specified)
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
git clone https://github.com/ctrl-alt-adrian/symlinkit.git
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

**Operation flags are required**: You must specify an operation flag (`-c`, `-o`, `-m`, or `-d`) when creating or deleting symlinks. Running `symlinkit` without an operation will show a helpful error message listing available operations.

If you don't pass SOURCE or DESTINATION, you'll be prompted to pick them interactively:
- **With fzf** (if available): Interactive fuzzy finder with preview
- **Without fzf**: Manual prompts asking you to type directory paths

**Inspection commands** like `--list`, `--tree`, `--broken`, etc. do not require operation flags.

---

## Flags

```
-c → create mode (safe creation, fails if exists)
-o → overwrite mode
-m → merge mode (recursive)
-d → delete mode (remove symlink)
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
# Create a new symlink (safe, fails if exists)
symlinkit -c ~/dotfiles/config ~/.config

# Overwrite ~/.config/config with ~/dotfiles/config
symlinkit -o ~/dotfiles/config ~/.config

# Merge ~/dotfiles/scripts into ~/bin/scripts
symlinkit -m ~/dotfiles/scripts ~/bin

# Delete a symlink
symlinkit -d ~/.config/nvim

# Preview delete (dry-run)
symlinkit --dry-run -d ~/.local/bin/old-link

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

# Count symlinks in $HOME
symlinkit --count-only ~

# JSON output of symlinks under /usr/local/bin
symlinkit --json /usr/local/bin

# JSON output of broken symlinks
symlinkit --json --broken ~/bin

# JSON count of symlinks
symlinkit --json --count-only ~/projects

# Use fzf even if system settings disable it
symlinkit --fzf --list

# Force manual prompts even if fzf is available
symlinkit --no-fzf --broken ~/dotfiles

# Minimal tree of ~/.config
symlinkit --tree ~/.config

# Verbose tree (permissions + symlinks) of ~/.config
symlinkit --tree-verbose ~/.config
```

---

## Testing

symlinkit includes a comprehensive test suite to verify functionality across different environments. Tests are generated locally to keep the repository clean.

### Quick Testing

```bash
# Get help on test generation
./generate-tests.sh -h

# Generate test files
./generate-tests.sh

# Make test scripts executable
chmod +x *.sh

# Get help on test runner
./run_tests.sh -h

# Run all tests
./run_tests.sh

# Run individual test suites
./simple_test.sh           # Basic functionality tests
./test_json_fallback.sh     # JSON functionality without jq
```

### Test Requirements

- **Optional**: `fzf`, `tree`, `jq` (tests gracefully skip missing dependencies)
- **Supported OS**: Linux, macOS (including WSL)
- **Unsupported**: Windows native (tests will skip with clear messaging)

### What Gets Tested

- ✅ **Core Commands**: Version, help, basic flag parsing
- ✅ **JSON Functionality**: List, broken, count modes with/without jq
- ✅ **Symlink Operations**: Create, overwrite, merge, delete (dry-run and actual)
- ✅ **List Operations**: Standard and verbose list modes
- ✅ **Tree Operations**: Standard and verbose tree views
- ✅ **Cross-platform Compatibility**: OS detection and graceful handling
- ✅ **Error Handling**: Invalid flags, missing dependencies, existing targets

### Test Output

The test suite provides colored output with clear pass/fail indicators:
- 🟢 **Green**: Passed tests
- 🔴 **Red**: Failed tests
- 🟡 **Yellow**: Skipped tests (missing dependencies/unsupported OS)
- 🔵 **Blue**: Section headers and information

---

## Contributing

Contributions are welcome! Here's how to get started:

### Development Setup

```bash
# 1. Fork and clone the repository
git clone https://github.com/YOUR-USERNAME/symlinkit.git
cd symlinkit

# 2. Make the script executable
chmod +x symlinkit

# 3. Generate and run tests
./generate-tests.sh
./run_tests.sh
```

### Making Changes

1. **Test your changes**: Always run the test suite before submitting
2. **Follow conventions**: Match existing code style and patterns
3. **Update documentation**: Update README, man page, and CHANGELOG as needed
4. **Test across platforms**: Verify compatibility on Linux/macOS if possible

### Testing

Always run the test suite before submitting changes. See the [Testing](#testing) section above for complete instructions.

### Submitting Changes

1. **Create a feature branch**: `git checkout -b feature/your-feature`
2. **Make your changes** with proper commit messages
3. **Test thoroughly** on your target platform(s)
4. **Update version info** in `symlinkit`, `CHANGELOG.md`, and `man/symlinkit.1`
5. **Submit a pull request** with a clear description

### What to Contribute

- 🐛 **Bug fixes**: Issues with existing functionality
- ✨ **New features**: Additional symlink management capabilities
- 📚 **Documentation**: Improvements to README, man page, or code comments
- 🧪 **Tests**: Additional test coverage or test improvements
- 🎨 **Code quality**: Refactoring, optimization, or style improvements

---

## Reporting Issues

Found a bug or have a feature request? We'd love to hear from you!

### Before Reporting

1. **Check existing issues**: Search [GitHub Issues](https://github.com/ctrl-alt-adrian/symlinkit/issues) to see if it's already reported
2. **Test with latest version**: Ensure you're using the most recent release
3. **Run the test suite**: Generate and run tests to help isolate the issue:
   ```bash
   ./generate-tests.sh
   ./run_tests.sh
   ```

### What to Include

- **Environment**: OS, version, shell (bash/zsh)
- **symlinkit version**: Run `./symlinkit --version`
- **Steps to reproduce**: Clear, minimal example
- **Expected vs actual behavior**: What should happen vs what does happen
- **Test results**: Include relevant test output if applicable

### Quick Links

- 🐛 [Report Bug](https://github.com/ctrl-alt-adrian/symlinkit/issues/new?labels=bug)
- ✨ [Request Feature](https://github.com/ctrl-alt-adrian/symlinkit/issues/new?labels=enhancement)
- 📚 [Ask Question](https://github.com/ctrl-alt-adrian/symlinkit/discussions)

---

## Requirements

- **Required**: None! symlinkit works out-of-the-box
- **realpath** → Usually pre-installed (`grealpath` on macOS via Homebrew)
- **fzf** → Optional, for enhanced interactive selection (fallback to manual prompts)
- **tree** → Optional, for `--tree` and `--tree-verbose`
- **jq** → Optional, for `--json` (fallback formatting available without jq)

**OS Notes:**

- Linux → usually preinstalled; install missing tools via your package manager
- macOS → install GNU utilities:
  ```bash
  brew install coreutils findutils tree jq fzf
  ```
- WSL → same as Linux; Windows paths handled via `wslpath`

---

## Documentation

For detailed guides and comprehensive documentation, visit the **[symlinkit Wiki](https://github.com/ctrl-alt-adrian/symlinkit/wiki)**.

### Wiki Pages
- [Installation Guide](https://github.com/ctrl-alt-adrian/symlinkit/wiki/Installation)
- [Quick Start](https://github.com/ctrl-alt-adrian/symlinkit/wiki/Quick-Start)
- [Symlink Modes](https://github.com/ctrl-alt-adrian/symlinkit/wiki/Symlink-Modes)
- [Interactive Selection](https://github.com/ctrl-alt-adrian/symlinkit/wiki/Interactive-Selection)
- [Inspection Tools](https://github.com/ctrl-alt-adrian/symlinkit/wiki/Inspection-Tools)
- [Advanced Features](https://github.com/ctrl-alt-adrian/symlinkit/wiki/Advanced-Features)
- [API Reference](https://github.com/ctrl-alt-adrian/symlinkit/wiki/API-Reference)

---

## License

Licensed under the [MIT License](LICENSE).
