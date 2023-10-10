-- editing-support.lua
--
-- Plugins that help with editing text and files

return {
  { -- add, delete, change and select surrounding pairs
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
        -- Configuration here, or leave empty to use defaults
      })
    end,
  },

  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim', opts = {} },

  -- Extended increment/decrement plugin
  {
    'monaqa/dial.nvim',
    config = function()
      local augend = require("dial.augend")
      require("dial.config").augends:register_group {
        -- default augends used when no group name is specified
        default = {
          augend.integer.alias.decimal,  -- nonnegative decimal number (0, 1, 2, 3, ...)
          augend.constant.alias.bool,    -- boolean value (true <-> false)
          augend.integer.alias.hex,      -- nonnegative hex number  (0x01, 0x1a1f, etc.)
          augend.date.alias["%Y/%m/%d"], -- date (2022/02/19, etc.)
          augend.date.alias["%Y-%m-%d"],
          augend.date.alias["%m/%d"],
          augend.date.alias["%H:%M"],
          augend.constant.new {
            elements = { "and", "or" },
            word = true,   -- if false, "sand" is incremented into "sor", "doctor" into "doctand", etc.
            cyclic = true, -- "or" is incremented into "and".
            preserve_case = true,
          },
          augend.constant.new {
            elements = { "yes", "no" },
            word = true,   -- if false, "sand" is incremented into "sor", "doctor" into "doctand", etc.
            cyclic = true, -- "or" is incremented into "and".
            preserve_case = true,
          },
          augend.constant.new {
            elements = { "&&", "||" },
            word = false,
            cyclic = true,
          },
        },
      }

      vim.keymap.set("n", "<C-a>", require("dial.map").inc_normal(), { noremap = true })
      vim.keymap.set("n", "<C-x>", require("dial.map").dec_normal(), { noremap = true })
      vim.keymap.set("n", "g<C-a>", require("dial.map").inc_gnormal(), { noremap = true })
      vim.keymap.set("n", "g<C-x>", require("dial.map").dec_gnormal(), { noremap = true })
      vim.keymap.set("v", "<C-a>", require("dial.map").inc_visual(), { noremap = true })
      vim.keymap.set("v", "<C-x>", require("dial.map").dec_visual(), { noremap = true })
      vim.keymap.set("v", "g<C-a>", require("dial.map").inc_gvisual(), { noremap = true })
      vim.keymap.set("v", "g<C-x>", require("dial.map").dec_gvisual(), { noremap = true })
    end,
  },

  { -- Bundle of more than two dozen new textobjects for Neovim.
    "chrisgrieser/nvim-various-textobjs",
    lazy = false,
    opts = { useDefaultKeymaps = true },
  },

  { -- split-join lines
    "Wansmer/treesj",
    dependencies = "nvim-treesitter/nvim-treesitter",
    keys = {
      { "<leader>j", function() require("treesj").toggle() end, desc = "󰗈 Split-join lines" },
    },
  },

  { -- case conversion, upper to lower to camel to snake...
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
