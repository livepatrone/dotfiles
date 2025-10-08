# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Development Environment Setup

This is a personal dotfiles repository configured for Bazzite Linux (rpm-ostree based) that manages development environment configurations through symlinked dotfiles.

### Core Installation Commands

**Complete setup (recommended)**:
```bash
./install.sh
```

**Individual components**:
```bash
./bootstrap-dotfiles.sh    # Set up bash, git, warp, and desktop environment configs
./bootstrap-nvim.sh        # Install NvChad and configure Neovim
```

**Sync configurations across devices**:
```bash
# Push local changes to repo
syncup                     # Alias: commit and push current configs

# Pull and apply changes from other devices
syncdown                   # Alias: pull and install configs
```

**Device-specific configuration management**:
```bash
sync_device_config         # Save device-specific settings
install_nerd_fonts        # Install JetBrains Mono Nerd Font
backup_current_configs     # Create timestamped backup
```

**Manual dependency installation** (if missing):
```bash
sudo rpm-ostree install neovim git fastfetch
# Warp Terminal: Download from https://www.warp.dev/
```

### Testing and Development

**Pre-commit setup** (for repository maintenance):
```bash
pre-commit install
pre-commit run --all-files
```

**Check for secrets and code quality**:
```bash
pre-commit run gitleaks --all-files
pre-commit run detect-private-key --all-files
```

## Architecture Overview

### Symlink-Based Configuration Management

The repository uses a sophisticated symlink strategy managed by `bootstrap-dotfiles.sh`:

- **Home files**: Direct symlinks from repo root to `$HOME` (e.g., `bashrc` → `~/.bashrc`)  
- **Config directories**: Links to `~/.config/` (e.g., `nvim/` → `~/.config/nvim`)
- **Special cases**: Warp terminal preferences require nested directory structure
- **Device-specific overrides**: Hostname-based configs in `device-configs/` for machine-specific settings

### Dependency Resolution System

The bootstrap script includes automatic dependency checking with three installation methods:
- **rpm-ostree**: System packages (neovim, git, fastfetch)
- **flatpak**: Flatpak applications (currently unused but supported)
- **manual**: Applications requiring manual installation (Warp Terminal)

### NvChad Integration Architecture

Neovim setup follows a two-layer approach:
1. **Base layer**: NvChad starter cloned and `.git` removed to prevent conflicts
2. **Custom layer**: Personal configurations symlinked to `~/.config/nvim/lua/custom/`

This allows for NvChad updates without losing personal configurations.

## Configuration Components

### Bash Configuration
- Uses system `/etc/bashrc` as base
- Supports `~/.bashrc.local` for machine-specific settings
- Loads additional configs from `~/.bashrc.d/` directory
- Sources device-specific configs (`~/.bashrc.device`, `~/.local.env`)
- Includes comprehensive aliases for dotfiles management
- Runs `fastfetch` on shell startup

### Git Configuration
- SSH signing enabled with Ed25519 key (`~/.ssh/id_ed25519.pub`)
- Global gitignore patterns via linked `gitignore_global`
- User: `juan.rios <livejuanrios@gmail.com>`

### Desktop Environment Configuration
- **GTK 3.0/4.0**: Theme, font, and cursor settings synced across devices
- **Fontconfig**: Consistent font rendering and fallback preferences
- **Device overrides**: Per-device display scaling and preferences

### Neovim Setup
- **Base**: NvChad framework with lazy.nvim plugin management
- **Theme**: Tokyo Night (configurable in `custom/init.lua`)
- **Features**: LSP support, relative line numbers, telescope integration
- **Python provider**: Auto-installed via pip for enhanced functionality

### Pre-commit Hooks
Repository maintenance includes:
- **Gitleaks**: Secret scanning with staged file protection
- **Standard hooks**: Private key detection, trailing whitespace, EOF fixing

## File Structure Logic

```
dotfiles/
├── bashrc, gitconfig, gitignore_global    # Direct home symlinks
├── aliases.sh                             # Useful aliases and functions
├── nvim/                                  # Config directory symlink
├── gtk-3.0/, gtk-4.0/                    # Desktop theming configs
├── fontconfig/                            # Font rendering settings
├── warp-terminal/user_preferences.json    # Nested config file
├── device-configs/                        # Hostname-specific overrides
├── bootstrap-*.sh                         # Modular setup scripts
├── install.sh                             # Single-command installer
└── .pre-commit-config.yaml               # Development quality control
```

## Environment Considerations

- **Platform**: Optimized for Bazzite Linux (rpm-ostree based)
- **Package management**: Prefers rpm-ostree for system packages
- **Font dependency**: JetBrains Mono Nerd Font required for proper terminal icons
- **Backup strategy**: Automatic timestamped backups of existing configs before linking