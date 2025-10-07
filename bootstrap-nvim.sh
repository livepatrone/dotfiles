#!/usr/bin/env bash
set -euo pipefail

REPO="${HOME}/dotfiles"
NVIM_CFG="${HOME}/.config/nvim"
CUSTOM_SRC="${REPO}/nvim/lua/custom"
CUSTOM_DST="${NVIM_CFG}/lua/custom"

msg() { printf "\033[1;36m==>\033[0m %s\n" "$*"; }
ok()  { printf "\033[1;32m✔\033[0m  %s\n" "$*"; }

# 0) Sanity
command -v git >/dev/null || { echo "git not found"; exit 1; }
command -v nvim >/dev/null || { echo "nvim not found"; exit 1; }

# 1) Ensure NvChad present (starter)
if [ ! -d "$NVIM_CFG" ] || [ ! -f "$NVIM_CFG/init.lua" ]; then
  msg "Installing NvChad starter into ${NVIM_CFG}"
  rm -rf "$NVIM_CFG"
  git clone https://github.com/NvChad/starter "$NVIM_CFG" --depth 1
  rm -rf "$NVIM_CFG/.git"
  ok "NvChad starter installed"
else
  ok "NvChad already present"
fi

# 2) Link your custom overrides
if [ ! -d "$CUSTOM_SRC" ]; then
  msg "Creating example custom config at ${CUSTOM_SRC}"
  mkdir -p "$CUSTOM_SRC"
  cat > "${CUSTOM_SRC}/init.lua" <<'LUA'
-- ~/dotfiles/nvim/lua/custom/init.lua
vim.g.nvchad_theme = "tokyonight"
vim.opt.number = true
vim.opt.relativenumber = true
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0
-- vim.g.python3_host_prog = "/usr/bin/python3" -- uncomment if needed

local map = vim.keymap.set
map("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "Find files" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>",  { desc = "Live grep" })
LUA
  ok "Wrote example custom/init.lua"
fi

mkdir -p "$(dirname "$CUSTOM_DST")"
if [ -L "$CUSTOM_DST" ] || [ -e "$CUSTOM_DST" ]; then
  if [ -L "$CUSTOM_DST" ] && [ "$(readlink -f "$CUSTOM_DST")" = "$(readlink -f "$CUSTOM_SRC")" ]; then
    ok "Custom already linked"
  else
    msg "Replacing existing ${CUSTOM_DST}"
    rm -rf "$CUSTOM_DST"
    ln -s "$CUSTOM_SRC" "$CUSTOM_DST"
    ok "Linked ${CUSTOM_DST} -> ${CUSTOM_SRC}"
  fi
else
  ln -s "$CUSTOM_SRC" "$CUSTOM_DST"
  ok "Linked ${CUSTOM_DST} -> ${CUSTOM_SRC}"
fi

# 3) Optional: ensure Python provider (quiet if already installed)
if ! python3 -c 'import pynvim' >/dev/null 2>&1; then
  msg "Installing Python provider (pynvim) for current user"
  python3 -m pip install --user -q pynvim || true
fi

# 4) Headless plugin sync (faster first run)
msg "Syncing plugins via Lazy (headless)"
nvim --headless "+Lazy! sync" +qa || true
ok "Done. Launch Neovim normally with: nvim"
