-- mason.lua

return {
  "williamboman/mason.nvim",
  enabled = true,
  opts = function()
    vim.keymap.set({ 'n', 'v' }, '<leader>cm', '<cmd>Mason<cr>', { desc = 'Open Mason' })
  end,
}
