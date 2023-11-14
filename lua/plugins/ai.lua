-- plugins/ai.lua

return {
  "jackMort/ChatGPT.nvim",
  event = "VeryLazy",
  config = function()
    require("chatgpt").setup({
      api_key_cmd = "gopass --password openai/neovim"
    })
  end,
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim"
  },
  {
    "robitx/gp.nvim",
    config = function()
      require("gp").setup({
        openai_api_key = vim.fn.system("gopass --password openai/neovim"),
      })
    end,
  },
}
