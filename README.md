# 🏠 My Dotfiles

Personal configuration files for my development environment on Bazzite Linux.

## 📦 What's Included

- **Bash**: Custom `.bashrc` with useful aliases and settings
- **Git**: Global git configuration with user settings and ignore patterns
- **Alacritty**: Terminal emulator configuration with TokyoNight theme
- **Neovim**: Full NvChad-based configuration with LSP setup
- **Warp Terminal**: Modern terminal preferences and settings

## 🚀 Quick Setup

### Prerequisites

- Git
- Bash
- Neovim (for nvim config)
- Alacritty (for terminal config)
- JetBrains Mono Nerd Font (for proper icons)

### Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/livepatrone/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```

2. Run the install script:
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
├── alacritty/          # Alacritty terminal configuration
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

### Alacritty
```bash
mkdir -p ~/.config/alacritty
ln -sf ~/dotfiles/alacritty ~/.config/alacritty
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

## 🎨 Features

### Alacritty Terminal
- **Theme**: TokyoNight color scheme
- **Font**: JetBrains Mono Nerd Font
- **Opacity**: 95% for subtle transparency
- **Key bindings**: Standard copy/paste and font size controls

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
