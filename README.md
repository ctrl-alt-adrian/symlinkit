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
- [Testing](#testing)
- [Contributing](#contributing)
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

# Count symlinks in $HOME
symlinkit --count-only ~

# JSON output of symlinks under /usr/local/bin
symlinkit --json /usr/local/bin

# JSON output of broken symlinks
symlinkit --json --broken ~/bin

# JSON count of symlinks
symlinkit --json --count-only ~/projects

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

- **Required**: `fzf` (for interactive functionality)
- **Optional**: `tree`, `jq` (tests gracefully skip missing dependencies)
- **Supported OS**: Linux, macOS (including WSL)
- **Unsupported**: Windows native (tests will skip with clear messaging)

### What Gets Tested

- ✅ **Core Commands**: Version, help, basic flag parsing
- ✅ **JSON Functionality**: List, broken, count modes with/without jq
- ✅ **Symlink Operations**: Dry-run, overwrite, list, broken detection
- ✅ **Cross-platform Compatibility**: OS detection and graceful handling
- ✅ **Error Handling**: Invalid flags, missing dependencies

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

The project uses a test generation system to keep the repository clean:

```bash
# Generate test files locally
./generate-tests.sh

# Make test scripts executable
chmod +x *.sh

# Run all tests
./run_tests.sh

# Run specific test suites
./simple_test.sh           # Basic functionality
./test_json_fallback.sh     # JSON edge cases
```

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

## Requirements

- fzf → required for interactive selection
- realpath → required (`grealpath` on macOS via Homebrew)
- tree → optional, for `--tree` and `--tree-verbose`
- jq → optional, for `--json` (fallback formatting available without jq)

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
