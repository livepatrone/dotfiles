#!/usr/bin/env bash
set -euo pipefail

REPO="${HOME}/dotfiles"
CFG="${HOME}/.config"
TS="$(date +%Y%m%d-%H%M%S)"

# Dependencies for each configuration
# Format: [config_name]="command_to_check:package_name:install_method"
declare -A DEPENDENCIES=(
  ["alacritty"]="alacritty:alacritty:rpm-ostree"
  ["nvim"]="nvim:neovim:rpm-ostree"
  ["git"]="git:git:rpm-ostree"
  ["warp-terminal"]="warp:warp-terminal:manual"
  ["fastfetch"]="fastfetch:fastfetch:rpm-ostree"
)

check_dependencies() {
  local missing_deps=()
  local missing_info=()

  echo "🔍 Checking dependencies..."

  for config in "${!DEPENDENCIES[@]}"; do
    local dep_info="${DEPENDENCIES[$config]}"
    local cmd="${dep_info%%:*}"
    local pkg="${dep_info#*:}"; pkg="${pkg%%:*}"
    local method="${dep_info##*:}"

    if ! command -v "$cmd" &> /dev/null; then
      missing_deps+=("$cmd")
      missing_info+=("$method:$pkg")
    fi
  done

  if [ ${#missing_deps[@]} -gt 0 ]; then
    echo "⚠️  Missing dependencies detected:"
    echo

    local rpm_packages=()
    local flatpak_packages=()
    local manual_packages=()

    for i in "${!missing_deps[@]}"; do
      local cmd="${missing_deps[$i]}"
      local info="${missing_info[$i]}"
      local method="${info%%:*}"
      local pkg="${info##*:}"

      echo "   ❌ ${cmd} is not installed"

      if [ "$method" = "rpm-ostree" ]; then
        rpm_packages+=("$pkg")
      elif [ "$method" = "flatpak" ]; then
        flatpak_packages+=("$pkg")
      elif [ "$method" = "manual" ]; then
        manual_packages+=("$pkg")
      fi
    done

    echo
    echo "📦 To install missing packages:"

    if [ ${#rpm_packages[@]} -gt 0 ]; then
      echo "   sudo rpm-ostree install ${rpm_packages[*]}"
    fi

    if [ ${#flatpak_packages[@]} -gt 0 ]; then
      if command -v flatpak &> /dev/null; then
        echo "   flatpak install flathub ${flatpak_packages[*]}"
      else
        echo "   # Flatpak not available, ${flatpak_packages[*]} may need manual installation"
      fi
    fi

    if [ ${#manual_packages[@]} -gt 0 ]; then
      echo "   # Manual installation required:"
      for pkg in "${manual_packages[@]}"; do
        if [ "$pkg" = "warp-terminal" ]; then
          echo "   # Warp Terminal: Download from https://www.warp.dev/"
        else
          echo "   # $pkg: Manual installation required"
        fi
      done
    fi

    echo
    echo "💡 After installing packages with rpm-ostree, you'll need to reboot."
    echo "   Then re-run this script to complete the setup."
    echo

    read -p "Continue anyway? (y/N): " -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      echo "Setup cancelled. Install the missing packages and try again."
      exit 1
    fi
    echo
  else
    echo "✅ All dependencies are installed!"
    echo
  fi
}

# Items under dotfiles/ that should be linked into ~/.config
CONFIG_DIRS=(
  "alacritty"
  "nvim"
)

# Files that live in $HOME (not under ~/.config) if you keep any in the repo root.
# Example: if you add a `bashrc` file to your repo root and want it as ~/.bashrc:
HOME_FILES=(
  "bashrc:.bashrc"
  "gitconfig:.gitconfig"
  "gitignore_global:.gitignore_global"
)

backup() {
  local path="$1"
  if [ -e "$path" ] && [ ! -L "$path" ]; then
    mv -v "$path" "${path}.bak-${TS}"
  elif [ -L "$path" ]; then
    # remove stale symlink so we can recreate it
    rm -v "$path"
  fi
}

link_into_config() {
  local name="$1"
  local src="${REPO}/${name}"
  local dst="${CFG}/${name}"

  if [ ! -e "$src" ]; then
    echo "⏭️  Skip: ${src} not found in repo"
    return
  fi

  mkdir -p "$CFG"
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    backup "$dst"
  fi

  ln -s "${src}" "${dst}"
  echo "✅ Linked ${dst} -> ${src}"
}

link_into_home() {
  local mapping="$1"
  local src_name="${mapping%%:*}"
  local dst_name="${mapping##*:}"

  local src="${REPO}/${src_name}"
  local dst="${HOME}/${dst_name}"

  if [ ! -e "$src" ]; then
    echo "⏭️  Skip: ${src} not found in repo"
    return
  fi

  if [ -e "$dst" ] || [ -L "$dst" ]; then
    backup "$dst"
  fi

  ln -s "${src}" "${dst}"
  echo "✅ Linked ${dst} -> ${src}"
}

echo "=== Dotfiles bootstrap ==="
echo "Repo: ${REPO}"
echo "Config dir: ${CFG}"
echo

# Check dependencies first
check_dependencies

for d in "${CONFIG_DIRS[@]}"; do
  link_into_config "$d"
done

for f in "${HOME_FILES[@]}"; do
  link_into_home "$f"
done

# Special case for Warp terminal user preferences
WARP_SRC="${REPO}/warp-terminal/user_preferences.json"
WARP_DST="${CFG}/warp-terminal/user_preferences.json"
if [ -e "$WARP_SRC" ]; then
  mkdir -p "${CFG}/warp-terminal"
  if [ -e "$WARP_DST" ] || [ -L "$WARP_DST" ]; then
    backup "$WARP_DST"
  fi
  ln -s "$WARP_SRC" "$WARP_DST"
  echo "✅ Linked ${WARP_DST} -> ${WARP_SRC}"
else
  echo "⏭️  Skip: ${WARP_SRC} not found in repo"
fi

echo
echo "All done! Re-run this script any time after adding new items to your repo."
