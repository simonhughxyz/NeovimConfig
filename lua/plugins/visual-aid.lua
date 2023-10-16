-- visual-aid.lua
--
-- plugins that provide visual aid in the buffer

return {
  { -- useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    enabled = true,
    config = function()
      local wk = require('which-key')

      wk.register({
        ['<leader>'] = {
          ['<Tab>'] = { name = '+tab' },
          b = { name = '+Buffer' },
          d = { name = '+Debug' },
          f = { name = '+Find' },
          g = { name = '+Git' },
          h = { name = '+Hunk' },
          t = { name = '+Text' },
          T = { name = '+Text' },
          w = { name = '+Window' },
          w = { name = '+Window' },
          x = { name = '+Diagnostics' },
        },
      })
    end,
  },

  { -- when searching, search count is shown next to the cursor
    "kevinhwang91/nvim-hlslens",
    enabled = true,
    opts = {},
  },

  { -- this plugin adds indentation guides to all lines (including empty lines).
    "lukas-reineke/indent-blankline.nvim",
    enabled = true,
    event = { "BufReadPost", "BufNewFile" },
    main = "ibl",
    opts = {
      exclude = {
        filetypes = {
          "help",
          "alpha",
          "dashboard",
          "fugitive",
          "neo-tree",
          "Trouble",
          "lazy",
          "mason",
          "notify",
          "toggleterm",
          "lazyterm",
          "lspinfo",
          "packer",
          "checkhealth",
          "help",
          "man",
          "gitcommit",
          "TelescopePrompt",
          "TelescopeResults",
        },
      },
    },
  },

  { -- color highlighter, shows color of color codes
    "norcalli/nvim-colorizer.lua",
    enabled = true,
    opts = {
      default_options = {
        RGB = true,
        RRGGBB = true,
        names = true,
        RRGGBBAA = true,
        rgb_fn = true,
        hsl_fn = true,
        css = true,
        css_fn = true,
        mode = "background",
      },
      "*", -- highlight all files
    },
  },

  { -- to highlight the outer pair of brackets/parenthesis
    "utilyre/sentiment.nvim",
    version = "*",
    event = "VeryLazy", -- keep for lazy loading
    opts = {
      -- config
    },
    init = function()
      -- `matchparen.vim` needs to be disabled manually in case of lazy loading
      vim.g.loaded_matchparen = 1
    end,
  },

  { -- highlights for ftFT motion
    "jinh0/eyeliner.nvim",
    priority = 200,
    keys = { "f", "F", "t", "T" },
    opts = {
      highlight_on_key = true,
      dim = true
    },
    init = function()
      vim.api.nvim_create_autocmd('ColorScheme', {
        pattern = '*',
        callback = function()
          vim.api.nvim_set_hl(0, 'EyelinerPrimary', { fg = '#aa00aa', bold = true, underline = false })
          vim.api.nvim_set_hl(0, 'EyelinerSecondary', { fg = '#a0f050', bold = true, underline = false })
        end,
      })
    end,
  },

  { -- use different colors for matching brackets
    "p00f/nvim-ts-rainbow",
    main = 'nvim-treesitter.configs',
    opts = {
      -- for nvim-ts-rainbow plugin
      rainbow = {
        enable = true,
        extended_mode = true,   -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
        max_file_lines = 10000, -- Do not enable for files with more than 10000 lines, int
        -- colors = {}, -- table of hex strings
        -- termcolors = {} -- table of colour name strings
      },
    }
  },

  { -- automatically highlighting other uses of the word under the cursor
    "RRethy/vim-illuminate",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      delay = 200,
      large_file_cutoff = 2000,
      large_file_overrides = {
        providers = { "lsp" },
      },
    },
    config = function(_, opts)
      require("illuminate").configure(opts)

      local function map(key, dir, buffer)
        vim.keymap.set("n", key, function()
          require("illuminate")["goto_" .. dir .. "_reference"](false)
        end, { desc = dir:sub(1, 1):upper() .. dir:sub(2) .. " Reference", buffer = buffer })
      end

      map("]]", "next")
      map("[[", "prev")

      -- also set it after loading ftplugins, since a lot overwrite [[ and ]]
      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          local buffer = vim.api.nvim_get_current_buf()
          map("]]", "next", buffer)
          map("[[", "prev", buffer)
        end,
      })
    end,
    keys = {
      { "]]", desc = "Next Reference" },
      { "[[", desc = "Prev Reference" },
    },
  },
}
