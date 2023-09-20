# Neovim Config
My personal [NeoVim](https://github.com/neovim/neovim) config, entirely written in lua.

I shamelessly copied and got inspired from:
- [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim)
- [LazyVim](https://github.com/LazyVim/LazyVim)

I also want to give a shoutout to [ThePrimeagen](https://www.youtube.com/channel/UC8ENHE5xdFSwx71u3fDH5Xw)

## Structure
All of my lua config is either in the `/lua` directory or the `/after/plugin` directory.

### lua directory
- init.lua: Sets the leader keys first and then requires the other lua modules.
- options.lua: Sets basic neovim options that are non plugin specific.
- lazy_setup.lua: Installs and sets up the [lazy.nvim](https://github.com/folke/lazy.nvim) plugin manager.
- keymaps.lua: Sets up keymaps not specific to plugins.
- highlights.lua: Sets up highlights.
- autocommands.lua: Sets up auto commands.

### lua/plugins directory
- Basic plugins go in `plugins.lua`
- Filetype plugins go in `filetype.lua`
- More complex plugins get their own files

### after/plugin directory
- These config files are called after their plugins are set up.

## Plugins I Use

### package manager
- [lazy.nvim](https://github.com/folke/lazy.nvim)

### coding aids & enhancement plugins
- [chrisgrieser/nvim-spider](https://github.com/chrisgrieser/nvim-spider)
- [chrisgrieser/nvim-various-textobjs](https://github.com/chrisgrieser/nvim-various-textobjs)
- [indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim)
- [nvim-colorizer](https://github.com/norcalli/nvim-colorizer.lua)
- [nvim-hlslens](https://github.com/kevinhwang91/nvim-hlslens)
- [nvim-surround](https://github.com/kylechui/nvim-surround)
- [todo-comments.nvim](https://github.com/folke/todo-comments.nvim)
- [unblevable/quick-scope](https://github.com/unblevable/quick-scope)
- [vim-illuminate](https://github.com/RRethy/vim-illuminate)
- [yanky.nvim](https://github.com/gbprod/yanky.nvim)

### dap & debug related plugins
- [jay-babu/mason-nvim-dap.nvim](https://github.com/jay-babu/mason-nvim-dap.nvim)
- [leoluz/nvim-dap-go](https://github.com/leoluz/nvim-dap-go)
- [nvim-dap](https://github.com/mfussenegger/nvim-dap)
- [rcarriga/nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui)
- [trouble.nvim](https://github.com/folke/trouble.nvim)
- [williamboman/mason.nvim](https://github.com/williamboman/mason.nvim)

### filetype plugins
- [chrisbra/csv.vim](https://github.com/chrisbra/csv.vim)
- [fourjay/vim-password-store](https://github.com/fourjay/vim-password-store)
- [leafgarland/typescript-vim](https://github.com/leafgarland/typescript-vim)
- [ledger/vim-ledger](https://github.com/ledger/vim-ledger)
- [MTDL9/vim-log-highlighting](https://github.com/MTDL9/vim-log-highlighting)
- [neomutt/neomutt.vim](https://github.com/neomutt/neomutt.vim)
- [pangloss/vim-javascript](https://github.com/pangloss/vim-javascript)
- [tmhedberg/SimpylFold](https://github.com/tmhedberg/SimpylFold)
- [tmux-plugins/vim-tmux](https://github.com/tmux-plugins/vim-tmux)
- [tridactyl/vim-tridactyl](https://github.com/tridactyl/vim-tridactyl)

### git related plugins
- [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim)
- [tpope/vim-fugitive](https://github.com/tpope/vim-fugitive)

### lsp & related plugins
- [cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp)
- [lsp-zero.nvim](https://github.com/VonHeikemen/lsp-zero.nvim)
- [LuaSnip](https://github.com/L3MON4D3/LuaSnip)
- [mason-lspconfig.nvim](https://github.com/williamboman/mason-lspconfig.nvim)
- [mason.nvim](https://github.com/williamboman/mason.nvim)
- [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)
- [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)

### treesitter & related plugins
- [haringsrob/nvim_context_vt](https://github.com/haringsrob/nvim_context_vt)
- [mini.ai](https://github.com/echasnovski/mini.ai)
- [nvim-treesitter-endwise](https://github.com/RRethy/nvim-treesitter-endwise)
- [nvim-treesitter-textobjects](https://github.com/nvim-treesitter/nvim-treesitter-textobjects)
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
- [nvim-ts-context-commentstring](https://github.com/JoosepAlviste/nvim-ts-context-commentstring)
- [nvim-ts-rainbow](https://github.com/p00f/nvim-ts-rainbow)

### ui, look & feel plugins
- [gruvbox.nvim](https://github.com/ellisonleao/gruvbox.nvim)
- [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim)
- [neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim)
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- [which-key.nvim](https://github.com/folke/which-key.nvim)

### util plugins
- [MunifTanjim/nui.nvim](https://github.com/MunifTanjim/nui.nvim)
- [nvim-lua/plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
- [nvim-tree/nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons)
- [sqlite.lua](https://github.com/kkharji/sqlite.lua)
