# Usage Examples & Workflows

This page provides comprehensive examples of how to use symlinkit effectively across different scenarios and workflows.

## 📋 Table of Contents
- [Basic Operations](#basic-operations)
- [Interactive Selection Examples](#interactive-selection-examples)
- [Dotfiles Management](#dotfiles-management)
- [System Administration](#system-administration)
- [Development Workflows](#development-workflows)
- [Inspection & Maintenance](#inspection--maintenance)
- [JSON Output & Scripting](#json-output--scripting)
- [Advanced Scenarios](#advanced-scenarios)

---

## 🎯 Basic Operations

### Simple Symlink Creation
```bash
# Create a single symlink (overwrite mode)
symlinkit -o ~/dotfiles/.zshrc ~/.zshrc

# Create symlinks for directory contents (merge mode)
symlinkit -m ~/dotfiles/scripts ~/bin

# Preview before making changes
symlinkit --dry-run -o ~/dotfiles/nvim ~/.config/nvim
```

### Interactive Mode
```bash
# Let symlinkit guide you through selection
symlinkit -o
# → You'll be prompted to select source and destination

# Interactive with mode selection
symlinkit
# → Select source, destination, then choose overwrite/merge/cancel
```

---

## 🖱️ Interactive Selection Examples

### With fzf (Enhanced Experience)
```bash
# Use fzf for interactive selection (default if fzf available)
symlinkit --list
# → Shows fuzzy-searchable directory list with preview

# Force fzf usage (error if not available)
symlinkit --fzf --broken
# → Ensures consistent fzf experience in scripts
```

### Manual Prompts (Fallback)
```bash
# Force manual text input prompts
symlinkit --no-fzf --list
# → Shows: "Specify a directory to list symlinks: "
# → You type: ~/dotfiles

# Useful for minimal environments or scripts
symlinkit --no-fzf -o
# → "Specify source directory: " → ~/source
# → "Specify destination directory: " → ~/target
```

---

## 🏠 Dotfiles Management

### Initial Setup
```bash
# Set up your entire dotfiles directory
cd ~/
symlinkit -m ~/dotfiles .
# → Merges all dotfiles into home directory

# Preview the operation first
symlinkit --dry-run -m ~/dotfiles .
# → Shows what would be linked without making changes
```

### Selective Dotfile Linking
```bash
# Link specific config directories
symlinkit -o ~/dotfiles/.zshrc ~/.zshrc
symlinkit -o ~/dotfiles/.vimrc ~/.vimrc
symlinkit -m ~/dotfiles/.config ~/.config

# With tree view to see results
symlinkit -o ~/dotfiles/tmux ~/.config/tmux --tree
```

### Dotfile Maintenance
```bash
# Find broken dotfile links
symlinkit --broken ~
# → Shows any broken symlinks in home directory

# Interactive repair
symlinkit --fix-broken ~
# → For each broken link: [d]elete / [u]pdate / [s]kip

# Audit all dotfile symlinks
symlinkit --json --list ~ > dotfiles-audit.json
```

---

## ⚙️ System Administration

### System-wide Symlink Management
```bash
# Audit system symlinks
symlinkit --list /usr/local/bin
symlinkit --broken /etc

# Count symlinks in various directories
symlinkit --count-only /usr/bin
symlinkit --count-only /opt
```

### Service Configuration
```bash
# Link service configurations
symlinkit -o ~/configs/nginx.conf /etc/nginx/nginx.conf
symlinkit -m ~/configs/systemd /etc/systemd/system

# Preview system changes (recommended)
symlinkit --dry-run -m ~/configs/services /etc/systemd/system
```

### Maintenance Scripts
```bash
#!/bin/bash
# Weekly symlink health check
echo "Checking for broken symlinks..."
symlinkit --broken / 2>/dev/null | tee broken-links-$(date +%Y%m%d).log

# Generate system symlink report
symlinkit --json --list /usr/local/bin > "system-symlinks-$(date +%Y%m%d).json"
```

---

## 💻 Development Workflows

### Project Setup
```bash
# Link development tools
symlinkit -m ~/dev-tools/bin ~/bin

# Link project-specific configs
symlinkit -o ~/projects/myapp/.eslintrc ~/.eslintrc
symlinkit -o ~/projects/myapp/.prettierrc ~/.prettierrc
```

### Multi-Environment Management
```bash
# Development environment
symlinkit -o ~/configs/dev/vimrc ~/.vimrc

# Production environment
symlinkit -o ~/configs/prod/vimrc ~/.vimrc

# Preview environment switch
symlinkit --dry-run -o ~/configs/staging/nginx.conf /etc/nginx/nginx.conf
```

### Build Tool Integration
```bash
# Link build outputs
symlinkit -m ~/project/dist ~/public/assets

# With confirmation via tree view
symlinkit -m ~/project/dist ~/public/assets --tree-verbose
```

---

## 🔍 Inspection & Maintenance

### Health Monitoring
```bash
# Regular health check
symlinkit --broken ~
symlinkit --broken /usr/local/bin
symlinkit --broken /opt

# Count-only for quick stats
symlinkit --count-only ~ && echo "symlinks in home"
symlinkit --count-only /usr/bin && echo "symlinks in /usr/bin"
```

### Visual Inspection
```bash
# Tree view of symlinks only
symlinkit --tree ~/.config
symlinkit --tree /usr/local/bin

# Detailed tree with permissions
symlinkit --tree-verbose ~/.config
```

### Interactive Repair Workflows
```bash
# Fix broken links with guided prompts
symlinkit --fix-broken ~
# For each broken link:
# [d]elete → Remove the broken symlink
# [u]pdate → Point to a new target (with optional fzf picker)
# [s]kip   → Leave unchanged

# Limit search depth for performance
symlinkit --depth 2 --fix-broken ~/projects
```

---

## 📊 JSON Output & Scripting

### Basic JSON Operations
```bash
# List all symlinks as JSON
symlinkit --json --list ~

# Find broken symlinks as JSON
symlinkit --json --broken /usr/local/bin

# Count symlinks with metadata
symlinkit --json --count-only ~/.config
```

### Scripting Examples
```bash
#!/bin/bash
# Automated symlink audit script

# Generate comprehensive report
{
  echo "{"
  echo "  \"timestamp\": \"$(date -Iseconds)\","
  echo "  \"hostname\": \"$(hostname)\","
  echo "  \"home_symlinks\": $(symlinkit --json --list ~),"
  echo "  \"broken_symlinks\": $(symlinkit --json --broken ~),"
  echo "  \"usr_local_bin\": $(symlinkit --json --count-only /usr/local/bin)"
  echo "}"
} > symlink-report-$(date +%Y%m%d).json

# Process with jq if available
if command -v jq >/dev/null 2>&1; then
  cat symlink-report-*.json | jq '.broken_symlinks | length'
  echo "broken symlinks found"
fi
```

### Integration with Other Tools
```bash
# Export to CSV (with jq)
symlinkit --json --list ~ | jq -r '.[] | [.path, .target] | @csv' > symlinks.csv

# Filter specific patterns
symlinkit --json --list ~/.config | jq '.[] | select(.target | contains("dotfiles"))'

# Count by target directory
symlinkit --json --list ~ | jq 'group_by(.target | split("/")[1:2] | join("/")) | map({target: .[0].target | split("/")[1:2] | join("/"), count: length})'
```

---

## 🚀 Advanced Scenarios

### Complex Directory Structures
```bash
# Multi-level directory linking with depth control
symlinkit --depth 5 --tree ~/complex-project

# Selective depth for performance
symlinkit --depth 1 --fix-broken /large-directory
```

### Sorting and Organization
```bash
# Sort by symlink path
symlinkit --sort path --list ~/.config

# Sort by target location
symlinkit --sort target --list ~/bin
```

### Batch Operations with Preview
```bash
# Preview multiple operations
symlinkit --dry-run -m ~/dotfiles/config ~/.config
symlinkit --dry-run -m ~/dotfiles/local ~/.local

# Apply after review
symlinkit -m ~/dotfiles/config ~/.config
symlinkit -m ~/dotfiles/local ~/.local
```

### Error Handling in Scripts
```bash
#!/bin/bash
set -euo pipefail

# Robust script with error handling
if symlinkit --json --broken ~ | jq -e '. | length > 0' >/dev/null; then
  echo "⚠️  Broken symlinks detected!"
  symlinkit --broken ~

  read -p "Fix broken symlinks interactively? (y/N): " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    symlinkit --fix-broken ~
  fi
else
  echo "✅ No broken symlinks found"
fi
```

---

## 🎯 Best Practices

### Safety First
```bash
# Always preview significant changes
symlinkit --dry-run -m ~/dotfiles ~/.config

# Use depth limits for large directories
symlinkit --depth 3 --list /usr

# Keep backups before major linking operations
cp -r ~/.config ~/.config.backup
symlinkit -m ~/dotfiles/config ~/.config
```

### Performance Optimization
```bash
# Limit depth for faster operations
symlinkit --depth 2 --broken /

# Use count-only for quick statistics
symlinkit --count-only /usr/bin

# Target specific directories instead of root
symlinkit --list /usr/local/bin  # Fast
symlinkit --list /                # Slow
```

### Maintenance Automation
```bash
# Weekly cron job for symlink health
0 9 * * 1 symlinkit --broken ~ | mail -s "Weekly Symlink Report" admin@example.com

# Monthly audit with JSON logging
0 0 1 * * symlinkit --json --list ~ > ~/logs/symlinks-$(date +\%Y\%m).json
```

---

## 🔧 Troubleshooting Common Scenarios

### Permission Issues
```bash
# Check permissions before linking
ls -la ~/dotfiles/config
symlinkit --dry-run -o ~/dotfiles/config ~/.config

# Use tree-verbose to see permissions
symlinkit --tree-verbose ~/.config
```

### Path Resolution Issues
```bash
# Verify paths are resolved correctly
symlinkit --list ~/.config | head -5

# Check for absolute vs relative targets
symlinkit --json --list ~/.config | jq '.[] | select(.target | startswith("/") | not)'
```

### fzf Availability Issues
```bash
# Test fzf availability
symlinkit --fzf --version  # Errors if fzf missing

# Force manual mode
symlinkit --no-fzf --list  # Always works

# Check current mode
command -v fzf && echo "fzf available" || echo "fzf not available"
```

---

*Need more examples? Check the [[Contributing]] page to suggest new use cases or contribute your own examples!*