-- treesitter.lua

local treesitter_opts = {
  -- Add languages to be installed here that you want installed for treesitter
  ensure_installed = {
    'lua',
    'vim',
    'vimdoc',
    'norg',
    'regex',
    'bash',
    'c',
    'cpp',
    'make',
    'markdown',
    'comment',
    'html',
    'php',
    'http',
    'css',
    'javascript',
    'typescript',
    'go',
    'python',
    'json',
    'toml',
    'yaml',
    'sql',
    'r',
    'gitattributes',
    'gitignore',
  },

  -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
  auto_install = true,

  highlight = { enable = true },
  indent = { enable = true },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = '<c-space>',
      node_incremental = '<c-space>',
      scope_incremental = '<c-s>',
      node_decremental = '<M-space>',
    },
  },

  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ['aa'] = '@parameter.outer',
        ['ia'] = '@parameter.inner',
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        [']m'] = '@function.outer',
        [']]'] = '@class.outer',
      },
      goto_next_end = {
        [']M'] = '@function.outer',
        [']['] = '@class.outer',
      },
      goto_previous_start = {
        ['[m'] = '@function.outer',
        ['[['] = '@class.outer',
      },
      goto_previous_end = {
        ['[M'] = '@function.outer',
        ['[]'] = '@class.outer',
      },
    },
    swap = {
      enable = true,
      swap_next = {
        ['<leader>a'] = '@parameter.inner',
      },
      swap_previous = {
        ['<leader>A'] = '@parameter.inner',
      },
    },
  },

  -- nvim-treesitter-endwise
  endwise = { enable = true },
}

return {
  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    priority = 5000,
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
      { "JoosepAlviste/nvim-ts-context-commentstring", lazy = true }
    },
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs',
    opts = treesitter_opts,
  },

  { -- basically autopair, but for keywords
    "RRethy/nvim-treesitter-endwise",
    -- event = "InsertEnter",
    dependencies = "nvim-treesitter/nvim-treesitter",
  },

  { -- virtual text context at the end of a scope
    "haringsrob/nvim_context_vt",
    event = "VeryLazy",
    dependencies = "nvim-treesitter/nvim-treesitter",
    opts = {
      prefix = "󱞷",
      highlight = "NonText",
      min_rows = 1,
      disable_ft = { "markdown" },
      min_rows_ft = { python = 10, yaml = 15, css = 15 },

      -- set up custom parser to return the whole line for context
      custom_parser = function(node, _, opts)
        -- If you return `nil`, no virtual text will be displayed.
        if node:type() == 'function' then
          return nil
        end

        -- get the context line
        local bufnr = vim.api.nvim_get_current_buf()
        local start_row, _, _, _ = vim.treesitter.get_node_range(node)
        local line = vim.api.nvim_buf_get_lines(bufnr, start_row, start_row + 1, false)[1]

        -- remove whitespace before context
        local context = string.gsub(line, '^%s*', '')

        return opts.prefix .. ' ' .. context
      end,
    },
  },
}
