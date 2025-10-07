-- ~/dotfiles/nvim/lua/custom/plugins.lua

local plugins = {
  -- Telescope extras
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
    config = function()
      require("telescope").load_extension("fzf")
    end,
  },

  -- File explorer
  { "nvim-tree/nvim-tree.lua", opts = {} },

  -- Statusline icons
  { "nvim-tree/nvim-web-devicons" },

  -- Treesitter for better syntax
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
  },

  -- Git signs in gutter
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
    end,
  },
}

return plugins
