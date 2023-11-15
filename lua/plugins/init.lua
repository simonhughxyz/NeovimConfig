-- plugins/init.lua

local o = vim.opt
local g = vim.g
local cmd = vim.cmd

return {
  { -- A port of gruvbox community theme to lua with treesitter and semantic highlights support
    "ellisonleao/gruvbox.nvim",
    enabled = true,
    lazy = false,
    priority = 10000,
    config = function()
      require("gruvbox").setup({
        transparent_mode = true,
      })
      o.background = "dark"
      g.gruvbox_italic = true
      g.gruvbox_bold = false
      g.gruvbox_transparent_bg = true
      g.gruvbox_constrast_dark = "hard"
      g.gruvbox_improved_strings = false
      cmd([[colorscheme gruvbox]])
    end,
  },

  {                -- add, delete, change and select surrounding pairs
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

  { -- table creator & formatter allowing one to create neat tables as you type
    "https://github.com/dhruvasagar/vim-table-mode",
  },

  { -- Align text interactively
    'echasnovski/mini.align',
    version = '*',
    config = function ()
      require('mini.align').setup({})
    end,
  },

  { -- Use the w, e, b motions like a spider. Move by subwords and skip insignificant punctuation.
    "chrisgrieser/nvim-spider",
    enabled = true,
    lazy = false,
    config = function()
      vim.keymap.set({ "n", "o", "x" }, "w", "<cmd>lua require('spider').motion('w')<cr>", { desc = "Spider-w" })
      vim.keymap.set({ "n", "o", "x" }, "e", "<cmd>lua require('spider').motion('e')<cr>", { desc = "Spider-e" })
      vim.keymap.set({ "n", "o", "x" }, "b", "<cmd>lua require('spider').motion('b')<cr>", { desc = "Spider-b" })
      vim.keymap.set({ "n", "o", "x" }, "ge", "<cmd>lua require('spider').motion('ge')<cr>", { desc = "Spider-ge" })
    end,
  },

  { -- to highlight and search for todo comments like TODO, HACK, BUG in your code base.
    "folke/todo-comments.nvim",
    enabled = true,
    cmd = { "TodoTrouble", "TodoTelescope" },
    event = { "BufReadPost", "BufNewFile" },
    config = true,
    -- stylua: ignore
    keys = {
      { "]t",         function() require("todo-comments").jump_next() end, desc = "Next todo comment" },
      { "[t",         function() require("todo-comments").jump_prev() end, desc = "Previous todo comment" },
      { "<leader>xt", "<cmd>TodoTrouble<cr>",                              desc = "Todo (Trouble)" },
      { "<leader>xT", "<cmd>TodoTrouble keywords=TODO,FIX,FIXME<cr>",      desc = "Todo/Fix/Fixme (Trouble)" },
      { "<leader>st", "<cmd>TodoTelescope<cr>",                            desc = "Todo" },
      { "<leader>sT", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>",    desc = "Todo/Fix/Fixme" },
    },
  },

  { -- a highly extendable fuzzy finder over lists, files, buffers, git status...
    "nvim-telescope/telescope.nvim",
    enabled = true,
    lazy = false,
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- Fuzzy Finder Algorithm which requires local dependencies to be built.
      -- Only load if `make` is available. Make sure you have the system
      -- requirements installed.
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        -- NOTE: If you are having trouble with this installation,
        --       refer to the README for telescope-fzf-native for more instructions.
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
    },
    config = function()
      -- Enable telescope fzf native, if installed
      pcall(require('telescope').load_extension, 'fzf')

      local ts = require('telescope.builtin')

      -- See `:help telescope.builtin`
      vim.keymap.set('n', '<leader>?', ts.oldfiles, { desc = 'Find recently opened files' })
      vim.keymap.set('n', '<leader>,', ts.buffers, { desc = 'Find existing buffers' })
      vim.keymap.set('n', '<leader>/', function()
        -- You can pass additional configuration to telescope to change theme, layout, etc.
        ts.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = 'Fuzzily search in current buffer' })

      vim.keymap.set('n', '<leader>gf', ts.git_files, { desc = 'Search Git Files' })
      vim.keymap.set('n', '<leader>gs', ts.git_status, { desc = 'Search Git Status' })
      vim.keymap.set('n', '<leader>gS', ts.git_stash, { desc = 'Search Git Stash' })
      vim.keymap.set('n', '<leader>gc', ts.git_commits, { desc = 'Search Git Commits' })
      vim.keymap.set('n', '<leader>ff', ts.find_files, { desc = 'Find Files' })
      vim.keymap.set('n', '<leader>sb', ts.builtin, { desc = 'Search Telescope Builtin' })
      vim.keymap.set('n', '<leader>sh', ts.help_tags, { desc = 'Search Help' })
      vim.keymap.set('n', '<leader>sw', ts.grep_string, { desc = 'Search Current Word' })
      vim.keymap.set('n', '<leader>sg', ts.live_grep, { desc = 'Search by Grep' })
      vim.keymap.set('n', '<leader>sd', ts.diagnostics, { desc = 'Search Diagnostics' })
      vim.keymap.set('n', '<leader>sk', ts.keymaps, { desc = 'Search Keymaps' })
      vim.keymap.set('n', "<leader>s'", ts.marks, { desc = 'Search Marks' })
      vim.keymap.set('n', '<leader>s"', ts.registers, { desc = 'Search Registers' })

      vim.keymap.set('n', '<leader>fd', function() ts.find_files({ cwd = '~/Documents' }) end,
        { desc = 'Find Documents' })
      vim.keymap.set('n', '<leader>fD', function() ts.find_files({ cwd = '~/Downloads' }) end,
        { desc = 'Find Downloads' })
      vim.keymap.set('n', '<leader>fp', function() ts.find_files({ cwd = '~/Projects' }) end, { desc = 'Find Projects' })
      vim.keymap.set('n', '<leader>fc', function() ts.find_files({ cwd = vim.fn.stdpath('config') }) end,
        { desc = 'Find Config' })
      vim.keymap.set('n', '<leader>fb', function() ts.find_files({ cwd = '~/.local/bin' }) end,
        { desc = 'Find Local Bin' })
    end,
  },

  -- TODO: change default mappings to be more consistent with vim
  { -- to browse the file system and other tree like structures
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
    },
    cmd = "Neotree",
    keys = {
      {
        "<leader>e",
        function()
          require("neo-tree.command").execute({ toggle = true, dir = vim.loop.cwd() })
        end,
        desc = "Explorer NeoTree",
      },
    },
    deactivate = function()
      vim.cmd([[Neotree close]])
    end,
    init = function()
      if vim.fn.argc() == 1 then
        local stat = vim.loop.fs_stat(vim.fn.argv(0))
        if stat and stat.type == "directory" then
          require("neo-tree")
        end
      end
    end,
    opts = {
      sources = { "filesystem", "buffers", "git_status", "document_symbols" },
      open_files_do_not_replace_types = { "terminal", "Trouble", "qf", "Outline" },
      filesystem = {
        bind_to_cwd = false,
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
      },
      window = {
        mappings = {
          ["<space>"] = "none",
        },
      },
      default_component_configs = {
        indent = {
          with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
          expander_collapsed = "",
          expander_expanded = "",
          expander_highlight = "NeoTreeExpander",
        },
      },
    },
  },

  { --  a per project file bookmark plugin
    'ThePrimeagen/harpoon',
    enabled = true,
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {},
    config = function()
      -- enable telescope extension
      local tsh = require("telescope").load_extension('harpoon')

      -- set keymaps
      vim.keymap.set('n', "<leader>'a", require('harpoon.mark').add_file, { desc = 'Harpoon Add File' })
      vim.keymap.set('n', "<leader>']", require('harpoon.ui').nav_next, { desc = 'Harpoon Next' })
      vim.keymap.set('n', "<leader>'[", require('harpoon.ui').nav_prev, { desc = 'Harpoon Previous' })
      vim.keymap.set("n", "<leader>fh", tsh.marks, { desc = "Find Harpoon" })

      for i = 1, 9 do
        vim.keymap.set('n', "<leader>'" .. i, function() require('harpoon.ui').nav_file(i) end,
          { desc = 'Harpoon Nav File' })
      end

      require('which-key').register({
        ['<leader>'] = {
          ["'"] = { name = "+Harpoon" },
        },
      })
    end,
  },

  { -- persist and toggle multiple terminals during an editing session
    'akinsho/toggleterm.nvim',
    version = "*",
    opts = {},
    config = function()
      require("toggleterm").setup()

      -- set keymaps to toggle toggleterm
      vim.keymap.set('n', '<c-t>', [[<Cmd>exe v:count1 . "ToggleTerm"<CR>]], { desc = 'Toggle Term' })
      vim.keymap.set('i', '<c-t>', [[<Cmd>exe v:count1 . "ToggleTerm"<CR>]], { desc = 'Toggle Term' })
      vim.keymap.set('t', '<c-t>', [[<Cmd>exe v:count1 . "ToggleTerm"<CR>]], { desc = 'Toggle Term' })
    end,
  },
  { -- provides project management
    "ahmedkhalf/project.nvim",
    enabled = true,
    config = function()
      require("project_nvim").setup {}

      local tsp = require('telescope').load_extension('projects')

      vim.keymap.set('n', '<leader>sp', function() tsp.projects() end, { desc = 'Search for Project' })
    end,
  },
  { -- Interacting with and manipulating Vim marks, show marks in sign column
    'chentoast/marks.nvim',
    enabled = true,
    config = function()
      require 'marks'.setup {
        default_mappings = true,
        signs = true,
        mappings = {}
      }
    end,
  },
  {
    "axieax/urlview.nvim",
    enabled = true,
    config = function()
      require("urlview").setup({
        default_picker = "telescope",
        log_level_min = 4,
      })

      vim.keymap.set("n", "su", "<Cmd>UrlView<CR>", { desc = "View buffer URLs" })
      vim.keymap.set("n", "sU", "<Cmd>UrlView lazy<CR>", { desc = "View Packer plugin URLs" })
    end,
  },

  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
    config = function()
      vim.keymap.set("n", "<leader>xx", function() require("trouble").open() end, { desc = "Trouble" })
      vim.keymap.set("n", "<leader>xw", function() require("trouble").open("workspace_diagnostics") end,
        { desc = "Workspace Diagnostics" })
      vim.keymap.set("n", "<leader>xd", function() require("trouble").open("document_diagnostics") end,
        { desc = "Document Diagnostics" })
      vim.keymap.set("n", "<leader>xq", function() require("trouble").open("quickfix") end, { desc = "Quickfix" })
      vim.keymap.set("n", "<leader>xl", function() require("trouble").open("loclist") end, { desc = "Local List" })
      vim.keymap.set("n", "gR", function() require("trouble").open("lsp_references") end, { desc = "Lsp References" })
    end,
  },

  {
    'stevearc/oil.nvim',
    opts = {},
    -- Optional dependencies
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },

  {
    "willothy/flatten.nvim",
    opts = function()
      ---@type Terminal?
      local saved_terminal

      return {
        window = {
          open = "alternate",
        },
        callbacks = {
          should_block = function(argv)
            -- Note that argv contains all the parts of the CLI command, including
            -- Neovim's path, commands, options and files.
            -- See: :help v:argv

            -- In this case, we would block if we find the `-b` flag
            -- This allows you to use `nvim -b file1` instead of
            -- `nvim --cmd 'let g:flatten_wait=1' file1`
            return vim.tbl_contains(argv, "-b")

            -- Alternatively, we can block if we find the diff-mode option
            -- return vim.tbl_contains(argv, "-d")
          end,
          pre_open = function()
            local term = require("toggleterm.terminal")
            local termid = term.get_focused_id()
            saved_terminal = term.get(termid)
          end,
          post_open = function(bufnr, winnr, ft, is_blocking)
            if is_blocking and saved_terminal then
              -- Hide the terminal while it's blocking
              saved_terminal:close()
            else
              -- If it's a normal file, just switch to its window
              vim.api.nvim_set_current_win(winnr)
            end

            -- If the file is a git commit, create one-shot autocmd to delete its buffer on write
            -- If you just want the toggleable terminal integration, ignore this bit
            if ft == "gitcommit" or ft == "gitrebase" then
              vim.api.nvim_create_autocmd("BufWritePost", {
                buffer = bufnr,
                once = true,
                callback = vim.schedule_wrap(function()
                  vim.api.nvim_buf_delete(bufnr, {})
                end),
              })
            end
          end,
          block_end = function()
            -- After blocking ends (for a git commit, etc), reopen the terminal
            vim.schedule(function()
              if saved_terminal then
                saved_terminal:open()
                saved_terminal = nil
              end
            end)
          end,
        },
      }
    end,
  },

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

  {
    "gbprod/yanky.nvim",
    dependencies = {
      {
        "kkharji/sqlite.lua",
        enabled = not jit.os:find("Windows")
      },
    },
    config = function()
      require("yanky").setup({
        ring = {
          history_length = 100,
          -- storage = "shada",
          sync_with_numbered_registers = true,
          cancel_event = "update",
        },
        picker = {
          select = {
            action = nil, -- nil to use default put action
          },
          -- telescope = {
          --   use_default_mappings = true, -- if default mappings should be used
          --   mappings = nil, -- nil to use default mappings or no mappings (see `use_default_mappings`)
          -- },
        },
        system_clipboard = {
          sync_with_ring = true,
        },
        highlight = {
          on_put = true,
          on_yank = true,
          timer = 500,
        },
        preserve_cursor_position = {
          enabled = true,
        },
      })
    end,
    opts = function()
      local mapping = require("yanky.telescope.mapping")
      local mappings = mapping.get_defaults()
      mappings.i["<c-p>"] = nil
      return {
        highlight = { timer = 200 },
        ring = { storage = jit.os:find("Windows") and "shada" or "sqlite" },
        picker = {
          telescope = {
            use_default_mappings = false,
            mappings = mappings,
          },
        },
      }
    end,
    keys = {
      -- stylua: ignore
      {
        "<leader>p",
        function() require("telescope").extensions.yank_history.yank_history({}) end,
        desc =
        "Open Yank History"
      },
      {
        "y",
        "<Plug>(YankyYank)",
        mode = { "n", "x" },
        desc =
        "Yank text"
      },
      {
        "p",
        "<Plug>(YankyPutAfter)",
        mode = { "n", "x" },
        desc =
        "Put yanked text after cursor"
      },
      {
        "P",
        "<Plug>(YankyPutBefore)",
        mode = { "n", "x" },
        desc =
        "Put yanked text before cursor"
      },
      {
        "gp",
        "<Plug>(YankyGPutAfter)",
        mode = { "n", "x" },
        desc =
        "Put yanked text after selection"
      },
      {
        "gP",
        "<Plug>(YankyGPutBefore)",
        mode = { "n", "x" },
        desc =
        "Put yanked text before selection"
      },
      {
        "[y",
        "<Plug>(YankyCycleForward)",
        desc =
        "Cycle forward through yank history"
      },
      {
        "]y",
        "<Plug>(YankyCycleBackward)",
        desc =
        "Cycle backward through yank history"
      },
      {
        "]p",
        "<Plug>(YankyPutIndentAfterLinewise)",
        desc =
        "Put indented after cursor (linewise)"
      },
      {
        "[p",
        "<Plug>(YankyPutIndentBeforeLinewise)",
        desc =
        "Put indented before cursor (linewise)"
      },
      {
        "]P",
        "<Plug>(YankyPutIndentAfterLinewise)",
        desc =
        "Put indented after cursor (linewise)"
      },
      {
        "[P",
        "<Plug>(YankyPutIndentBeforeLinewise)",
        desc =
        "Put indented before cursor (linewise)"
      },
      {
        ">p",
        "<Plug>(YankyPutIndentAfterShiftRight)",
        desc =
        "Put and indent right"
      },
      {
        "<p",
        "<Plug>(YankyPutIndentAfterShiftLeft)",
        desc =
        "Put and indent left"
      },
      {
        ">P",
        "<Plug>(YankyPutIndentBeforeShiftRight)",
        desc =
        "Put before and indent right"
      },
      {
        "<P",
        "<Plug>(YankyPutIndentBeforeShiftLeft)",
        desc =
        "Put before and indent left"
      },
      {
        "=p",
        "<Plug>(YankyPutAfterFilter)",
        desc =
        "Put after applying a filter"
      },
      {
        "=P",
        "<Plug>(YankyPutBeforeFilter)",
        desc =
        "Put before applying a filter"
      },
    },
  },

  { -- Neovim plugin to improve the default vim.ui interfaces
    'stevearc/dressing.nvim',
    opts = {},
  },

}
