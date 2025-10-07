-- ~/dotfiles/nvim/lua/custom/init.lua

-- Theme
vim.g.nvchad_theme = "tokyonight"

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Disable unused language providers
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_ruby_provider = 0

-- Telescope keymaps
local map = vim.keymap.set
map("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "Find files" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>",  { desc = "Live grep" })
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>",    { desc = "Find buffers" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>",  { desc = "Help tags" })

-- Better escape from insert mode
map("i", "jk", "<ESC>", { desc = "Escape insert mode with jk" })
