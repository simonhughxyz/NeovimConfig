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
