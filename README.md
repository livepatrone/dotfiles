# 🏠 My Dotfiles

Personal configuration files for my development environment on Bazzite Linux.

## 📦 What's Included

- **Bash**: Custom `.bashrc` with useful aliases and settings
- **Git**: Global git configuration with user settings and ignore patterns
- **Neovim**: Full NvChad-based configuration with LSP setup
- **Warp Terminal**: Modern terminal preferences and settings

## 🚀 Quick Setup

### Prerequisites

- Git
- Bash
- Neovim (for nvim config)
- Warp Terminal (for terminal config)
- JetBrains Mono Nerd Font (for proper icons)

### Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/livepatrone/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```

2. Run the install script (it will check dependencies automatically):
   ```bash
   ./install.sh
   ```

   Or run bootstrap scripts individually:
   ```bash
   ./bootstrap-dotfiles.sh
   ./bootstrap-nvim.sh
   ```

## 📁 Structure

```
.
├── nvim/              # Neovim configuration (NvChad based)
├── warp-terminal/     # Warp terminal preferences
├── bashrc             # Bash configuration
├── gitconfig          # Git global configuration
├── gitignore_global   # Global gitignore patterns
├── install.sh         # Simple one-command installer
└── bootstrap-*.sh     # Detailed installation scripts
```

## ⚙️ Manual Setup

If you prefer to set up manually:

### Bash
```bash
ln -sf ~/dotfiles/bashrc ~/.bashrc
```

### Git
```bash
ln -sf ~/dotfiles/gitconfig ~/.gitconfig
ln -sf ~/dotfiles/gitignore_global ~/.gitignore_global
```


### Neovim
```bash
ln -sf ~/dotfiles/nvim ~/.config/nvim
```

### Warp Terminal
```bash
mkdir -p ~/.config/warp-terminal
ln -sf ~/dotfiles/warp-terminal/user_preferences.json ~/.config/warp-terminal/user_preferences.json
```

## 🔍 Dependency Checking

The install scripts automatically check for required applications and provide installation commands for missing dependencies:

- **rpm-ostree packages**: Neovim, Git, Fastfetch
- **Manual installation**: Warp Terminal (from warp.dev)

If dependencies are missing, you'll see helpful commands like:
```bash
sudo rpm-ostree install neovim
# Warp Terminal: Download from https://www.warp.dev/
```

## 🎨 Features


### Neovim
- **Base**: NvChad configuration
- **LSP**: Language server support
- **Plugins**: Managed via Lazy.nvim

### Bash
- **Aliases**: Convenient shortcuts
- **Prompt**: Clean and informative
- **Local config**: Sources `~/.bashrc.local` if available

## 🔄 Updating

To update your dotfiles:

```bash
cd ~/dotfiles
git pull origin main
```

## 🛠️ Development

This repository uses pre-commit hooks for code quality:
- Secret detection
- End-of-file fixing
- Trailing whitespace removal

## 📝 License

Feel free to use these dotfiles as inspiration for your own setup!
