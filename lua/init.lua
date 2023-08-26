-- init.lua

-- Leader keys need to be set first
vim.g.mapleader = ' '
vim.g.maplocalleader = '  '

require('options') -- Import basic neovim options
require('lazy_setup') -- Install lazy plugin manager and set up plugins
require('keymaps') -- Set up non plugin specific keymaps
