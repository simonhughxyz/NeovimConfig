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

  { -- when searching, search count is shown next to the cursor
    "kevinhwang91/nvim-hlslens",
  },

  { -- split-join lines
    "Wansmer/treesj",
    dependencies = "nvim-treesitter/nvim-treesitter",
    keys = {
      { "<leader>j", function() require("treesj").toggle() end, desc = "󰗈 Split-join lines" },
    },
  },
  { -- case conversion
  { -- converts a piece of text to an indicated string case
    "johmsalas/text-case.nvim",
    init = function()
      local casings = {
        { char = "u", arg = "upper",      desc = "UPPER CASE" },
        { char = "l", arg = "lower",      desc = "lower case" },
        { char = "t", arg = "title",      desc = "Title Case" },
        { char = "c", arg = "camel",      desc = "camelCase" },
        { char = "C", arg = "pascal",     desc = "CamelCase" },
        { char = "s", arg = "snake",      desc = "snake_case" },
        { char = "_", arg = "snake",      desc = "snake_case" },
        { char = "d", arg = "dash",       desc = "dash-case" },
        { char = "D", arg = "title_dash", desc = "Title-Dash-Case" },
        { char = "-", arg = "dash",       desc = "dash-case" },
        { char = "p", arg = "phrase",     desc = "Phrase case" },
        { char = "/", arg = "path",       desc = "path/case" },
        { char = "S", arg = "constant",   desc = "UPPER_SNAKE_CASE" },
        { char = ".", arg = "dot",        desc = "dot.case" },
      }

      for _, case in pairs(casings) do
        vim.keymap.set(
          "n",
          "<leader>t" .. case.char,
          ("<cmd>lua require('textcase').current_word('to_%s_case')<CR>"):format(case.arg),
          { desc = case.desc }
        )
        vim.keymap.set(
          "v",
          "<leader>t" .. case.char,
          ("<cmd>lua require('textcase').operator('to_%s_case')<CR>"):format(case.arg),
          { desc = case.desc }
        )
        vim.keymap.set(
          "n",
          "<leader>T" .. case.char,
          ("<cmd>lua require('textcase').lsp_rename('to_%s_case')<CR>"):format(case.arg),
          { desc = "󰒕 " .. case.desc }
        )
      end
    end,
  },
}
