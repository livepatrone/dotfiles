#!/usr/bin/env bash
# Dotfiles management aliases and functions

# Quick dotfiles management
alias dotfiles='cd ~/dotfiles'
alias dots='cd ~/dotfiles'
alias syncup='cd ~/dotfiles && git add -A && git commit -m "Sync config changes from $(hostname)" && git push'
alias syncdown='cd ~/dotfiles && git pull && ./install.sh'

# Useful system aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Config editing shortcuts
alias editbash='nvim ~/dotfiles/bashrc'
alias editgit='nvim ~/dotfiles/gitconfig' 
alias editnvim='nvim ~/dotfiles/nvim/'
alias editwarp='nvim ~/dotfiles/warp-terminal/user_preferences.json'

# Quick config reloading
alias reload='source ~/.bashrc'
alias reloadssh='eval "$(ssh-agent -s)" && ssh-add ~/.ssh/id_ed25519'

# System info
alias sysinfo='fastfetch'
alias ports='netstat -tuln'
alias myip='curl -s http://ipinfo.io/ip'

# Git shortcuts
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias glog='git log --oneline --graph --decorate'

# Functions for dotfiles management
sync_device_config() {
    local hostname=$(hostname)
    local device_dir="$HOME/dotfiles/device-configs/$hostname"
    
    echo "🔄 Syncing current configs to device-specific directory..."
    mkdir -p "$device_dir"
    
    # Backup current GTK settings as device-specific if they differ
    if [ -f ~/.config/gtk-3.0/settings.ini ]; then
        if ! diff -q ~/.config/gtk-3.0/settings.ini ~/dotfiles/gtk-3.0/settings.ini >/dev/null 2>&1; then
            echo "📁 Backing up GTK-3.0 settings for $hostname"
            mkdir -p "$device_dir/gtk-3.0"
            cp ~/.config/gtk-3.0/settings.ini "$device_dir/gtk-3.0/"
        fi
    fi
    
    echo "✅ Device config sync complete for $hostname"
}

install_nerd_fonts() {
    echo "📥 Installing JetBrains Mono Nerd Font..."
    local fonts_dir="$HOME/.local/share/fonts"
    mkdir -p "$fonts_dir"
    
    if ! fc-list | grep -i "jetbrains mono nerd font" > /dev/null; then
        cd /tmp
        wget -q https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
        unzip -q JetBrainsMono.zip -d JetBrainsMono
        cp JetBrainsMono/*.ttf "$fonts_dir/"
        fc-cache -fv
        echo "✅ JetBrains Mono Nerd Font installed"
        rm -rf JetBrainsMono JetBrainsMono.zip
    else
        echo "ℹ️  JetBrains Mono Nerd Font already installed"
    fi
}

backup_current_configs() {
    local backup_dir="$HOME/dotfiles/backups/$(date +%Y%m%d-%H%M%S)"
    echo "💾 Creating backup of current configs in $backup_dir"
    mkdir -p "$backup_dir"
    
    # Backup key config files that might exist
    [ -f ~/.bashrc ] && cp ~/.bashrc "$backup_dir/"
    [ -f ~/.gitconfig ] && cp ~/.gitconfig "$backup_dir/"
    [ -d ~/.config/gtk-3.0 ] && cp -r ~/.config/gtk-3.0 "$backup_dir/"
    [ -d ~/.config/gtk-4.0 ] && cp -r ~/.config/gtk-4.0 "$backup_dir/"
    [ -d ~/.config/nvim ] && cp -r ~/.config/nvim "$backup_dir/"
    
    echo "✅ Backup completed: $backup_dir"
}