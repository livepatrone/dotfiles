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
