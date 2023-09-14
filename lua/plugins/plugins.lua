-- plugins.lua
--
-- Plugins that don't require a lot of configuration go here

return {
  -- Useful plugin to show you pending keybinds.
  { 'folke/which-key.nvim',  opts = {} },

  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim', opts = {} },

  { 'monaqa/dial.nvim' },

  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
  },

  {
    'stevearc/oil.nvim',
    opts = {},
    -- Optional dependencies
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },

  -- Git plugin
  'tpope/vim-fugitive',

  { -- Use the w, e, b motions like a spider. Move by subwords and skip insignificant punctuation.
    "chrisgrieser/nvim-spider",
    enabled = true,
    lazy = true,
  },

  { -- Bundle of more than two dozen new textobjects for Neovim.
    "chrisgrieser/nvim-various-textobjs",
    lazy = false,
    opts = { useDefaultKeymaps = true },
  },
}
