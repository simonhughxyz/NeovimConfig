-- visual-aid.lua
--
-- plugins that provide visual aid in the buffer

return {
  { -- useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    enabled = true,
    opts = {}
  },

  { -- when searching, search count is shown next to the cursor
    "kevinhwang91/nvim-hlslens",
    enabled = true,
  },

  { -- this plugin adds indentation guides to all lines (including empty lines).
    "lukas-reineke/indent-blankline.nvim",
    enabled = true,
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      char = "│",
      filetype_exclude = {
        "help",
        "alpha",
        "dashboard",
        "neo-tree",
        "Trouble",
        "lazy",
        "mason",
        "notify",
        "toggleterm",
        "lazyterm",
      },
      show_trailing_blankline_indent = false,
      show_current_context = true,
      show_current_context_start = false,
    },
  },

  { -- show character highlights to help navigate
    "unblevable/quick-scope",
    priority = 11000, -- needs to load before ColorScheme
    config = function()
      vim.cmd([[
            augroup qs_colors
              autocmd!
              autocmd ColorScheme * highlight QuickScopePrimary guifg='#aa00aa' gui=underline ctermfg=155 cterm=underline
              autocmd ColorScheme * highlight QuickScopeSecondary guifg='#a0f050' gui=underline ctermfg=81 cterm=underline
            augroup END
           ]])
      vim.keymap.set("n", "<leader>cq", "<cmd>QuickScopeToggle<cr>", { desc = "Toggle quick scope" })
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
