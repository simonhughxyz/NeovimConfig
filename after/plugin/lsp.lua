-- lsp.lua
--
-- lsp relating config

local lsp = require('lsp-zero')

lsp.preset("recommended")

lsp.ensure_installed({
  'html',
  'lua_ls',
})

-- Fix Undefined global 'vim'
lsp.nvim_workspace()

local cmp = require('cmp')
local cmp_select = {behavior = cmp.SelectBehavior.Select}
local cmp_mappings = lsp.defaults.cmp_mappings({
  ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
  ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
  ['<C-y>'] = cmp.mapping.confirm({ select = true }),
  ["<C-Space>"] = cmp.mapping.complete(),
})

cmp_mappings['<Tab>'] = nil
cmp_mappings['<S-Tab>'] = nil

lsp.setup_nvim_cmp({
  mapping = cmp_mappings
})

lsp.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  -- lsp.default_keymaps({buffer = bufnr})

  -- Autoformat code on write
  lsp.buffer_autoformat(client, bufnr)

  local opts = function(desc)
    return {buffer = bufnr, remap = false, desc = desc}
  end

  vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts("Go To Definition"))
  vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts("Hover"))
  vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts("Workspace Symbol"))
  vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts("Open Float"))
  vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts("Go To Next"))
  vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts("Go To Previous"))
  vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts("Code Action"))
  vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts("References"))
  vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts("Rename"))
  vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts("Signiture Help"))
end)

-- (Optional) Configure lua language server for neovim
require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())

lsp.setup()
