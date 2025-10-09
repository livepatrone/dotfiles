# ~/.zshrc - Zsh configuration
# Part of https://github.com/livepatrone/dotfiles

# Enable Powerlevel10k instant prompt (if available)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# History configuration
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt HIST_VERIFY
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_IGNORE_SPACE

# Directory navigation
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS

# Completion system
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Load aliases if available
[[ -f ~/.aliases ]] && source ~/.aliases

# Load device-specific configuration if available
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Show system info on new shells (optional - comment out if annoying)
if command -v fastfetch >/dev/null 2>&1; then
    fastfetch
fi

# Basic prompt (if no framework is installed)
if [[ -z "$ZSH_THEME" && -z "$STARSHIP_SESSION_KEY" ]]; then
    PROMPT='%F{blue}%n@%m%f:%F{green}%~%f%# '
fi
