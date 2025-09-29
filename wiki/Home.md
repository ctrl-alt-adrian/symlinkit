# symlinkit Wiki

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/ctrl-alt-adrian/symlinkit)
![Linux](https://img.shields.io/badge/OS-Linux-green?logo=linux)
![macOS](https://img.shields.io/badge/OS-macOS-lightgrey?logo=apple)
![WSL](https://img.shields.io/badge/OS-WSL-blue?logo=windows)

Welcome to the **symlinkit** wiki! This is your comprehensive guide to using, understanding, and contributing to symlinkit - the intelligent symlink management tool.

## 🚀 What is symlinkit?

**symlinkit** is a command-line tool designed to make working with symbolic links effortless and intuitive. It provides:

- **🧠 Intelligent Interactive Selection** - Auto-detects fzf availability, falls back gracefully to manual prompts
- **🔀 Flexible Modes** - Overwrite and merge modes for different symlinking strategies
- **🔍 Comprehensive Inspection** - List, find broken links, count, and visualize with tree views
- **🛡️ Safety First** - Dry-run modes to preview changes before applying
- **🌍 Cross-Platform** - Works seamlessly on Linux, macOS, and WSL

Originally designed for dotfiles management, symlinkit excels at any scenario requiring organized symbolic link management.

---

## 📚 Wiki Navigation

### Getting Started
- **[[Installation]]** - Installation methods and requirements
- **[[Quick Start]]** - Get up and running in 5 minutes
- **[[Usage Examples]]** - Common workflows and use cases

### Features & Functionality
- **[[Interactive Selection]]** - Understanding fzf integration and manual fallbacks
- **[[Symlink Modes]]** - Overwrite vs Merge modes explained
- **[[Inspection Tools]]** - List, broken detection, tree views, and JSON output
- **[[Advanced Features]]** - Depth control, sorting, and specialized workflows

### Development & Contributing
- **[[Testing Framework]]** - Understanding and adding tests
- **[[Contributing]]** - Guidelines for contributing with mandatory test requirements
- **[[API Reference]]** - Flag reference and internal architecture

---

## ✨ Key Features Highlighted

### 🎯 Intelligent fzf Integration
```bash
# Automatically uses fzf if available
symlinkit --list

# Force fzf usage (error if not available)
symlinkit --fzf --broken ~/dotfiles

# Disable fzf, use manual prompts
symlinkit --no-fzf --list
```

### 🔧 Flexible Symlink Creation
```bash
# Interactive selection (with fzf or manual prompts)
symlinkit -o

# Direct specification
symlinkit -o ~/dotfiles/config ~/.config

# Merge directory contents
symlinkit -m ~/dotfiles/scripts ~/bin

# Safe preview first
symlinkit --dry-run -m ~/dotfiles/nvim ~/.config
```

### 🔍 Comprehensive Inspection
```bash
# Find all symlinks
symlinkit --list ~/

# Detect broken links
symlinkit --broken ~/

# Interactive repair
symlinkit --fix-broken ~/

# JSON output for scripting
symlinkit --json --broken ~/dotfiles
```

---

## 🛠️ Requirements & Compatibility

### Required
- **None!** symlinkit works out-of-the-box on supported platforms
- `realpath` (usually pre-installed; `grealpath` on macOS via Homebrew)

### Optional (Enhanced Features)
- **fzf** → Enhanced interactive selection (graceful fallback to manual prompts)
- **tree** → Visual tree representations (`--tree`, `--tree-verbose`)
- **jq** → Enhanced JSON formatting (built-in fallback available)

### Supported Platforms
- ✅ **Linux** (all major distributions)
- ✅ **macOS** (with Homebrew for GNU utilities)
- ✅ **WSL** (Windows Subsystem for Linux)
- ❌ **Windows native** (not supported)

---

## 🚀 Quick Examples

### Dotfiles Management
```bash
# Link entire dotfiles directory with interactive selection
symlinkit -m

# Specific config file
symlinkit -o ~/dotfiles/.zshrc ~/.zshrc

# Preview changes first
symlinkit --dry-run -m ~/dotfiles ~/.config
```

### System Administration
```bash
# Find all broken symlinks in system
symlinkit --broken /

# Generate report
symlinkit --json --list /usr/local/bin > symlink_audit.json

# Interactive cleanup
symlinkit --fix-broken /usr/local/bin
```

### Development Workflows
```bash
# Link project scripts
symlinkit -m ~/project/bin ~/bin

# Force manual prompts for automation
symlinkit --no-fzf -o ~/configs/vim ~/.vimrc
```

---

## 📖 Learning Path

New to symlinkit? Follow this learning path:

1. **[[Installation]]** - Get symlinkit installed
2. **[[Quick Start]]** - Create your first symlinks
3. **[[Usage Examples]]** - Explore common scenarios
4. **[[Interactive Selection]]** - Master the selection system
5. **[[Inspection Tools]]** - Learn to analyze existing symlinks
6. **[[Testing Framework]]** - Understand quality assurance (for contributors)

---

## 🤝 Community & Support

- **🐛 Report Issues**: [GitHub Issues](https://github.com/ctrl-alt-adrian/symlinkit/issues)
- **💡 Feature Requests**: [GitHub Issues](https://github.com/ctrl-alt-adrian/symlinkit/issues/new?labels=enhancement)
- **📚 Questions**: [GitHub Discussions](https://github.com/ctrl-alt-adrian/symlinkit/discussions)
- **🔧 Contribute**: See [[Contributing]] (tests required!)

---

## 📄 License

symlinkit is released under the [MIT License](https://github.com/ctrl-alt-adrian/symlinkit/blob/main/LICENSE), making it free for personal and commercial use.

---

*This wiki is actively maintained. Last updated: September 2025 for symlinkit v1.5.0*