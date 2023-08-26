-- lazy_setup.lua
--
-- Install and set up lazy plugin manager

-- Install package manager
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
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

-- Plugins to be installed
-- Help with plugin setup: https://github.com/folke/lazy.nvim#-structuring-your-plugins
require('lazy').setup({

  -- Import any plugin inside the plugins directory
  { import = 'plugins' },
}, {})
