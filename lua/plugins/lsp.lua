-- lsp.lua
--
-- language server protocol plugins

return {
  -- Collection of functions that will help you setup Neovim's LSP client
  'VonHeikemen/lsp-zero.nvim',
  branch = 'v2.x',
  dependencies = {
    -- LSP Support
    { 'neovim/nvim-lspconfig' },             -- Required
    { 'williamboman/mason.nvim' },           -- Optional
    { 'williamboman/mason-lspconfig.nvim' }, -- Optional

    -- Autocompletion
    { 'hrsh7th/nvim-cmp' },     -- Required
    { 'hrsh7th/cmp-nvim-lsp' }, -- Requred
    { 'L3MON4D3/LuaSnip' },     -- Required
  },
}
