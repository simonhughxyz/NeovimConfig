-- lsp.lua
--
-- language server protocol plugins

return {
  -- Collection of functions that will help you setup Neovim's LSP client
  'VonHeikemen/lsp-zero.nvim',
  branch = 'v3.x',
  dependencies = {
    -- LSP Support
    { 'neovim/nvim-lspconfig' },             -- Required
    { 'williamboman/mason.nvim' },           -- Optional
    { 'williamboman/mason-lspconfig.nvim' }, -- Optional

    -- Format
    { 'onsails/lspkind.nvim' }, -- shows icons on completion menu
    { 'kosayoda/nvim-lightbulb' },
    {
      'weilbith/nvim-code-action-menu',
      cmd = 'CodeActionMenu',
    },

    -- Autocompletion
    { 'hrsh7th/nvim-cmp' },
    { 'hrsh7th/cmp-nvim-lsp' },
    {
      'L3MON4D3/LuaSnip',
      dependencies = { "rafamadriz/friendly-snippets" },
    },
    { 'nvimtools/none-ls.nvim',     dependencies = { 'nvim-lua/plenary.nvim' } },
    { "jay-babu/mason-null-ls.nvim" },

    { 'saadparwaiz1/cmp_luasnip' },
    { 'hrsh7th/cmp-nvim-lua' },
    { 'hrsh7th/cmp-buffer' },
    { 'hrsh7th/cmp-cmdline' },
    { 'hrsh7th/cmp-path' },
    { 'hrsh7th/cmp-emoji' },
  },
  config = function()
    local lsp_zero = require('lsp-zero')

    lsp_zero.on_attach(function(client, bufnr)
      -- see :help lsp-zero-keybindings
      -- to learn the available actions
      lsp_zero.default_keymaps({ buffer = bufnr })

      local opts = function(desc)
        return { buffer = bufnr, remap = false, desc = desc }
      end

      local ts = require('telescope.builtin')

      vim.keymap.set({ 'n', 'x' }, '<leader>lf', function()
        vim.lsp.buf.format({ async = false, timeout_ms = 10000 })
      end, opts('Lsp format buffer'))

      vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts("Go To Next Diagnostic"))
      vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts("Go To Previous Diagnostic"))
      -- vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts("Go To Definition"))
      vim.keymap.set("n", "gd", ts.lsp_definitions, opts("Go To Definition"))
      vim.keymap.set("n", "<leader>la", function() vim.lsp.buf.code_action() end, opts("Code Action"))
      vim.keymap.set("n", "<leader>lh", function() vim.lsp.buf.hover() end, opts("Hover"))
      vim.keymap.set("n", "<leader>lH", function() vim.lsp.buf.signature_help() end, opts("Signiture Help"))
      -- vim.keymap.set("n", "<leader>ls", function() vim.lsp.buf.workspace_symbol() end, opts("Workspace Symbol"))
      vim.keymap.set("n", "<leader>ls", ts.lsp_workspace_symbols, opts("Workspace Symbol"))
      -- vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts("Open Float"))
      -- vim.keymap.set("n", "<leader>lr", function() vim.lsp.buf.references() end, opts("References"))
      vim.keymap.set("n", "<leader>lr", ts.lsp_references, opts("References"))
      vim.keymap.set("n", "<leader>li", function() vim.lsp.buf.implementation() end, opts("Implementation"))
      vim.keymap.set("n", "<leader>lR", function() vim.lsp.buf.rename() end, opts("Rename"))
      vim.keymap.set("n", "<leader>lI", '<cmd>LspInfo<CR>', opts("LspInfo"))
    end)

    require('mason').setup({})
    require('mason-lspconfig').setup({
      ensure_installed = {
        'lua_ls',
        'bashls',
        'pyright',    -- python
        'html',
        'clangd',
      },
      handlers = {
        lsp_zero.default_setup,
        lua_ls = function()
          local lua_opts = lsp_zero.nvim_lua_ls()
          require('lspconfig').lua_ls.setup(lua_opts)
        end,
      }
    })

    local null_ls = require("null-ls")

    local o = vim.o
    null_ls.setup({
      sources = {
        null_ls.builtins.formatting.stylua.with({ extra_args = { '--indent_type=spaces', '--indent_width=' .. o.tabstop } }),
        null_ls.builtins.diagnostics.eslint,
        null_ls.builtins.diagnostics.trail_space,

        null_ls.builtins.formatting.black, -- python formatting

        null_ls.builtins.completion.spell,
        null_ls.builtins.diagnostics.codespell,
        null_ls.builtins.diagnostics.write_good,
      },
    })

    require("mason-null-ls").setup({
      ensure_installed = {
        "stylua",
        "ruff",  -- python linter
        "mypy",  -- python type checker
        "black", -- python formatter
        "eslint",
        "trail_space",
        "spell",
        "codespell",
        "write_good",
      }
    })

    local cmp = require('cmp')
    local cmp_action = require('lsp-zero').cmp_action()

    -- load snippets
    require('luasnip.loaders.from_lua').lazy_load({ paths = './snippets/' })
    require('luasnip.loaders.from_vscode').lazy_load()


    local types = require("luasnip.util.types")

    require('luasnip').config.set_config({
      -- This one is cool cause if you have dynamic snippets, it updates as you type!
      updateevents = "TextChanged,TextChangedI",

      ext_opts = {
        [types.choiceNode] = {
          active = {
            virt_text = { { " ⬅️c ", "NonTest" } },
          },
        },
        [types.insertNode] = {
          active = {
            virt_text = { { " ⬅️t", "NonTest" } },
          },
        },
      },
    })

    -- snippet keymap
    vim.keymap.set("i", "<c-o>", require "luasnip.extras.select_choice")
    vim.keymap.set("n", "<leader>csc", require "luasnip.extras.select_choice")
    vim.keymap.set("i", "<c-d>", "<Plug>luasnip-next-choice")
    vim.keymap.set("s", "<c-d>", "<Plug>luasnip-next-choice")
    vim.keymap.set("i", "<c-u>", "<Plug>luasnip-prev-choice")
    vim.keymap.set("s", "<c-u>", "<Plug>luasnip-prev-choice")

    cmp.setup({
      sources = {
        { name = 'nvim_lsp' }, -- completion for neovim
        { name = 'nvim_lua' }, -- completion for neovim lua api
        { name = 'luasnip' },  -- show snippets
        { name = 'buffer' },   -- show elements from your buffer
        { name = 'path' },     -- show file paths
        { name = 'emoji' },    -- show emoji's
      },
      snippet = {
        expand = function(args)
          require('luasnip').lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ['<CR>'] = cmp.mapping.confirm({ select = false }),
        -- scroll up and down the documentation window
        ['<C-u>'] = cmp.mapping.scroll_docs(-4),
        ['<C-d>'] = cmp.mapping.scroll_docs(4),

        ['<C-l>'] = cmp_action.luasnip_jump_forward(),
        ['<C-h>'] = cmp_action.luasnip_jump_backward(),
      }),
      formatting = {
        fields = { 'abbr', 'kind', 'menu' },
        format = require('lspkind').cmp_format({
          mode = 'symbol_text',  -- show only symbol annotations
          maxwidth = 50,         -- prevent the popup from showing more than provided characters
          ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead
        })
      }
    })

    -- `/` cmdline setup.
    cmp.setup.cmdline('/', {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = 'buffer' }
      }
    })

    -- `:` cmdline setup.
    cmp.setup.cmdline(':', {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({
        { name = 'path' }
      }, {
        { name = 'cmdline' }
      })
    })

    require("nvim-lightbulb").setup({
      autocmd = { enabled = true },
      virtual_text = {
        enabled = true,
        text = '󰌵'
      },
    })
  end,
}
