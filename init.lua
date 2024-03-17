-- init.lua
--
-- Only used to boostrap config and to call `lua/config.lua`
-- user config.norg to edit config and then run `:Neorg tangle` to generate `lua/config.lua`

-- NOTE: `lua/config.lua` is generated from config.norg using `tangle`
local result, err = pcall(require, "config")

-- NOTE: Will only be run once to bootstap the norg config
if not(result) then
  -- NOTE: On bootstrap, will see an error that config can'tbe found, this is normal and should be ignored
  -- Close neovim and open again, run `:Neorg tangle` to generate `lua/config.lua` to remove error
  print(err)

  local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
  if not vim.loop.fs_stat(lazypath) then
    vim.fn.system {
      'git',
      'clone',
      '--filter=blob:none',
      'https://github.com/folke/lazy.nvim.git',
      '--branch=stable', -- latest stable release
      lazypath,
    }
  end
  vim.opt.rtp:prepend(lazypath)

  require('lazy').setup({
      {
        "nvim-neorg/neorg",
        -- build = ":Neorg sync-parsers",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        opts = {
          load = {
            ["core.defaults"] = {}, -- Loads default behaviour
          },
        },
      }
    }, {})
end
