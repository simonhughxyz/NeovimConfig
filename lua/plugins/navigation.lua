-- navigation.lua
--
-- plugins that help with navigating between windows, buffers, files...

return {
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
      vim.keymap.set("n", "<leader>fh", tsh.marks , { desc = "Find Harpoon" })

      for i = 1, 9 do
        vim.keymap.set('n', "<leader>'" .. i, function() require('harpoon.ui').nav_file(i) end, { desc = 'Harpoon Nav File' })
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
      vim.keymap.set('n', '<c-t>', [[<Cmd>ToggleTerm<CR>]], { desc = 'Toggle Term' })
      vim.keymap.set('i', '<c-t>', [[<Cmd>ToggleTerm<CR>]], { desc = 'Toggle Term' })
      vim.keymap.set('t', '<c-t>', [[<Cmd>ToggleTerm<CR>]], { desc = 'Toggle Term' })
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
      })

      vim.keymap.set("n", "su", "<Cmd>UrlView<CR>", { desc = "View buffer URLs" })
      vim.keymap.set("n", "sU", "<Cmd>UrlView lazy<CR>", { desc = "View Packer plugin URLs" })
    end,
  },
}
