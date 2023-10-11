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

    -- Autocompletion
    { 'hrsh7th/nvim-cmp' },     -- Required
    { 'hrsh7th/cmp-nvim-lsp' }, -- Requred
    { 'L3MON4D3/LuaSnip' },     -- Required

    { 'hrsh7th/cmp-buffer' },
  },
  config = function()
    local lsp_zero = require('lsp-zero')

    lsp_zero.on_attach(function(client, bufnr)
      -- see :help lsp-zero-keybindings
      -- to learn the available actions
      lsp_zero.default_keymaps({ buffer = bufnr })
      local opts = {buffer = bufnr}

      vim.keymap.set({'n', 'x'}, 'gq', function()
        vim.lsp.buf.format({async = false, timeout_ms = 10000})
      end, {buffer = burnr, desc = 'Lsp format buffer'})

    end)

    require('mason').setup({})
    require('mason-lspconfig').setup({
      ensure_installed = {
        'html',
        'pylsp',
        'lua_ls',
        'bashls',
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

    local cmp = require('cmp')
    local cmp_action = require('lsp-zero').cmp_action()
    local cmp_format = lsp_zero.cmp_format()

    cmp.setup({
      sources = {
        { name = 'nvim_lsp' },
        { name = 'buffer' },
      },
      snippet = {
        expand = function(args)
          require('luasnip').lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        -- scroll up and down the documentation window
        ['<C-u>'] = cmp.mapping.scroll_docs(-4),
        ['<C-d>'] = cmp.mapping.scroll_docs(4), 

        ['<C-f>'] = cmp_action.luasnip_jump_forward(),
        ['<C-b>'] = cmp_action.luasnip_jump_backward(),
      }),
      --- (Optional) Show source name in completion menu
      formatting = cmp_format,
    })
  end,
}
