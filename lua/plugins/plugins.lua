-- plugins.lua
--
-- Plugins that don't require a lot of configuration go here

return {
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
}
