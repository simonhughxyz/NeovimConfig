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
  },
}
