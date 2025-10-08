#!/usr/bin/env bash
# Simple dotfiles installer

set -euo pipefail

echo "🏠 Installing dotfiles..."

# Check if we're in the right directory
if [ ! -f "bootstrap-dotfiles.sh" ]; then
    echo "❌ Error: Please run this from the dotfiles directory"
    exit 1
fi

# Make bootstrap scripts executable
chmod +x bootstrap-dotfiles.sh bootstrap-nvim.sh

# Run bootstrap scripts
echo "📝 Setting up dotfiles..."
./bootstrap-dotfiles.sh

echo "🚀 Setting up Neovim..."
./bootstrap-nvim.sh

echo "✅ Dotfiles installation complete!"
echo ""
echo "📌 Next steps:"
echo "   • Restart your terminal or source ~/.bashrc"
echo "   • Open Neovim and let plugins install"
echo "   • Make sure you have JetBrains Mono Nerd Font installed"
