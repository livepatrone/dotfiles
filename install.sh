#!/usr/bin/env bash
# Universal dotfiles installer for Bazzite (rpm-ostree) and Fedora (dnf)
# https://github.com/livepatrone/dotfiles

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print functions
info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; }

# Detect OS type
detect_os() {
    if command -v rpm-ostree &> /dev/null; then
        echo "silverblue"
    elif command -v dnf &> /dev/null; then
        echo "fedora"
    else
        error "Unsupported system. This script requires Fedora or Bazzite/Silverblue."
        exit 1
    fi
}

# Install packages based on OS type
install_packages() {
    local os_type="$1"
    local packages=("git" "zsh" "neovim" "fastfetch" "curl" "ripgrep" "fd-find" "nodejs" "python3-pip")

    info "Installing core packages..."

    if [[ "$os_type" == "silverblue" ]]; then
        info "Detected Silverblue/Bazzite - using rpm-ostree"
        if ! rpm -q "${packages[@]}" &> /dev/null; then
            warning "Some packages need to be installed. This requires a reboot."
            echo "Run: sudo rpm-ostree install ${packages[*]}"
            read -p "Install packages now? (y/N): " -r
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                sudo rpm-ostree install "${packages[@]}"
                warning "Reboot required! Run 'systemctl reboot' then re-run this script."
                exit 0
            else
                warning "Packages not installed. Some features may not work."
            fi
        else
            success "All core packages already installed"
        fi
    elif [[ "$os_type" == "fedora" ]]; then
        info "Detected Fedora Workstation - using dnf"
        sudo dnf install -y "${packages[@]}"
        success "Core packages installed"
    fi
}

# Install Warp Terminal
install_warp() {
    if command -v warp-terminal &> /dev/null; then
        success "Warp Terminal already installed"
        return
    fi

    info "Installing Warp Terminal..."
    local warp_rpm_url="https://releases.warp.dev/stable/v0.2024.11.12.08.02.stable_00/warp-terminal-v0.2024.11.12.08.02.stable_00-1.x86_64.rpm"

    if [[ "$(detect_os)" == "silverblue" ]]; then
        warning "Warp Terminal requires manual installation on Silverblue/Bazzite"
        echo "1. Download: $warp_rpm_url"
        echo "2. Install: sudo rpm-ostree install ./warp-terminal-*.rpm"
        echo "3. Reboot and re-run this script"
    else
        sudo dnf install -y "$warp_rpm_url"
        success "Warp Terminal installed"
    fi
}

# Install Wave (AppImage)
install_wave() {
    local wave_dir="$HOME/.local/bin"
    local wave_path="$wave_dir/wave"

    if [[ -x "$wave_path" ]]; then
        success "Wave already installed"
        return
    fi

    info "Installing Wave terminal..."
    mkdir -p "$wave_dir"

    # Download latest Wave AppImage
    local wave_url="https://dl.waveterm.dev/releases-w2/linux-x64/wave-linux-x64-latest.AppImage"
    curl -L "$wave_url" -o "$wave_path"
    chmod +x "$wave_path"

    # Add to PATH if not already there
    if [[ ":$PATH:" != *":$wave_dir:"* ]]; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    fi

    success "Wave terminal installed to $wave_path"
}

# Install Ollama
install_ollama() {
    if command -v ollama &> /dev/null; then
        success "Ollama already installed"
    else
        info "Installing Ollama..."
        curl -fsSL https://ollama.ai/install.sh | sh
        success "Ollama installed"
    fi

    # Start Ollama service
    if ! systemctl is-active --quiet ollama 2>/dev/null; then
        info "Starting Ollama service..."
        sudo systemctl enable --now ollama || true
    fi

    # Pull required models
    info "Pulling Ollama models (this may take a while)..."
    local models=("llama3.1:8b-instruct-q4_K_M" "qwen2.5-coder:7b-instruct-q4_K_M")

    for model in "${models[@]}"; do
        if ! ollama list | grep -q "${model%:*}"; then
            info "Pulling model: $model"
            ollama pull "$model" || warning "Failed to pull $model - try manually: ollama pull $model"
        else
            success "Model $model already available"
        fi
    done
}

# Clone or update dotfiles repository
setup_dotfiles_repo() {
    local dotfiles_dir="$HOME/.dotfiles"
    local repo_url="https://github.com/livepatrone/dotfiles.git"

    if [[ -d "$dotfiles_dir" ]]; then
        info "Updating existing dotfiles repository..."
        cd "$dotfiles_dir"
        git pull --rebase || warning "Failed to update dotfiles - continuing with current version"
    else
        info "Cloning dotfiles repository..."
        git clone "$repo_url" "$dotfiles_dir"
    fi

    cd "$dotfiles_dir"
    chmod +x install.sh bootstrap-dotfiles.sh bootstrap-nvim.sh sync-dotfiles 2>/dev/null || true
    success "Dotfiles repository ready at $dotfiles_dir"
}

# Create symlinks for dotfiles
create_symlinks() {
    local dotfiles_dir="$HOME/.dotfiles"
    local timestamp=$(date +%Y%m%d-%H%M%S)

    info "Creating symlinks for dotfiles..."

    # Backup function
    backup_if_exists() {
        local target="$1"
        if [[ -e "$target" && ! -L "$target" ]]; then
            mv "$target" "${target}.bak-${timestamp}"
            info "Backed up existing $target"
        elif [[ -L "$target" ]]; then
            rm "$target"
        fi
    }

    # Home directory files
    local home_files=(
        "bashrc:.bashrc"
        "gitconfig:.gitconfig"
        "gitignore_global:.gitignore_global"
        "aliases.sh:.aliases"
    )

    for mapping in "${home_files[@]}"; do
        local src_name="${mapping%%:*}"
        local dst_name="${mapping##*:}"
        local src="$dotfiles_dir/$src_name"
        local dst="$HOME/$dst_name"

        if [[ -f "$src" ]]; then
            backup_if_exists "$dst"
            ln -s "$src" "$dst"
            success "Linked $dst -> $src"
        fi
    done

    # Optional zshrc if it exists
    if [[ -f "$dotfiles_dir/zshrc" ]]; then
        backup_if_exists "$HOME/.zshrc"
        ln -s "$dotfiles_dir/zshrc" "$HOME/.zshrc"
        success "Linked ~/.zshrc -> $dotfiles_dir/zshrc"
    fi

    # Config directory files
    mkdir -p "$HOME/.config"
    local config_dirs=("nvim" "gtk-3.0" "gtk-4.0" "fontconfig")

    for config in "${config_dirs[@]}"; do
        local src="$dotfiles_dir/$config"
        local dst="$HOME/.config/$config"

        if [[ -d "$src" ]]; then
            backup_if_exists "$dst"
            ln -s "$src" "$dst"
            success "Linked $dst -> $src"
        fi
    done

    # Warp terminal preferences
    local warp_src="$dotfiles_dir/warp-terminal/user_preferences.json"
    local warp_dst="$HOME/.config/warp-terminal/user_preferences.json"

    if [[ -f "$warp_src" ]]; then
        mkdir -p "$(dirname "$warp_dst")"
        backup_if_exists "$warp_dst"
        ln -s "$warp_src" "$warp_dst"
        success "Linked $warp_dst -> $warp_src"
    fi
}

# Install JetBrains Mono Nerd Font
install_nerd_fonts() {
    local fonts_dir="$HOME/.local/share/fonts"

    if fc-list | grep -qi "jetbrains mono nerd font"; then
        success "JetBrains Mono Nerd Font already installed"
        return
    fi

    info "Installing JetBrains Mono Nerd Font..."
    mkdir -p "$fonts_dir"

    local tmp_dir="/tmp/nerd-fonts"
    mkdir -p "$tmp_dir"
    cd "$tmp_dir"

    curl -L "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip" -o JetBrainsMono.zip
    unzip -q JetBrainsMono.zip
    cp *.ttf "$fonts_dir/"
    fc-cache -fv

    rm -rf "$tmp_dir"
    success "JetBrains Mono Nerd Font installed"
}

# Print post-install instructions
print_post_install() {
    echo
    success "=== Installation Complete! ==="
    echo
    info "Next steps:"
    echo "1. Restart your terminal or run: source ~/.bashrc"
    echo "2. Open Neovim and let plugins install automatically"
    echo
    info "SSH Key Setup:"
    echo "1. Generate SSH key: ssh-keygen -t ed25519 -C \"your_email@example.com\""
    echo "2. Add to SSH agent: eval \"\$(ssh-agent -s)\" && ssh-add ~/.ssh/id_ed25519"
    echo "3. Copy public key: cat ~/.ssh/id_ed25519.pub"
    echo "4. Add to GitHub: https://github.com/settings/keys"
    echo
    info "Ollama + Wave Setup:"
    echo "1. Start Ollama: sudo systemctl start ollama"
    echo "2. Test models: ollama list"
    echo "3. In Wave, configure OpenAI-compatible endpoint:"
    echo "   - API URL: http://localhost:11434/v1"
    echo "   - Models: llama3.1:8b-instruct-q4_K_M, qwen2.5-coder:7b-instruct-q4_K_M"
    echo
    info "Sync workflow:"
    echo "- Push changes: cd ~/.dotfiles && ./sync-dotfiles"
    echo "- Pull changes: cd ~/.dotfiles && git pull && ./install.sh"
}

# Main installation flow
main() {
    echo "🚀 Universal Dotfiles Installer"
    echo "================================"

    local os_type
    os_type=$(detect_os)
    info "Detected OS: $os_type"

    install_packages "$os_type"
    install_nerd_fonts
    install_warp
    install_wave
    install_ollama
    setup_dotfiles_repo
    create_symlinks

    print_post_install
}

# Run main function
main "$@"
