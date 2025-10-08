#!/usr/bin/env bash
set -euo pipefail

REPO="${HOME}/dotfiles"
CFG="${HOME}/.config"
TS="$(date +%Y%m%d-%H%M%S)"

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
