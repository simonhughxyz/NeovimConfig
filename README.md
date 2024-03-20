---
title: Neovim Config
description: My personal neovim config
authors: Simon H Moore
categories: 
  - config
  - neovim
  - lua
tangle: 
  languages: 
    lua: ./lua/config.lua
created: 2024-03-06T23:01:44+0100
updated: 2024-03-20T08:49:21+0100
version: 1.1.1
---

 



# INSTALL INSTRUCTIONS

All of my main config is contained in this file `config.norg`, to be able to use this config you have to first `tangle` the file to generate the `config.lua` file.
___
1. Create `lua` directory.
A `lua` directory is needed so that the `config.lua` file can be crated inside of it.
Run the below command inside of your shell at the root of this config:
```sh
mkdir lua
```
2. Open Neovim to bootstrap the config.
A. Because the Lazy.nvim package manager and Neorg plugin is required to `tangle` the config, you have to bootstrap the config for the first time.
Don't worry this happens automatically, you just have to open Neovim by running:
```sh
nvim
```
You will see some errors pop up, don't worry about them this just happens because Neovim expects there to be a config which is not there yet.

B. After this is done, close Neovim again by running the below command:
```vim
:qa
```
4. Tangle the `config.norg` file.
A. Last, we need to `tangle` the config.norg file, to do so open the file with Neovim by running the following command:
```sh
nvim config.norg
```
B. After the `config.norg` file is opened in Neovim, run the following command inside Neovim:
```vim
:Neorg tangle
```
Neovim will ask you which file to tangle, select `config.norg`

5. Reopen Neovim and enjoy
Close and reopen Neovim and the `Lazy` plugin manager will install everything needed.
You might have to reopen Neovim a few times to make sure everything is installed.


# SETUP VARIABLES AND FUNCTIONS

## Leader keys

Used by many plugins for keybindings, need to be set early as plugins can be dependant on it.
___
```lua
vim.g.mapleader = ' '
vim.g.maplocalleader = '  '
```

## API Variables

Declare common API variables, will be used throughout the config.
___



```
local o = vim.opt
local g = vim.g
local cmd = vim.cmd
```


## Global Print Table Function

The `P()` function can be used globally to print a lua table for inspection.
___
```lua
P = function(v)
  print(vim.inspect(v))
  return v
end
```


## Lazy Helper Function

The `plug()` function is used to add plugins to the `plugins` table.
The `plugins` table will be used by lazy to install and load plugins.
___
```lua
local plugins = {}

function plug(plugin)
  plugins[#plugins +1] = plugin
end
```


# OPTIONS

Configure inbuilt Neovim options.
___
```lua
o.autowrite = true           -- Enable auto write
o.clipboard = "unnamedplus"  -- Sync with system clipboard
o.completeopt = "menu,menuone,noselect"
o.conceallevel = 3           -- Hide * markup for bold and italic
o.confirm = true             -- Confirm to save changes before exiting modified buffer
o.cursorline = true          -- Enable highlighting of the current line
o.breakindent = true         -- Every like wrapped will honor indent
o.expandtab = true           -- Use spaces instead of tabs
o.formatoptions = "jcroqlnt" -- tcqj
o.grepformat = "%f:%l:%c:%m"
o.grepprg = "rg --vimgrep"
o.ignorecase = true      -- Ignore case
o.inccommand = "nosplit" -- preview incremental substitute
o.laststatus = 0
o.list = true            -- Show some invisible characters (tabs...
o.mouse = "a"            -- Enable mouse mode
o.number = true          -- Print line number
o.pumblend = 10          -- Popup blend
o.pumheight = 10         -- Maximum number of entries in a popup
o.relativenumber = true  -- Relative line numbers
o.scrolloff = 4          -- Lines of context
o.sessionoptions = { "buffers", "curdir", "tabpages", "winsize" }
o.shiftround = true      -- Round indent
o.shiftwidth = 2         -- Size of an indent
o.shortmess:append({ W = true, I = true, c = true })
o.showmode = false       -- Dont show mode since we have a statusline
o.sidescrolloff = 8      -- Columns of context
o.signcolumn = "yes"     -- Always show the signcolumn, otherwise it would shift the text each time
o.smartcase = true       -- Don't ignore case with capitals
o.smartindent = true     -- Insert indents automatically
o.spelllang = { "en" }
o.splitbelow = true      -- Put new windows below current
o.splitright = true      -- Put new windows right of current
o.tabstop = 2            -- Number of spaces tabs count for
o.termguicolors = true   -- True color support
o.timeoutlen = 300
o.undofile = true
o.undolevels = 10000
o.updatetime = 200               -- Save swap file and trigger CursorHold
o.wildmode = "longest:full,full" -- Command-line completion mode
o.winminwidth = 5                -- Minimum window width
o.wrap = false                   -- Disable line wrap
o.foldlevelstart = 0             -- Enable foldlevel when opening file
o.foldnestmax = 2                -- Set max nested foldlevel
vim.opt.foldenable = true
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldtext = ''
vim.o.fillchars = 'fold: '

if vim.fn.has("nvim-0.9.0") == 1 then
  o.splitkeep = "screen"
  o.shortmess:append({ C = true })
end

-- use powershell on windows
if vim.fn.has("win32") == 1 then
  o.shell = vim.fn.executable "pwsh" == 1 and "pwsh" or "powershell"
  o.shellcmdflag =
  "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
  o.shellredir = "-RedirectStandardOutput %s -NoNewWindow -Wait"
  o.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit LastExitCode"
  o.shellquote = ""
  o.shellxquote = ""
end

-- if in a wsl environment WSL_DISTRO_NAME should be set
local in_wsl = os.getenv('WSL_DISTRO_NAME') ~= nil

if in_wsl then
  -- Need to install win32yank in windows
  -- see https://mitchellt.com/2022/05/15/WSL-Neovim-Lua-and-the-Windows-Clipboard.html
  vim.g.clipboard = {
    name = "win32yank-wsl",
    copy = {
      ["+"] = "win32yank.exe -i --crlf",
      ["*"] = "win32yank.exe -i --crlf",
    },
    paste = {
      ["+"] = "win32yank.exe -o --lf",
      ["*"] = "win32yank.exe -o --lf",
    },
    cache_enabled = true,
  }
end
```


# SYNTAX HIGHLIGHTS & COLOR

Here I set up the color and syntax used in Neovim buffers.
___

## Options

Enable true color support:
___
```lua
o.termguicolors = true
```

## Gruvebox Colorscheme

A port of gruvbox community theme to lua with treesitter and semantic highlights support.
___
```lua
plug({
 "ellisonleao/gruvbox.nvim",
 enabled = true,
 lazy = false,
 priority = 10000,
 config = function()
   require("gruvbox").setup({
     transparent_mode = true,
     terminal_colors = false, -- disable gruvbox in terminal
     overrides = {
       Folded = { bg = "#202020" },
       -- fix markdown todo colors
       ["@lsp.type.class.markdown"] = { fg = "#000000" },
       ["@neorg.tags.ranged_verbatim.code_block"] = { bg = "#222222" },
     }
   })
   o.background = "dark"
   g.gruvbox_italic = true
   g.gruvbox_bold = false
   g.gruvbox_transparent_bg = true
   g.gruvbox_constrast_dark = "hard"
   g.gruvbox_improved_strings = false
   cmd([[colorscheme gruvbox]])
 end,
 })
```

## Indent Blankline

This plugin adds indentation guides to all lines.
___
```lua
plug({
  "lukas-reineke/indent-blankline.nvim",
  enabled = true,
  event = { "BufReadPost", "BufNewFile" },
  main = "ibl",
  opts = {
    exclude = {
      filetypes = {
        "help",
        "alpha",
        "dashboard",
        "fugitive",
        "neo-tree",
        "Trouble",
        "lazy",
        "mason",
        "notify",
        "toggleterm",
        "lazyterm",
        "lspinfo",
        "packer",
        "checkhealth",
        "help",
        "man",
        "gitcommit",
        "TelescopePrompt",
        "TelescopeResults",
      },
    },
  },
})
```

## Colorizer

Color highlighter, shows color of color codes
___
```lua
plug({
  "norcalli/nvim-colorizer.lua",
  enabled = true,
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    default_options = {
      RGB = true,
      RRGGBB = true,
      names = true,
      RRGGBBAA = true,
      rgb_fn = true,
      hsl_fn = true,
      css = true,
      css_fn = true,
      mode = "background",
    },
    "*", -- highlight all files
  },
})
```

## Rainbow

Use different colors for matching brackets.
___
```lua
plug({
  "p00f/nvim-ts-rainbow",
  event = { "BufReadPost", "BufNewFile" },
  main = 'nvim-treesitter.configs',
  opts = {
    -- for nvim-ts-rainbow plugin
    rainbow = {
      enable = true,
      extended_mode = true,   -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
      max_file_lines = 10000, -- Do not enable for files with more than 10000 lines, int
      -- colors = {}, -- table of hex strings
      -- termcolors = {} -- table of colour name strings
    },
  }
})
```

## Sentiment

To highlight the outer pair of brackets/parenthesis.
___
```lua
plug({
  "utilyre/sentiment.nvim",
  version = "*",
  event = "VeryLazy", -- keep for lazy loading
  opts = {
    -- config
  },
  init = function()
    -- `matchparen.vim` needs to be disabled manually in case of lazy loading
    vim.g.loaded_matchparen = 1
  end,
})
```

## Headlines

This plugin adds highlights for text filetypes, like markdown, orgmode, and neorg.
___
[GitHub](https://github.com/lukas-reineke/headlines.nvim)
```lua
plug({
  "lukas-reineke/headlines.nvim",
  dependencies = "nvim-treesitter/nvim-treesitter",
  config = function()

    vim.cmd [[highlight Headline1 guibg=#1e2718]]
    vim.cmd [[highlight Headline2 guibg=#21262d]]
    vim.cmd [[highlight CodeBlock guibg=#1c1c1c]]
    vim.cmd [[highlight Dash guibg=#D19A66 gui=bold]]
    require("headlines").setup {
      norg = {
        query = vim.treesitter.query.parse(
                "norg",
                [[
                    [
                        (heading1_prefix)
                        (heading2_prefix)
                        (heading3_prefix)
                        (heading4_prefix)
                        (heading5_prefix)
                        (heading6_prefix)
                    ] @headline

                    (weak_paragraph_delimiter) @dash
                    (strong_paragraph_delimiter) @doubledash

                    ([(ranged_tag
                        name: (tag_name) @_name
                        (#eq? @_name "code")
                    )
                    (ranged_verbatim_tag
                        name: (tag_name) @_name
                        (#eq? @_name "code")
                    )] @codeblock (#offset! @codeblock 0 0 1 0))

                    (quote1_prefix) @quote
                ]]
            ),
        headline_highlights = { "Headline1", "Headline2" },
            bullet_highlights = {
                "@neorg.headings.1.prefix",
                "@neorg.headings.2.prefix",
                "@neorg.headings.3.prefix",
                "@neorg.headings.4.prefix",
                "@neorg.headings.5.prefix",
                "@neorg.headings.6.prefix",
            },
            bullets = { "◉", "○", "✸", "✿" },
            codeblock_highlight = false,
            dash_highlight = "Dash",
            dash_string = "-",
            doubledash_highlight = "DoubleDash",
            doubledash_string = "=",
            quote_highlight = "Quote",
            quote_string = "┃",
            fat_headlines = true,
            fat_headline_upper_string = "▃",
            fat_headline_lower_string = "🬂",
        },
    }

  end,
})
```

# UI

Here we configure the user interface for Neovim.
___

## Lualine

A blazing fast and easy to configure Neovim statusline written in Lua.
___
[GitHub](https://github.com/nvim-lualine/lualine.nvim)
```lua
local colors = {
 black = "#000000",
 white = "#ffffff",
 gray = "#444444",
 light_gray = "#666666",
 background = "#0c0c0c",
 green = "#005000",
 yellow = "#706000",
 blue = "#004090",
 paste = "#5518ab",
 red = "#800000",
}

local lualine_theme = {
 normal = {
   a = { fg = colors.white, bg = colors.green },
   b = { fg = colors.white, bg = colors.grey },
   c = { fg = colors.white, bg = colors.black },
 },

 insert = { a = { fg = colors.white, bg = colors.blue } },
 command = { a = { fg = colors.white, bg = colors.red } },
 visual = { a = { fg = colors.white, bg = colors.yellow } },
 replace = { a = { fg = colors.white, bg = colors.red } },

 inactive = {
   a = { fg = colors.white, bg = colors.black },
   b = { fg = colors.white, bg = colors.black },
   c = { fg = colors.light_gray, bg = colors.black },
 },
}

plug({
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function()
      return {
        options = {
          theme = lualine_theme,
          component_separators = { left = "", right = "" },
          section_separators = { left = "|", right = "|" },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = {
            {
              "filename",
              path = 4
            },
          },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {
            {
              "filename",
              path = 4
            },
          },
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {},
        },
        tabline = {},
        winbar = {
          lualine_c = {
            {
              "filename",
              path = 4,
            },
            "navic"
          },
        },
        inactive_winbar = {
          lualine_c = {
              {
                "filename",
                path = 3
              }
            },
        },
        extensions = {},
      }
    end,
  },
})
```

## Dressing

Neovim plugin to improve the default vim.ui interfaces.
___
[GitHub](https://github.com/stevearc/dressing.nvim)
```lua
plug({
  'stevearc/dressing.nvim',
  opts = {},
})
```

## Notify

A fancy, configurable notification manager for NeoVim.
___
[GitHub](https://github.com/rcarriga/nvim-notify)
```lua
plug({
  "rcarriga/nvim-notify",
  enabled = true,
  lazy = false,
  config = function ()
    local notify = require("notify")
    notify.setup({
      minimum_width = 20,
      max_width = 50,
      max_height = 50,
      render = "compact",
      timeout = 1000,
      top_down = true
    })
    vim.notify = notify
    pcall(require('telescope').load_extension, "notify")
  end,
  keys = {
    {
      "<leader>;n",
      function () require("telescope").extensions.notify.notify() end,
      desc = "Notificiation History"
    },
  }
})
```

# NEORG

An all-encompassing tool based around structured note taking, project and task management, time tracking, slideshows, writing typeset documents and much more.
___
[GitHub](https://github.com/nvim-neorg/neorg)
[Spec](https://github.com/nvim-neorg/norg-specs/blob/main/1.0-specification.norg)
```lua
plug({
  "nvim-neorg/neorg",
  build = ":Neorg sync-parsers",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "Pocco81/true-zen.nvim",
    "nvim-neorg/neorg-telescope",
    "nvim-treesitter/nvim-treesitter",
    "nvim-treesitter/nvim-treesitter-textobjects",
    "hrsh7th/nvim-cmp",
  },
  config = function()
    require("neorg").setup({
      load = {
        ["core.defaults"] = {}, -- Loads default behaviour
        ["core.concealer"] = {  -- Adds pretty icons to your documents
          config = {
            foldlevelstart = "0",
            icon_preset = "diamond",
            icons = {
              code_block = {
                width = "content",
                min_width = 85,
                conceal = true,
              },
            },
          },
        },
        ["core.dirman"] = { -- Manages Neorg workspaces
          config = {
            workspaces = {
              documents = "~/Documents",
              notes = "~/Documents/Notes",
              career = "~/Documents/Career",
              profiles = "~/Documents/Profiles",
            },
            default_workspace = "documents",
          },
        },
        ["core.completion"] = {
          config = {
            engine = 'nvim-cmp',
            name = "[Norg]",
          }
        },
        ["core.integrations.nvim-cmp"] = {},
        ["core.qol.toc"] = {
          config = {
            close_split_on_jump = true,
            toc_split_placement = "right",
          }
        },
        ["core.export"] = {},
        ["core.export.markdown"] = {
          config = {
            extensions = "all",
          }
        },
        ["core.integrations.telescope"] = {},
        ["core.presenter"] = {
          config = {
            zen_mode = "truezen",
          }
        },
        ["core.journal"] = {
          config = {
            workspace = "journal",
            strategy = "flat",
          }
        },
        ["core.summary"] = {},
        ["core.esupports.metagen"] = { config = { type = "auto", update_date = true } },
      }
    })

    local neorg_callbacks = require("neorg.core.callbacks")

    neorg_callbacks.on_event("core.keybinds.events.enable_keybinds", function(_, keybinds)
      -- Map all the below keybinds only when the "norg" mode is active
      keybinds.map_event_to_mode("norg", {
        n = { -- Bind keys in normal mode
          { "<localleader>ff", "core.integrations.telescope.find_norg_files",  opts = { desc = 'Find Norg Files' } },
          { "<localleader>fl", "core.integrations.telescope.find_linkable",    opts = { desc = 'Find Linkable' } },
          { "<localleader>sh", "core.integrations.telescope.search_headings",  opts = { desc = 'Search Headings' } },
          { "<localleader>sw", "core.integrations.telescope.switch_workspace", opts = { desc = 'Switch Workspace' } },
          { "<localleader>cg", "core.looking-glass.magnify-code-block", opts = { desc = 'Looking Glass' } },
        },

        i = { -- Bind in insert mode
          { "<C-l>",  "core.integrations.telescope.insert_link",      opts = { desc = 'Insert Link' } },
          { "<C-L>", "core.integrations.telescope.insert_file_link", opts = { desc = 'Insert Neorg File Link' } },
        },
      }, {
        silent = true,
        noremap = true,
      })
    end)
  end,
})
```

# TELESCOPE

## Telescope

A highly extendable fuzzy finder over lists, files, buffers, git status and more.
___
[GitHub](https://github.com/nvim-telescope/telescope.nvim)
```lua
plug({
 "nvim-telescope/telescope.nvim",
 enabled = true,
 lazy = false,
 dependencies = {
   'nvim-lua/plenary.nvim',
   -- Fuzzy Finder Algorithm which requires local dependencies to be built.
   -- Only load if `make` is available. Make sure you have the system
   -- requirements installed.
   {
     'nvim-telescope/telescope-fzf-native.nvim',
     -- NOTE: If you are having trouble with this installation,
     --       refer to the README for telescope-fzf-native for more instructions.
     build = 'make',
     cond = function()
       return vim.fn.executable 'make' == 1
     end,
   },
 },
 config = function()
   require('telescope').setup{
     defaults = {
       mappings = {
         n = {
           ['<c-d>'] = require('telescope.actions').delete_buffer
         }, -- n
         i = {
           ["<C-h>"] = "which_key",
           ['<c-d>'] = require('telescope.actions').delete_buffer
         } -- i
       } -- mappings
     }, -- defaults
   }

   -- Enable telescope fzf native, if installed
   pcall(require('telescope').load_extension, 'fzf')

   local ts = require('telescope.builtin')

   local fuzzy_search = function()
     -- You can pass additional configuration to telescope to change theme, layout, etc.
     ts.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
       winblend = 10,
       previewer = false,
     })
   end

   -- Shortcuts
   vim.keymap.set('n', '<leader>?', ts.oldfiles, { desc = 'Find Recently Files' })
   vim.keymap.set('n', '<leader>,', ts.buffers, { desc = 'Find buffers' })
   vim.keymap.set('n', '<leader>/', fuzzy_search , { desc = 'Fuzzy Search in buffer' })

   -- Find Files
   vim.keymap.set('n', '<leader>ff', ts.find_files, { desc = 'Find Files' })
   vim.keymap.set('n', '<leader>fb', ts.buffers, { desc = 'Find Buffers' })
   vim.keymap.set('n', '<leader>fr', ts.oldfiles, { desc = 'Find Recent Files' })
   vim.keymap.set('n', '<leader>fg', ts.git_files, { desc = 'Find Git Files' })
   vim.keymap.set('n', '<leader>fs', ts.git_status, { desc = 'Find Git Status' })
   vim.keymap.set('n', '<leader>fS', ts.git_stash, { desc = 'Find Git Stash' })

   vim.keymap.set('n', '<leader>fd', function() ts.find_files({ cwd = '~/Documents' }) end,
     { desc = 'Find Documents' })
   vim.keymap.set('n', '<leader>fD', function() ts.find_files({ cwd = '~/Downloads' }) end,
     { desc = 'Find Downloads' })
   vim.keymap.set('n', '<leader>fp', function() ts.find_files({ cwd = '~/Projects' }) end, { desc = 'Find Projects' })
   vim.keymap.set('n', '<leader>fc', function() ts.find_files({ cwd = vim.fn.stdpath('config') }) end,
     { desc = 'Find Config' })
   vim.keymap.set('n', '<leader>fB', function() ts.find_files({ cwd = '~/.local/bin' }) end,
     { desc = 'Find Local Bin' })

   -- Search for content, help and functions
   vim.keymap.set('n', '<leader>sc', ts.git_commits, { desc = 'Search Git Commits' })
   vim.keymap.set('n', '<leader>st', ts.builtin, { desc = 'Search Telescope' })
   vim.keymap.set('n', '<leader>sh', ts.help_tags, { desc = 'Search Help' })
   vim.keymap.set('n', '<leader>sw', ts.grep_string, { desc = 'Search Current Word' })
   vim.keymap.set('n', '<leader>sg', ts.live_grep, { desc = 'Search by Grep' })
   vim.keymap.set('n', '<leader>sd', ts.diagnostics, { desc = 'Search Diagnostics' })
   vim.keymap.set('n', '<leader>sk', ts.keymaps, { desc = 'Search Keymaps' })
   vim.keymap.set('n', "<leader>s'", ts.marks, { desc = 'Search Marks' })
   vim.keymap.set('n', '<leader>s"', ts.registers, { desc = 'Search Registers' })
   vim.keymap.set('n', '<leader>sf', fuzzy_search , { desc = 'Fuzzy Search in buffer' })

 end,
})
```


## Telescope Sessions Picker

Load nvim session files from target directory.
___
[GitHub](https://github.com/JoseConseco/telescope_sessions_picker.nvim)
```lua
plug({
 "JoseConseco/telescope_sessions_picker.nvim",
 enabled = true,
 lazy = true,
 config = function()
   require('telescope').load_extension('sessions_picker')
 end,
 keys = {
   { "<leader>sS",
     function() require('telescope').extensions.sessions_picker.sessions_picker() end,
     desc = "Search Neovim Sessions"
   },
 }
})
```


## Telescope Tmux

A Telescope.nvim extension for fuzzy-finding over tmux targets.
___
[GitHub](https://github.com/camgraff/telescope-tmux.nvim)
```lua
plug({ -- https://github.com/camgraff/telescope-tmux.nvim
 "camgraff/telescope-tmux.nvim",
 enabled = true,
 lazy = true,
 config = function ()
   require('telescope').load_extension('tmux')
 end,
 keys = {
   { "<leader>ss",
     function() require('telescope').extensions.tmux.sessions({}) end,
     desc = "Search Tmux Sessions"
   },
 }
})
```


## Telescope Tabs

A Telescope.nvim extension for fuzzy-finding over vim tabs.
___
[GitHub](https://github.com/LukasPietzschmann/telescope-tabs)
```lua
plug({
 'LukasPietzschmann/telescope-tabs',
 dependencies = { 'nvim-telescope/telescope.nvim' },
 enabled = true,
 lazy = true,
 config = function()
   require('telescope').load_extension 'telescope-tabs'
   require('telescope-tabs').setup {
     show_preview = true,
   }
 end,
 keys = {
   {"<tab>", mode = { "n" }, function() require("telescope-tabs").list_tabs() end, desc = "Open Tabs"}
 }
})
```

## URL VIEW

Extracts URL's from buffer for search in telescope
___
[GitHub](https://github.com/axieax/urlview.nvim)
```lua
plug({
  "axieax/urlview.nvim",
  enabled = true,
  lazy = true,
  config = function()
    require("urlview").setup({
      default_picker = "telescope",
      log_level_min = 4,
    })
  end,
  keys = {
    {
      "<leader>su",
      "<Cmd>UrlView<CR>",
      desc = "View buffer URLs",
    },
    {
      "<leader>sU",
      "<Cmd>UrlView lazy<CR>",
      desc = "View lazy plugin URLs",
    },
  },
})
```

# FILE NAVIGATION

## Oil

A file explorer that lets you edit your filesystem like a normal Neovim buffer.
___
[GitHub](https://github.com/stevearc/oil.nvim)
```lua
plug({
   "stevearc/oil.nvim",
   dependencies = { "nvim-tree/nvim-web-devicons" },
   enabled = true,
   lazy = true,
   config = function ()
     require("oil").setup({
       default_file_explorer = true,
     })

   end,
   cmd = "Oil",
   keys = {
     { "<leader>o", function() require("oil").toggle_float() end, desc = "Oil File Manager" },
     { "<leader>O", function() require("oil").toggle_float(vim.fn.getcwd()) end, desc = "Oil File Manager" },
   }
})
```

## Neo-Tree

To browse the file system and other tree like structures
___
[GitHub](https://github.com/nvim-neo-tree/neo-tree.nvim)
```lua
plug({
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
    "MunifTanjim/nui.nvim",
  },
  cmd = "Neotree",
  keys = {
    {
      "<leader>e",
      function()
        require("neo-tree.command").execute({ toggle = true, dir = vim.loop.cwd() })
      end,
      desc = "Explorer NeoTree",
    },
    {
      "<leader>be",
      function()
        require("neo-tree.command").execute({ toggle = true, source = "buffers"  })
      end,
      desc = "Explorer NeoTree Buffers",
    },
  },
  deactivate = function()
    vim.cmd([[Neotree close]])
  end,
  opts = {
    sources = { "filesystem", "buffers", "git_status", "document_symbols" },
    open_files_do_not_replace_types = { "terminal", "Trouble", "qf", "Outline" },
    filesystem = {
      bind_to_cwd = false,
      follow_current_file = { enabled = true },
      use_libuv_file_watcher = true,
    },
    window = {
      mappings = {
        ["<space>"] = "none",
      },
    },
    default_component_configs = {
      indent = {
        with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
        expander_collapsed = "",
        expander_expanded = "",
        expander_highlight = "NeoTreeExpander",
      },
    },
  },
})
```

## Harpoon

A per project file bookmark plugin
___
[GitHub](https://github.com/ThePrimeagen/harpoon)
```lua
plug({
  'ThePrimeagen/harpoon',
  enabled = true,
  dependencies = { 'nvim-lua/plenary.nvim' },
  opts = {},
  config = function()
    -- enable telescope extension
    local tsh = require("telescope").load_extension('harpoon')

    -- set keymaps
    vim.keymap.set('n', "<leader>'a", require('harpoon.mark').add_file, { desc = 'Harpoon Add File' })
    vim.keymap.set('n', "<leader>']", require('harpoon.ui').nav_next, { desc = 'Harpoon Next' })
    vim.keymap.set('n', "<leader>'[", require('harpoon.ui').nav_prev, { desc = 'Harpoon Previous' })
    vim.keymap.set("n", "<leader>fh", tsh.marks, { desc = "Find Harpoon" })

    for i = 1, 9 do
      vim.keymap.set('n', "<leader>'" .. i, function() require('harpoon.ui').nav_file(i) end,
        { desc = 'Harpoon Nav File' })
    end

    require('which-key').register({
      ['<leader>'] = {
        ["'"] = { name = "+Harpoon" },
      },
    })
  end,
})
```

## Project.nvim

An all in one neovim plugin written in lua that provides superior project management.
___
[GitHub](https://github.com/ahmedkhalf/project.nvim)
```lua
plug({
  "ahmedkhalf/project.nvim",
  enabled = true,
  lazy = false,
  config = function()
    require("project_nvim").setup({
      detection_methods = { "lsp", "pattern" },
      patterns = { ".project", ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json" },
      silent_chdir = false,
    })

    pcall(require('telescope').load_extension('projects'))
  end,
  keys = {
    {
      "<leader>sp",
      function() require('telescope').load_extension('projects').projects() end,
      desc = 'Search for Project',
    },
  },
})
```

# BUFFER NAVIGATION

## EYELINER

Move faster with unique f/F indicators for each word on the line.
___
[GitHub](https://github.com/jinh0/eyeliner.nvim)
```lua
plug({
  "jinh0/eyeliner.nvim",
  priority = 200,
  keys = { "f", "F", "t", "T" },
  opts = {
    highlight_on_key = true,
    dim = true
  },
  init = function()
    vim.api.nvim_create_autocmd('ColorScheme', {
      pattern = '*',
      callback = function()
        vim.api.nvim_set_hl(0, 'EyelinerPrimary', { fg = '#aa00aa', bold = true, underline = false })
        vim.api.nvim_set_hl(0, 'EyelinerSecondary', { fg = '#a0f050', bold = true, underline = false })
      end,
    })
  end,
})
```

## ILLUMINATE

Neovim plugin for automatically highlighting other uses of the word under the cursor using either LSP, Tree-sitter, or regex matching.
___
[GitHub](https://github.com/RRethy/vim-illuminate)
```lua
plug({
  "RRethy/vim-illuminate",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    delay = 200,
    large_file_cutoff = 2000,
    large_file_overrides = {
      providers = { "lsp" },
    },
  },
  config = function(_, opts)
    require("illuminate").configure(opts)

    local function map(key, dir, buffer)
      vim.keymap.set("n", key, function()
        require("illuminate")["goto_" .. dir .. "_reference"](false)
      end, { desc = dir:sub(1, 1):upper() .. dir:sub(2) .. " Reference", buffer = buffer })
    end

    map("]]", "next")
    map("[[", "prev")

    -- also set it after loading ftplugins, since a lot overwrite [[ and ]]
    vim.api.nvim_create_autocmd("FileType", {
      callback = function()
        local buffer = vim.api.nvim_get_current_buf()
        map("]]", "next", buffer)
        map("[[", "prev", buffer)
      end,
    })
  end,
  keys = {
    { "]]", desc = "Next Reference" },
    { "[[", desc = "Prev Reference" },
  },
})
```

## Nvim Spider

Use the w, e, b motions like a spider. Move by subwords and skip insignificant punctuation.
___
[GitHub](https://github.com/chrisgrieser/nvim-spider)
```lua
plug({
  "chrisgrieser/nvim-spider",
  enabled = true,
  lazy = false,
  config = function()
    vim.keymap.set({ "n", "o", "x" }, "w", "<cmd>lua require('spider').motion('w')<cr>", { desc = "Spider-w" })
    vim.keymap.set({ "n", "o", "x" }, "e", "<cmd>lua require('spider').motion('e')<cr>", { desc = "Spider-e" })
    vim.keymap.set({ "n", "o", "x" }, "b", "<cmd>lua require('spider').motion('b')<cr>", { desc = "Spider-b" })
    vim.keymap.set({ "n", "o", "x" }, "ge", "<cmd>lua require('spider').motion('ge')<cr>", { desc = "Spider-ge" })
  end,
})
```

## Leap

A general-purpose motion plugin for Neovim.
___
[GitHub](https://github.com/ggandor/leap.nvim)
```lua
plug({ -- https://github.com/ggandor/leap.nvim
  "ggandor/leap.nvim",
  enabled = true,
  config = function ()
    local leap = require('leap')
    leap.create_default_mappings()
    leap.opts = {
      highlight_unlabeled_phase_one_targets = true,
      safe_labels = 'jfkdls;agh',
      labels = 'jfkdls;aghvncmir',
    }
  end,
})
```

# GIT

## Fugitive

A git wrapper plugin.
___
[GitHub](https://github.com/tpope/vim-fugitive)
```lua
plug({
  'tpope/vim-fugitive',
  enabled = true,
  lazy = true,
  keys = {
    { "<leader>gg",
      "<cmd>Git<cr>",
      desc = "Git"
    },
    { "<leader>gp",
      "<cmd>Git push<cr>",
      desc = "Git Push"
    },
    { "<leader>gP",
      "<cmd>Git pull<cr>",
      desc = "Git Pull"
    },
    { "<leader>gl",
      "<cmd>Git log<cr>",
      desc = "Git Log"
    },
    { "<leader>gd",
      "<cmd>Git diff<cr>",
      desc = "Git Diff"
    },
  }
})
```

## Gitsigns

Adds git related signs to the gutter, as well as utilities for managing changes
___
[GitHub](https://github.com/lewis6991/gitsigns.nvim)
```lua
plug({
  'lewis6991/gitsigns.nvim',
  enabled = true,
  opts = {
    -- See `:help gitsigns.txt`
    on_attach = function(bufnr)
      local gs = package.loaded.gitsigns
      vim.keymap.set('n', '[h', gs.prev_hunk, { buffer = bufnr, desc = 'Go to Previous Hunk' })
      vim.keymap.set('n', ']h', gs.next_hunk, { buffer = bufnr, desc = 'Go to Next Hunk' })
      vim.keymap.set('n', '<leader>hs', gs.stage_hunk, { buffer = bufnr, desc = 'Git Stage Hunk' })
      vim.keymap.set('n', '<leader>hS', gs.stage_buffer, { buffer = bufnr, desc = 'Git Stage Entire Buffer' })
      vim.keymap.set('n', '<leader>hr', gs.reset_hunk, { buffer = bufnr, desc = 'Git Reset Hunk' })
      vim.keymap.set('n', '<leader>hR', gs.reset_buffer, { buffer = bufnr, desc = 'Git Reset Entire Buffer' })
      vim.keymap.set('v', '<leader>hs', function() gs.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end,
        { buffer = bufnr, desc = 'Git Stage Selected Hunk' })

      vim.keymap.set('v', '<leader>gr', function() gs.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end,
        { buffer = bufnr, desc = 'Git Reset Selected Hunk' })

      vim.keymap.set('n', '<leader>hu', gs.undo_stage_hunk, { buffer = bufnr, desc = 'Git Undo Stage Hunk' })
      vim.keymap.set('n', '<leader>ht', gs.toggle_deleted, { buffer = bufnr, desc = 'Git Toggle Deleted' })
      vim.keymap.set('n', '<leader>hd', gs.diffthis, { buffer = bufnr, desc = 'Git Diff Hunk' })
      vim.keymap.set('n', '<leader>hD', function() gs.diffthis('~') end, { buffer = bufnr, desc = 'Git Diff Hunk' })
      vim.keymap.set('n', '<leader>hp', gs.preview_hunk, { buffer = bufnr, desc = 'Git Preview Hunk' })
      vim.keymap.set('n', '<leader>hb', gs.blame_line, { buffer = bufnr, desc = 'Git Blame Line' })
      vim.keymap.set('n', '<leader>hB', gs.toggle_current_line_blame,
        { buffer = bufnr, desc = 'Git Blame Line Toggle' })

      -- Text object
      vim.keymap.set({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'Hunk' })
      vim.keymap.set({ 'o', 'x' }, 'ah', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'Hunk' })
    end,
  },
})
```

## Diffview

Single tabpage interface for easily cycling through diffs for all modified files for any git rev.
___
[GitHub](https://github.com/sindrets/diffview.nvim)
```lua
plug({
  "sindrets/diffview.nvim",
  enabled = true,
  lazy = true,
  keys = {
    {
      "<leader>dd",
      "<cmd>DiffviewOpen<cr>",
      desc = "Open Diff View",
    }
  },
})
```

# LSP

Language Server Protocol
___
The Language Server Protocol (LSP) defines the protocol used between an editor or IDE and a language server that provides language features like auto complete, go to definition, find all references etc. The goal of the Language Server Index Format (LSIF, pronounced like "else if") is to support rich code navigation in development tools or a Web UI without needing a local copy of the source code.
___
[Official LSP Home](https://microsoft.github.io/language-server-protocol/)
```lua
plug({
-- Collection of functions that will help you setup Neovim's LSP client
'VonHeikemen/lsp-zero.nvim',
branch = 'v3.x',
dependencies = {
  -- LSP Support
  { 'neovim/nvim-lspconfig' },             -- Required
  { 'williamboman/mason.nvim' },           -- Optional
  { 'williamboman/mason-lspconfig.nvim' }, -- Optional

  -- Format
  { 'onsails/lspkind.nvim' }, -- shows icons on completion menu
  { 'kosayoda/nvim-lightbulb' },
  {
    'weilbith/nvim-code-action-menu',
    cmd = 'CodeActionMenu',
  },

  -- Autocompletion
  { 'hrsh7th/nvim-cmp' },
  { 'hrsh7th/cmp-nvim-lsp' },
  {
    'L3MON4D3/LuaSnip',
    dependencies = { "rafamadriz/friendly-snippets" },
  },
  { 'nvimtools/none-ls.nvim',     dependencies = { 'nvim-lua/plenary.nvim' } },
  { "jay-babu/mason-null-ls.nvim" },

  { 'saadparwaiz1/cmp_luasnip' },
  { 'hrsh7th/cmp-nvim-lua' },
  { 'hrsh7th/cmp-buffer' },
  { 'hrsh7th/cmp-cmdline' },
  { 'hrsh7th/cmp-path' },
  { 'hrsh7th/cmp-emoji' },
  { 'hrsh7th/cmp-calc' },
},
config = function()
  local lsp_zero = require('lsp-zero')

  lsp_zero.on_attach(function(client, bufnr)
    -- see :help lsp-zero-keybindings
    -- to learn the available actions
    lsp_zero.default_keymaps({ buffer = bufnr })

    local opts = function(desc)
      return { buffer = bufnr, remap = false, desc = desc }
    end

    local ts = require('telescope.builtin')

    vim.keymap.set({ 'n', 'x' }, '<leader>lf', function()
      vim.lsp.buf.format({ async = false, timeout_ms = 10000 })
    end, opts('Lsp format buffer'))

    vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts("Go To Next Diagnostic"))
    vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts("Go To Previous Diagnostic"))
    -- vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts("Go To Definition"))
    vim.keymap.set("n", "gd", ts.lsp_definitions, opts("Go To Definition"))
    vim.keymap.set("n", "<leader>la", function() vim.lsp.buf.code_action() end, opts("Code Action"))
    vim.keymap.set("n", "<leader>lh", function() vim.lsp.buf.hover() end, opts("Hover"))
    vim.keymap.set("n", "<leader>lH", function() vim.lsp.buf.signature_help() end, opts("Signiture Help"))
    -- vim.keymap.set("n", "<leader>ls", function() vim.lsp.buf.workspace_symbol() end, opts("Workspace Symbol"))
    vim.keymap.set("n", "<leader>ls", ts.lsp_workspace_symbols, opts("Workspace Symbol"))
    -- vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts("Open Float"))
    -- vim.keymap.set("n", "<leader>lr", function() vim.lsp.buf.references() end, opts("References"))
    vim.keymap.set("n", "<leader>lr", ts.lsp_references, opts("References"))
    vim.keymap.set("n", "<leader>li", function() vim.lsp.buf.implementation() end, opts("Implementation"))
    vim.keymap.set("n", "<leader>lR", function() vim.lsp.buf.rename() end, opts("Rename"))
    vim.keymap.set("n", "<leader>lI", '<cmd>LspInfo<CR>', opts("LspInfo"))
  end)

  require('mason').setup({})
  require('mason-lspconfig').setup({
    ensure_installed = {
      'lua_ls',
      'bashls',
      'pyright',    -- python
      'html',
      'clangd',
      "marksman",   -- markdown
    },
    handlers = {
      lsp_zero.default_setup,
      lua_ls = function()
        local lua_opts = lsp_zero.nvim_lua_ls()
        require('lspconfig').lua_ls.setup(lua_opts)
      end,
      marksman = function()
        require('lspconfig').marksman.setup({})
      end,
    }
  })

  -- Open Mason UI
  vim.keymap.set("n", "<leader>;m", "<cmd>Mason<cr>", { desc = "Mason Plugin Manager" })

  local null_ls = require("null-ls")

  local o = vim.o
  null_ls.setup({
    sources = {
      null_ls.builtins.formatting.stylua.with({ extra_args = { '--indent_type=spaces', '--indent_width=' .. o.tabstop } }),
      null_ls.builtins.diagnostics.eslint,
      null_ls.builtins.diagnostics.trail_space,

      null_ls.builtins.formatting.black, -- python formatting

      null_ls.builtins.completion.spell,
      null_ls.builtins.diagnostics.codespell,
      null_ls.builtins.diagnostics.write_good,

      null_ls.builtins.formatting.prettierd,
      null_ls.builtins.diagnostics.markdownlint, -- markdown
    },
  })

  require("mason-null-ls").setup({
    ensure_installed = {
      "stylua",
      "ruff",  -- python linter
      "mypy",  -- python type checker
      "black", -- python formatter
      "eslint",
      "trail_space",
      "spell",
      "codespell",
      "write_good",
      "prettierd",
      "markdownlint", -- markdown linter
    }
  })

  local cmp = require('cmp')
  local cmp_action = require('lsp-zero').cmp_action()

  -- load snippets
  require('luasnip.loaders.from_lua').lazy_load({ paths = './snippets/' })
  require('luasnip.loaders.from_vscode').lazy_load()


  local types = require("luasnip.util.types")

  require('luasnip').config.set_config({
    -- This one is cool cause if you have dynamic snippets, it updates as you type!
    updateevents = "TextChanged,TextChangedI",

    enable_autosnippets = true,

    ext_opts = {
      [types.choiceNode] = {
        active = {
          virt_text = { { " ⬅️c ", "NonTest" } },
        },
      },
      [types.insertNode] = {
        active = {
          virt_text = { { " ⬅️t", "NonTest" } },
        },
      },
    },
  })

  -- snippet keymap
  vim.keymap.set("i", "<c-o>", require "luasnip.extras.select_choice")
  vim.keymap.set("n", "<leader>csc", require "luasnip.extras.select_choice")
  vim.keymap.set("i", "<c-d>", "<Plug>luasnip-next-choice")
  vim.keymap.set("s", "<c-d>", "<Plug>luasnip-next-choice")
  vim.keymap.set("i", "<c-u>", "<Plug>luasnip-prev-choice")
  vim.keymap.set("s", "<c-u>", "<Plug>luasnip-prev-choice")

  cmp.setup({
    sources = {
      { name = 'nvim_lsp' }, -- completion for neovim
      { name = 'nvim_lua' }, -- completion for neovim lua api
      { name = 'luasnip' },  -- show snippets
      { name = 'buffer' },   -- show elements from your buffer
      { name = 'path' },     -- show file paths
      { name = 'calc' },     -- completion for math calculation
      { name = 'emoji' },    -- show emoji's
    },
    snippet = {
      expand = function(args)
        require('luasnip').lsp_expand(args.body)
      end,
    },
    mapping = cmp.mapping.preset.insert({
      ['<CR>'] = cmp.mapping.confirm({ select = false }),
      -- scroll up and down the documentation window
      ['<C-u>'] = cmp.mapping.scroll_docs(-4),
      ['<C-d>'] = cmp.mapping.scroll_docs(4),

      ['<C-l>'] = cmp_action.luasnip_jump_forward(),
      ['<C-h>'] = cmp_action.luasnip_jump_backward(),
    }),
    formatting = {
      fields = { 'abbr', 'kind', 'menu' },
      format = require('lspkind').cmp_format({
        mode = 'symbol_text',  -- show only symbol annotations
        maxwidth = 50,         -- prevent the popup from showing more than provided characters
        ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead
      })
    }
  })

  -- `/` cmdline setup.
  cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' }
    }
  })

  -- `:` cmdline setup.
  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    })
  })

  require("nvim-lightbulb").setup({
    autocmd = { enabled = true },
    virtual_text = {
      enabled = true,
      text = '󰌵'
    },
  })
end,
})
```

# DEBUG

A Debug Adapter Protocol client implementation for Neovim
___
[GitHub](https://github.com/mfussenegger/nvim-dap)
```lua
plug({
'mfussenegger/nvim-dap',
dependencies = {
  -- Creates a beautiful debugger UI
  'rcarriga/nvim-dap-ui',

  -- add virtual text
  'theHamsta/nvim-dap-virtual-text',

  -- Installs the debug adapters for you
  'williamboman/mason.nvim',
  'jay-babu/mason-nvim-dap.nvim',

  -- Add your own debuggers here
  { 'leoluz/nvim-dap-go',           ft = { 'go' } },
  { 'mfussenegger/nvim-dap-python', ft = { 'python' } },
},
config = function()
  local dap = require("dap")
  local dapui = require("dapui")
  local mason_registry = require("mason-registry")

  require("mason-nvim-dap").setup {
    -- Makes a best effort to setup the various debuggers with
    -- reasonable debug configurations
    automatic_setup = true,

    -- You can provide additional configuration to the handlers,
    -- see mason-nvim-dap README for more information
    handlers = {},

    -- You'll need to check that you have the required things installed
    -- online, please don't ask me how to install them :)
    ensure_installed = {
      -- Update this to ensure that you have the debuggers for the langs you want
      'delve',
      'debugpy',
    },
  }

  -- Basic debugging keymaps, feel free to change to your liking!
  vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debug: Start/Continue' })
  vim.keymap.set('n', '<F1>', dap.step_into, { desc = 'Debug: Step Into' })
  vim.keymap.set('n', '<F2>', dap.step_over, { desc = 'Debug: Step Over' })
  vim.keymap.set('n', '<F3>', dap.step_out, { desc = 'Debug: Step Out' })
  vim.keymap.set('n', '<F4>', dap.step_back, { desc = 'Debug: Step Back' })
  vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
  vim.keymap.set('n', '<leader>dB', dap.set_breakpoint, { desc = 'Debug: Set Breakpoint' })
  vim.keymap.set('n', '<leader>dl', dap.run_last, { desc = 'Debug: Run Last' })
  vim.keymap.set('n', '<leader>dc', function()
    dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
  end, { desc = 'Debug: Set Breakpoint Condition' })

  -- Add virtual text showing contained values
  require("nvim-dap-virtual-text").setup({
    highlight_new_as_changed = true, -- highlight new variables in the same way as changed variables (if highlight_changed_variables)
    only_first_definition = false,   -- only show virtual text at first definition (if there are multiple)
  })

  -- Dap UI setup
  -- For more information, see |:help nvim-dap-ui|
  dapui.setup {
    -- Set icons to characters that are more likely to work in every terminal.
    --    Feel free to remove or use ones that you like more! :)
    --    Don't feel like these are good choices.
    icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
    controls = {
      icons = {
        pause = '⏸',
        play = '▶',
        step_into = '⏎',
        step_over = '⏭',
        step_out = '⏮',
        step_back = 'b',
        run_last = '▶▶',
        terminate = '⏹',
        disconnect = '⏏',
      },
    },
  }

  -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
  vim.keymap.set('n', '<F7>', dapui.toggle, { desc = 'Debug: See last session result.' })

  dap.listeners.after.event_initialized['dapui_config'] = dapui.open
  dap.listeners.before.event_terminated['dapui_config'] = dapui.close
  dap.listeners.before.event_exited['dapui_config'] = dapui.close

  -- Setup golang dap
  require('dap-go').setup()

  -- Setup python dap
  local debug_py_path = mason_registry.get_package("debugpy"):get_install_path() .. "/venv/bin/python"
  require('dap-python').setup(debug_py_path)
end,
})
```

# TEXT MANIPULATION

## Comment.nvim

Smart and Powerful commenting plugin for neovim
___
[GitHub](https://github.com/numToStr/Comment.nvim)
```lua
plug({ 'numToStr/Comment.nvim', opts = {} })
```

## Dial.nvim

Extended increment/decrement plugin
___
[GitHub](https://github.com/monaqa/dial.nvim)
```lua
plug({
 'monaqa/dial.nvim',
 config = function()
   local augend = require("dial.augend")
   require("dial.config").augends:register_group {
     -- default augends used when no group name is specified
     default = {
       augend.integer.alias.decimal,  -- nonnegative decimal number (0, 1, 2, 3, ...)
       augend.constant.alias.bool,    -- boolean value (true <-> false)
       augend.integer.alias.hex,      -- nonnegative hex number  (0x01, 0x1a1f, etc.)
       augend.date.alias["%Y/%m/%d"], -- date (2022/02/19, etc.)
       augend.date.alias["%Y-%m-%d"],
       augend.date.alias["%m/%d"],
       augend.date.alias["%H:%M"],
       augend.constant.new {
         elements = { "and", "or" },
         word = true,   -- if false, "sand" is incremented into "sor", "doctor" into "doctand", etc.
         cyclic = true, -- "or" is incremented into "and".
         preserve_case = true,
       },
       augend.constant.new {
         elements = { "yes", "no" },
         word = true,   -- if false, "sand" is incremented into "sor", "doctor" into "doctand", etc.
         cyclic = true, -- "or" is incremented into "and".
         preserve_case = true,
       },
       augend.constant.new {
         elements = { "&&", "||" },
         word = false,
         cyclic = true,
       },
     },
   }

   vim.keymap.set("n", "<C-a>", require("dial.map").inc_normal(), { noremap = true })
   vim.keymap.set("n", "<C-x>", require("dial.map").dec_normal(), { noremap = true })
   vim.keymap.set("n", "g<C-a>", require("dial.map").inc_gnormal(), { noremap = true })
   vim.keymap.set("n", "g<C-x>", require("dial.map").dec_gnormal(), { noremap = true })
   vim.keymap.set("v", "<C-a>", require("dial.map").inc_visual(), { noremap = true })
   vim.keymap.set("v", "<C-x>", require("dial.map").dec_visual(), { noremap = true })
   vim.keymap.set("v", "g<C-a>", require("dial.map").inc_gvisual(), { noremap = true })
   vim.keymap.set("v", "g<C-x>", require("dial.map").dec_gvisual(), { noremap = true })
 end,
})
```

## Nvim-Surround

Add, delete, change and select surrounding pairs
___
[GitHub](https://github.com/kylechui/nvim-surround)
```lua
plug({
 "kylechui/nvim-surround",
 version = "*", -- Use for stability; omit to use `main` branch for the latest features
 event = "VeryLazy",
 config = function()
   require("nvim-surround").setup({
     -- Configuration here, or leave empty to use defaults
   })
 end,
})
```

## Nvim-various-textobjs

Bundle of more than two dozen new textobjects for Neovim.
___
[GitHub](https://github.com/chrisgrieser/nvim-various-textobjs)
```lua
plug({
  "chrisgrieser/nvim-various-textobjs",
  lazy = false,
  opts = {
    useDefaultKeymaps = true,
    disabledKeymaps = { "gc" },
  },
})
```

## Treesj

A plugin for splitting/joining blocks of code like arrays, hashes, statements, objects, dictionaries and more.
___
[GitHub](https://github.com/Wansmer/treesj)
```lua
plug({
  "Wansmer/treesj",
  dependencies = "nvim-treesitter/nvim-treesitter",
  keys = {
    { "<leader>j", function() require("treesj").toggle() end, desc = "󰗈 Split-join lines" },
  },
})
```

## Text case

Case conversion, upper to lower to camel to snake and more.
___
[GitHub](https://github.com/johmsalas/text-case.nvim)
```lua
plug({
  "johmsalas/text-case.nvim",
  init = function()
    local casings = {
      { char = "u", arg = "upper",      desc = "UPPER CASE" },
      { char = "l", arg = "lower",      desc = "lower case" },
      { char = "t", arg = "title",      desc = "Title Case" },
      { char = "c", arg = "camel",      desc = "camelCase" },
      { char = "C", arg = "pascal",     desc = "CamelCase" },
      { char = "s", arg = "snake",      desc = "snake_case" },
      { char = "_", arg = "snake",      desc = "snake_case" },
      { char = "d", arg = "dash",       desc = "dash-case" },
      { char = "D", arg = "title_dash", desc = "Title-Dash-Case" },
      { char = "-", arg = "dash",       desc = "dash-case" },
      { char = "p", arg = "phrase",     desc = "Phrase case" },
      { char = "/", arg = "path",       desc = "path/case" },
      { char = "S", arg = "constant",   desc = "UPPER_SNAKE_CASE" },
      { char = ".", arg = "dot",        desc = "dot.case" },
    }

    for _, case in pairs(casings) do
      vim.keymap.set(
        "n",
        "<leader>c" .. case.char,
        ("<cmd>lua require('textcase').current_word('to_%s_case')<CR>"):format(case.arg),
        { desc = case.desc }
      )
      vim.keymap.set(
        "v",
        "<leader>c" .. case.char,
        ("<cmd>lua require('textcase').operator('to_%s_case')<CR>"):format(case.arg),
        { desc = case.desc }
      )
      vim.keymap.set(
        "n",
        "<leader>C" .. case.char,
        ("<cmd>lua require('textcase').lsp_rename('to_%s_case')<CR>"):format(case.arg),
        { desc = "󰒕 " .. case.desc }
      )
    end
  end,
})
```

## Autolist

Automatic list continuation and formatting.
___
[GitHub](https://github.com/gaoDean/autolist.nvim)
```lua
plug({
  "gaoDean/autolist.nvim",
  ft = {
    "markdown",
    "text",
    "tex",
    "plaintex",
    "norg",
  },
  config = function()
    require("autolist").setup()

    -- vim.keymap.set("i", "<tab>", "<cmd>AutolistTab<cr>")
    -- vim.keymap.set("i", "<s-tab>", "<cmd>AutolistShiftTab<cr>")
    -- vim.keymap.set("i", "<c-t>", "<c-t><cmd>AutolistRecalculate<cr>") -- an example of using <c-t> to indent
    vim.keymap.set("i", "<CR>", "<CR><cmd>AutolistNewBullet<cr>")
    vim.keymap.set("n", "o", "o<cmd>AutolistNewBullet<cr>")
    vim.keymap.set("n", "O", "O<cmd>AutolistNewBulletBefore<cr>")
    vim.keymap.set("n", "<CR>", "<cmd>AutolistToggleCheckbox<cr><CR>")
    vim.keymap.set("n", "<C-r>", "<cmd>AutolistRecalculate<cr>")

    -- cycle list types with dot-repeat
    vim.keymap.set("n", "<leader>ln", require("autolist").cycle_next_dr, { expr = true })
    vim.keymap.set("n", "<leader>lp", require("autolist").cycle_prev_dr, { expr = true })

    -- if you don't want dot-repeat
    -- vim.keymap.set("n", "<leader>cn", "<cmd>AutolistCycleNext<cr>")
    -- vim.keymap.set("n", "<leader>cp", "<cmd>AutolistCycleNext<cr>")

    -- functions to recalculate list on edit
    vim.keymap.set("n", ">>", ">><cmd>AutolistRecalculate<cr>")
    vim.keymap.set("n", "<<", "<<<cmd>AutolistRecalculate<cr>")
    vim.keymap.set("n", "dd", "dd<cmd>AutolistRecalculate<cr>")
    vim.keymap.set("v", "d", "d<cmd>AutolistRecalculate<cr>")
  end,
})
```

# TERMINAL

## Toggle Term

Persist and toggle multiple terminals during an editing session.
___
[GitHub](https://github.com/akinsho/toggleterm.nvim)
```lua
plug({
  'akinsho/toggleterm.nvim',
  version = "*",
  opts = {},
  config = function()
    require("toggleterm").setup()

    -- set keymaps to toggle toggleterm
    vim.keymap.set('n', '<c-b>', [[<Cmd>exe v:count1 . "ToggleTerm size=12 direction=horizontal"<CR>]],
      { desc = 'Toggle Term Horizontal' })
    vim.keymap.set('i', '<c-b>', [[<Cmd>exe v:count1 . "ToggleTerm size=12 direction=horizontal"<CR>]],
      { desc = 'Toggle Term Horizontal' })
    vim.keymap.set('t', '<c-b>', [[<Cmd>exe v:count1 . "ToggleTerm size=12 direction=horizontal"<CR>]],
      { desc = 'Toggle Term Horizontal' })

    vim.keymap.set('n', '<c-t>', [[<Cmd>exe v:count1 . "ToggleTerm size=80 direction=vertical"<CR>]],
      { desc = 'Toggle Term Vertical' })
    vim.keymap.set('i', '<c-t>', [[<Cmd>exe v:count1 . "ToggleTerm size=80 direction=vertical"<CR>]],
      { desc = 'Toggle Term Vertical' })
    vim.keymap.set('t', '<c-t>', [[<Cmd>exe v:count1 . "ToggleTerm size=80 direction=vertical"<CR>]],
      { desc = 'Toggle Term Vertical' })

    vim.keymap.set('n', '<c-f>', [[<Cmd>exe v:count1 . "ToggleTerm size=80 direction=float"<CR>]],
      { desc = 'Toggle Term Vertical' })
    vim.keymap.set('i', '<c-f>', [[<Cmd>exe v:count1 . "ToggleTerm size=80 direction=float"<CR>]],
      { desc = 'Toggle Term Vertical' })
    vim.keymap.set('t', '<c-f>', [[<Cmd>exe v:count1 . "ToggleTerm size=80 direction=float"<CR>]],
      { desc = 'Toggle Term Vertical' })

    local terminal = require("toggleterm.terminal").Terminal

    -- Set up task warrior Vit tui app toggle
    local vit = terminal:new({
      cmd = "vit",
      count = 1000,
      direction = "horizontal",
      hidden = true,
      close_on_exit = true,
      auto_scroll = false,
      start_in_insert = true,
    })

    vim.keymap.set({"n", "i", "t", "v"}, "<cm-v>", function () vit:toggle() end, {noremap = true, silent = true, desc = "Toggle Vit"})

    -- Set up powershell toggle term
    local powershell = terminal:new({
      cmd = "powershell.exe",
      count = 2,
      direction = "horizontal",
      hidden = false,
      close_on_exit = false,
      auto_scroll = true,
      start_in_insert = true,
    })

    vim.keymap.set({"n", "i", "t", "v"}, "<cm-p>", function () powershell:toggle() end, {noremap = true, silent = true, desc = "Toggle Powershell"})
  end,
})
```

## Flatten

Open files from terminal buffers without creating a nested session.
___
[GitHub](https://github.com/willothy/flatten.nvim)
```lua
plug({
   "willothy/flatten.nvim",
   branch = "1.0-dev",
   opts = function()
     ---@type Terminal?
     local saved_terminal

     return {
       window = {
         open = "alternate",
       },
       callbacks = {
         should_block = function(argv)
           -- Note that argv contains all the parts of the CLI command, including
           -- Neovim's path, commands, options and files.
           -- See: :help v:argv

           -- In this case, we would block if we find the `-b` flag
           -- This allows you to use `nvim -b file1` instead of
           -- `nvim --cmd 'let g:flatten_wait=1' file1`
           return vim.tbl_contains(argv, "-b")

           -- Alternatively, we can block if we find the diff-mode option
           -- return vim.tbl_contains(argv, "-d")
         end,
         pre_open = function()
           local term = require("toggleterm.terminal")
           local termid = term.get_focused_id()
           saved_terminal = term.get(termid)
         end,
         post_open = function(bufnr, winnr, ft, is_blocking)
           if is_blocking and saved_terminal then
             -- Hide the terminal while it's blocking
             saved_terminal:close()
           else
             -- If it's a normal file, just switch to its window
             vim.api.nvim_set_current_win(winnr)
           end

           -- If the file is a git commit, create one-shot autocmd to delete its buffer on write
           -- If you just want the toggleable terminal integration, ignore this bit
           if ft == "gitcommit" or ft == "gitrebase" then
             vim.api.nvim_create_autocmd("BufWritePost", {
               buffer = bufnr,
               once = true,
               callback = vim.schedule_wrap(function()
                 vim.api.nvim_buf_delete(bufnr, {})
               end),
             })
           end
         end,
         block_end = function()
           -- After blocking ends (for a git commit, etc), reopen the terminal
           vim.schedule(function()
             if saved_terminal then
               saved_terminal:open()
               saved_terminal = nil
             end
           end)
         end,
       },
     }
   end,
})
```

# VIM TABLE MODE

Table creator & formatter allowing one to create neat tables as you type.
___
[GitHub](https://github.com/dhruvasagar/vim-table-mode)
```lua
plug({ "https://github.com/dhruvasagar/vim-table-mode" })
```

# TODO COMMENTS

To highlight and search for todo comments like TODO, HACK, BUG in your code base.
___
[GitHub](https://github.com/folke/todo-comments.nvim)
```lua
plug({
  "folke/todo-comments.nvim",
  enabled = true,
  cmd = { "TodoTrouble", "TodoTelescope" },
  event = { "BufReadPost", "BufNewFile" },
  config = true,
  -- stylua: ignore
  keys = {
    { "]t",         function() require("todo-comments").jump_next() end, desc = "Next todo comment" },
    { "[t",         function() require("todo-comments").jump_prev() end, desc = "Previous todo comment" },
    { "<leader>xt", "<cmd>TodoTrouble<cr>",                              desc = "Todo (Trouble)" },
    { "<leader>xT", "<cmd>TodoTrouble keywords=TODO,FIX,FIXME<cr>",      desc = "Todo/Fix/Fixme (Trouble)" },
    { "<leader>st", "<cmd>TodoTelescope<cr>",                            desc = "Todo" },
    { "<leader>sT", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>",    desc = "Todo/Fix/Fixme" },
  },
})
```

# MARKS

A better user experience for interacting with and manipulating Vim marks.
___
[GitHub](https://github.com/chentoast/marks.nvim)
```lua
plug({
  'chentoast/marks.nvim',
  enabled = true,
  config = function()
    require 'marks'.setup {
      default_mappings = true,
      signs = true,
      mappings = {}
    }
  end,
})
```

# MARKDOWN

## Nvim Toc

Generate table of contents for markdown files.
___
[GitHub](https://github.com/richardbizik/nvim-toc)
```lua
plug({
  'richardbizik/nvim-toc',
  ft = { 'markdown' },
  config = function()
    require('nvim-toc').setup({})
  end,
})
```

## Glow

Preview markdown code directly in your neovim terminal.
___

### Requirements

You must install `Glow`.
[GitHub](https://github.com/ellisonleao/glow.nvim)
```lua
plug({
  "ellisonleao/glow.nvim",
  config = true,
  cmd = "Glow",
})
```

## Preview

Preview Markdown in your modern browser with synchronised scrolling and flexible configuration.
___
[GitHub](https://github.com/iamcco/markdown-preview.nvim)
```lua
plug({
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  ft = { "markdown" },
  build = function() vim.fn["mkdp#util#install"]() end,
})
```

## Hl-MDCodeblock

Add treesitter highlights to markdown code blocks.
___
[GitHub](https://github.com/yaocccc/nvim-hl-mdcodeblock.lua)
```lua
plug({
  'yaocccc/nvim-hl-mdcodeblock.lua',
  dependencies = {'nvim-treesitter/nvim-treesitter'},
  config = function()
    require('hl-mdcodeblock').setup({
      -- option
    })
  end
})
```

# TROUBLE

A pretty list for showing diagnostics, references, telescope results, quickfix
and location lists to help you solve all the trouble your code is causing.
___
[GitHub](https://github.com/folke/trouble.nvim)
```lua
plug({
  "folke/trouble.nvim",
  enabled = true,
  lazy = true,
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    { "<leader>xx", function() require("trouble").open() end, desc = "Trouble" },
    { "<leader>xw", function() require("trouble").open("workspace_diagnostics") end, desc = "Workspace Diagnostics" },
    { "<leader>xd", function() require("trouble").open("document_diagnostics") end, desc = "Document Diagnostics" },
    { "<leader>xq", function() require("trouble").open("quickfix") end, desc = "Quickfix" },
    { "<leader>xl", function() require("trouble").open("loclist") end, desc = "Local List" },
    { "gR", function() require("trouble").open("lsp_references") end, desc = "Lsp References" },
  },
})
```

# WHICH KEY

A lua plugin that displays a popup with possible key bindings of the command you started typing.
___
[GitHub](https://github.com/folke/which-key.nvim)
```lua
plug({
  'folke/which-key.nvim',
  enabled = true,
  config = function()
    local wk = require('which-key')

    wk.register({
      ['<leader>'] = {
        ["<Tab>"] = { name = '+Tab' },
        [";"] = { name = '+Command' },
        b = { name = '+Buffer' },
        c = { name = '+Case' },
        C = { name = '+Case' },
        d = { name = '+Debug' },
        f = { name = '+Find' },
        g = { name = '+Git' },
        h = { name = '+Hunk' },
        l = { name = '+Lsp' },
        s = { name = '+Search' },
        t = { name = '+Table' },
        T = { name = '+Text' },
        w = { name = '+Window' },
        x = { name = '+Diagnostics' },
      },
    })
  end,
})
```

# HLSLENS

Nvim-hlslens helps you better glance at matched information, seamlessly jump between matched instances.
When searching, search count is shown next to the cursor as virtual text.
___
[GitHub](https://github.com/kevinhwang91/nvim-hlslens)
```lua
plug({
  "kevinhwang91/nvim-hlslens",
  enabled = true,
  opts = {},
})
```

# YANKY

Improve yank and put functionalities for Neovim.
___
[GitHub](https://github.com/gbprod/yanky.nvim)
```lua
plug({
  "gbprod/yanky.nvim",
  dependencies = {
    {
      "kkharji/sqlite.lua",
      enabled = not jit.os:find("Windows")
    },
  },
  config = function()
    require("yanky").setup({
      ring = {
        history_length = 100,
        -- storage = "shada",
        sync_with_numbered_registers = true,
        cancel_event = "update",
      },
      picker = {
        select = {
          action = nil, -- nil to use default put action
        },
        -- telescope = {
        --   use_default_mappings = true, -- if default mappings should be used
        --   mappings = nil, -- nil to use default mappings or no mappings (see `use_default_mappings`)
        -- },
      },
      system_clipboard = {
        sync_with_ring = true,
      },
      highlight = {
        on_put = true,
        on_yank = true,
        timer = 500,
      },
      preserve_cursor_position = {
        enabled = true,
      },
    })
  end,
  opts = function()
    local mapping = require("yanky.telescope.mapping")
    local mappings = mapping.get_defaults()
    mappings.i["<c-p>"] = nil
    return {
      highlight = { timer = 200 },
      ring = { storage = jit.os:find("Windows") and "shada" or "sqlite" },
      picker = {
        telescope = {
          use_default_mappings = false,
          mappings = mappings,
        },
      },
    }
  end,
  keys = {
    -- stylua: ignore
    {
      "<leader>p",
      function() require("telescope").extensions.yank_history.yank_history({}) end,
      desc =
        "Open Yank History"
    },
    {
      "y",
      "<Plug>(YankyYank)",
      mode = { "n", "x" },
      desc =
        "Yank text"
    },
    {
      "p",
      "<Plug>(YankyPutAfter)",
      mode = { "n", "x" },
      desc =
        "Put yanked text after cursor"
    },
    {
      "P",
      "<Plug>(YankyPutBefore)",
      mode = { "n", "x" },
      desc =
        "Put yanked text before cursor"
    },
    {
      "gp",
      "<Plug>(YankyGPutAfter)",
      mode = { "n", "x" },
      desc =
        "Put yanked text after selection"
    },
    {
      "gP",
      "<Plug>(YankyGPutBefore)",
      mode = { "n", "x" },
      desc =
        "Put yanked text before selection"
    },
    {
      "[y",
      "<Plug>(YankyCycleForward)",
      desc =
        "Cycle forward through yank history"
    },
    {
      "]y",
      "<Plug>(YankyCycleBackward)",
      desc =
        "Cycle backward through yank history"
    },
    {
      "]p",
      "<Plug>(YankyPutIndentAfterLinewise)",
      desc =
        "Put indented after cursor (linewise)"
    },
    {
      "[p",
      "<Plug>(YankyPutIndentBeforeLinewise)",
      desc =
        "Put indented before cursor (linewise)"
    },
    {
      "]P",
      "<Plug>(YankyPutIndentAfterLinewise)",
      desc =
        "Put indented after cursor (linewise)"
    },
    {
      "[P",
      "<Plug>(YankyPutIndentBeforeLinewise)",
      desc =
        "Put indented before cursor (linewise)"
    },
    {
      ">p",
      "<Plug>(YankyPutIndentAfterShiftRight)",
      desc =
        "Put and indent right"
    },
    {
      "<p",
      "<Plug>(YankyPutIndentAfterShiftLeft)",
      desc =
        "Put and indent left"
    },
    {
      ">P",
      "<Plug>(YankyPutIndentBeforeShiftRight)",
      desc =
        "Put before and indent right"
    },
    {
      "<P",
      "<Plug>(YankyPutIndentBeforeShiftLeft)",
      desc =
        "Put before and indent left"
    },
    {
      "=p",
      "<Plug>(YankyPutAfterFilter)",
      desc =
        "Put after applying a filter"
    },
    {
      "=P",
      "<Plug>(YankyPutBeforeFilter)",
      desc =
        "Put before applying a filter"
    },
  },
})
```

# BIGFILE

This plugin automatically disables certain features if the opened file is big. File size and features to disable are configurable.
___
[GitHub](https://github.com/LunarVim/bigfile.nvim)
```lua
plug({ -- https://github.com/LunarVim/bigfile.nvim
  "LunarVim/bigfile.nvim",
  enabled = true,
  event = { "FileReadPre", "BufReadPre", "User FileOpened" },
  config = function ()
    require("bigfile").setup {
      filesize = 2, -- size of the file in MiB, the plugin round file sizes to the closest MiB
      pattern = { "*" }, -- autocmd pattern or function see <### Overriding the detection of big files>
      features = { -- features to disable
        "indent_blankline",
        "illuminate",
        "lsp",
        "treesitter",
        "syntax",
        "matchparen",
        "vimopts",
        "filetype",
      },
    }
  end
})
```

# MINI SESSIONS

Session management (read, write, delete)
___
[GitHub](https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-sessions.md)
```lua
plug({
  'echasnovski/mini.sessions',
  version = false,
  config = function()
    require('mini.sessions').setup({
    })

    vim.api.nvim_create_user_command(
      'SessionWrite',
      function(opts)
        if (opts['args']) then
          MiniSessions.write(opts.args)
        end
      end,
      { nargs = 1 }
    )
  end,
})
```

# TREESITTER

## Treesitter

The goal of nvim-treesitter is both to provide a simple and easy way to use the interface for tree-sitter in Neovim and to provide some basic functionality such as highlighting based on it.
___
[GitHub](https://github.com/nvim-treesitter/nvim-treesitter)
```lua
plug({
  -- Highlight, edit, and navigate code
  'nvim-treesitter/nvim-treesitter',
  priority = 5000,
  dependencies = {
    'nvim-treesitter/nvim-treesitter-textobjects',
    { "JoosepAlviste/nvim-ts-context-commentstring", lazy = true }
  },
  build = ':TSUpdate',
  main = 'nvim-treesitter.configs',
  opts = {
    -- Add languages to be installed here that you want installed for treesitter
    ensure_installed = {
      'lua',
      'vim',
      'vimdoc',
      'norg',
      'regex',
      'bash',
      'c',
      'cpp',
      'make',
      'markdown',
      'markdown_inline',
      'comment',
      'html',
      'php',
      'http',
      'css',
      'javascript',
      'typescript',
      'go',
      'python',
      'json',
      'toml',
      'yaml',
      'sql',
      'r',
      'gitattributes',
      'gitignore',
    },

    -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
    auto_install = true,

    highlight = { enable = true },
    indent = { enable = true },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = '<c-space>',
        node_incremental = '<c-space>',
        scope_incremental = '<c-s>',
        node_decremental = '<M-space>',
      },
    },

    textobjects = {
      select = {
        enable = true,
        lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ['aa'] = '@parameter.outer',
          ['ia'] = '@parameter.inner',
          ['af'] = '@function.outer',
          ['if'] = '@function.inner',
          ['ac'] = '@class.outer',
          ['ic'] = '@class.inner',
        },
      },
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          [']m'] = '@function.outer',
          [']]'] = '@class.outer',
        },
        goto_next_end = {
          [']M'] = '@function.outer',
          [']['] = '@class.outer',
        },
        goto_previous_start = {
          ['[m'] = '@function.outer',
          ['[['] = '@class.outer',
        },
        goto_previous_end = {
          ['[M'] = '@function.outer',
          ['[]'] = '@class.outer',
        },
      },
      swap = {
        enable = true,
        swap_next = {
          ['<leader>a'] = '@parameter.inner',
        },
        swap_previous = {
          ['<leader>A'] = '@parameter.inner',
        },
      },
    },

    -- nvim-treesitter-endwise
    endwise = { enable = true },
  }
})
```

## Endwise

Wisely add "end" in Ruby, Lua, Vimscript, etc.
___
[GitHub](https://github.com/RRethy/nvim-treesitter-endwise)
```lua
plug({ -- basically autopair, but for keywords
  "RRethy/nvim-treesitter-endwise",
  -- event = "InsertEnter",
  dependencies = "nvim-treesitter/nvim-treesitter",
})
```

## Virtual Text Context

Shows virtual text of the current context after functions, methods, statements, etc.
___
[GitHub](https://github.com/andersevenrud/nvim_context_vt)
```lua
plug({ -- virtual text context at the end of a scope
  "haringsrob/nvim_context_vt",
  event = "VeryLazy",
  dependencies = "nvim-treesitter/nvim-treesitter",
  opts = {
    prefix = "󱞷",
    highlight = "NonText",
    min_rows = 1,
    disable_ft = { "markdown" },
    min_rows_ft = { python = 10, yaml = 15, css = 15 },

    -- set up custom parser to return the whole line for context
    custom_parser = function(node, _, opts)
      -- If you return `nil`, no virtual text will be displayed.
      if node:type() == 'function' then
        return nil
      end

      -- get the context line
      local bufnr = vim.api.nvim_get_current_buf()
      local start_row, _, _, _ = vim.treesitter.get_node_range(node)
      local line = vim.api.nvim_buf_get_lines(bufnr, start_row, start_row + 1, false)[1]

      -- remove whitespace before context
      local context = string.gsub(line, '^%s*', '')

      return opts.prefix .. ' ' .. context
    end,
  },
})
```

## Mini Ai

Extend and create a/i textobjects.
___
[GitHub](https://github.com/echasnovski/mini.ai)
```lua
plug({ -- extend and create a/i textobjects
  "echasnovski/mini.ai",
  event = "VeryLazy",
  dependencies = { "nvim-treesitter-textobjects" },
  opts = function()
    local ai = require("mini.ai")
    return {
      n_lines = 500,
      custom_textobjects = {
        o = ai.gen_spec.treesitter({
          a = { "@block.outer", "@conditional.outer", "@loop.outer" },
          i = { "@block.inner", "@conditional.inner", "@loop.inner" },
        }, {}),
        f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }, {}),
        c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }, {}),
      },
    }
  end,
  config = function(_, opts)
    require("mini.ai").setup(opts)
    -- register all text objects with which-key
    local i = {
      [" "] = "Whitespace",
      ['"'] = 'Balanced "',
      ["'"] = "Balanced '",
      ["`"] = "Balanced `",
      ["("] = "Balanced (",
      [")"] = "Balanced ) including white-space",
      [">"] = "Balanced > including white-space",
      ["<lt>"] = "Balanced <",
      ["]"] = "Balanced ] including white-space",
      ["["] = "Balanced [",
      ["}"] = "Balanced } including white-space",
      ["{"] = "Balanced {",
      ["?"] = "User Prompt",
      _ = "Underscore",
      a = "Argument",
      b = "Balanced ), ], }",
      c = "Class",
      f = "Function",
      o = "Block, conditional, loop",
      q = "Quote `, \", '",
      t = "Tag",
    }
    local a = vim.deepcopy(i)
    for k, v in pairs(a) do
      a[k] = v:gsub(" including.*", "")
    end

    local ic = vim.deepcopy(i)
    local ac = vim.deepcopy(a)
    for key, name in pairs({ n = "Next", l = "Last" }) do
      i[key] = vim.tbl_extend("force", { name = "Inside " .. name .. " textobject" }, ic)
      a[key] = vim.tbl_extend("force", { name = "Around " .. name .. " textobject" }, ac)
    end
    require("which-key").register({
      mode = { "o", "x" },
      i = i,
      a = a,
    })
  end,
})
```

# LAZY

Set up the `lazy.nvim` plugin manager, use the `plugins` table to install and load plugins.
See [Lazy Helper Function](#lazy-helper-function) for the `plugin()` function.
___
[GitHub](https://github.com/folke/lazy.nvim)

```lua
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
require('lazy').setup(plugins, {})


-- open lazy menu
vim.keymap.set("n", "<leader>;l", "<cmd>Lazy<cr>", { desc = "Lazy Plugin Manager" })
```

# KEYMAPS

Here I configure my native neovim keybindings, these are any key binds not involved with any plugin.
___
```lua
local function map(mode, lhs, rhs, opts)
  local keys = require("lazy.core.handler").handlers.keys
  ---@cast keys LazyKeysHandler
  -- do not create the keymap if a lazy keys handler exists
  if not keys.active[keys.parse({ lhs, mode = mode }).id] then
    opts = opts or {}
    opts.silent = opts.silent ~= false
    if opts.remap and not vim.g.vscode then
      opts.remap = nil
    end
    vim.keymap.set(mode, lhs, rhs, opts)
  end
end

-- better up/down
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Move to window using the <ctrl> hjkl keys
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window", remap = true })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window", remap = true })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window", remap = true })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window", remap = true })

-- Resize window using <ctrl> arrow keys
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- Move Lines
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move down" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move up" })
map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move down" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move up" })

-- Navigate through buffers
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })

map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
map("n", "<leader>`", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })

-- Clear search with <esc>
map({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })

-- Clear search, diff update and redraw
-- taken from runtime/lua/_editor.lua
map(
  "n",
  "<leader>ur",
  "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>",
  { desc = "Redraw / clear hlsearch / diff update" }
)

map({ "n", "x" }, "gw", "*N", { desc = "Search word under cursor" })

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
map("n", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
map("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
map("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
map("n", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })
map("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })
map("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })

-- Add undo break-points
map("i", ",", ",<c-g>u")
map("i", ".", ".<c-g>u")
map("i", ";", ";<c-g>u")

-- save file
map({ "i", "v", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

--keywordprg
map("n", "<leader>K", "<cmd>norm! K<cr>", { desc = "Keywordprg" })

-- better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- new file
map("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New File" })

map("n", "<leader>xl", "<cmd>lopen<cr>", { desc = "Location List" })
map("n", "<leader>xq", "<cmd>copen<cr>", { desc = "Quickfix List" })

-- quit
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })

-- highlights under cursor
if vim.fn.has("nvim-0.9.0") == 1 then
  map("n", "<leader>ui", vim.show_pos, { desc = "Inspect Pos" })
end


-- Terminal Mappings
map("t", "<esc><esc>", "<c-\\><c-n>", { desc = "Enter Normal Mode" })
map("t", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Go to left window" })
map("t", "<C-j>", "<cmd>wincmd j<cr>", { desc = "Go to lower window" })
map("t", "<C-k>", "<cmd>wincmd k<cr>", { desc = "Go to upper window" })
map("t", "<C-l>", "<cmd>wincmd l<cr>", { desc = "Go to right window" })
map("t", "<C-/>", "<cmd>close<cr>", { desc = "Hide Terminal" })
map("t", "<c-_>", "<cmd>close<cr>", { desc = "which_key_ignore" })

-- windows
map("n", "<leader>ww", "<C-W>p", { desc = "Other window", remap = true })
map("n", "<leader>wd", "<C-W>c", { desc = "Delete window", remap = true })
map("n", "<leader>w-", "<C-W>s", { desc = "Split window below", remap = true })
map("n", "<leader>w|", "<C-W>v", { desc = "Split window right", remap = true })
map("n", "<leader>-", "<C-W>s", { desc = "Split window below", remap = true })
map("n", "<leader>|", "<C-W>v", { desc = "Split window right", remap = true })

-- tabs
map("n", "<leader><tab>G", "<cmd>tablast<cr>", { desc = "Last Tab" })
map("n", "<leader><tab>g", "<cmd>tabfirst<cr>", { desc = "First Tab" })
map("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New Tab" })
map("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next Tab" })
map("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close Tab" })
map("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })
map("n", "<leader><tab>s", "<cmd>tab split<cr>", { desc = "Split Tab" })

-- Convenience
map('n', '\\', ':%s//g<left><left>', { desc = "Search buffer" })
map('v', '\\', ':s//g<Left><Left>', { desc = "Search selection" })
map("n", "<leader>S", "<cmd>set spell!<cr>", { desc = "Toggle spell" })

-- Insert file name
map("i", "<C-f>f", '<C-R>=expand("%:t")<cr>', { desc = "Insert current filename" })
map("i", "<C-f>F", '<C-R>=expand("%:t:r")<cr>', { desc = "Insert current filename without extension" })
map("i", "<C-f>e", '<C-R>=expand("%:e")<cr>', { desc = "Insert extendion of current file" })
map("i", "<C-f>p", '<C-R>=expand("%:p:h")<cr>', { desc = "Insert absolute path of current directory" })
map("i", "<C-f>P", '<C-R>=expand("%:h")<cr>', { desc = "Insert relative path of current directory" })
map("i", "<C-f>d", '<C-R>=expand("%:p:h:t")<cr>', { desc = "Insert parent directory of current file" })
```

# HIGHLIGHTS

Here I configure any highlights.
___
```lua
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})
```

# AUTOCOMMANDS

Here I configure any autocommands.
___
```lua
local function augroup(name)
  return vim.api.nvim_create_augroup("shm_" .. name, { clear = true })
end

-- Use internal formatting for bindings like gq.
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    vim.bo[args.buf].formatexpr = nil
  end,
})

-- Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("checktime"),
  command = "checktime",
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- resize splits if window got resized
vim.api.nvim_create_autocmd({ "VimResized" }, {
  group = augroup("resize_splits"),
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

-- go to last loc when opening a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_loc"),
  callback = function()
    local exclude = { "gitcommit" }
    local buf = vim.api.nvim_get_current_buf()
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) then
      return
    end
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "PlenaryTestPopup",
    "help",
    "lspinfo",
    "man",
    "notify",
    "qf",
    "spectre_panel",
    "startuptime",
    "tsplayground",
    "neotest-output",
    "checkhealth",
    "neotest-summary",
    "neotest-output-panel",
    "fugitive",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- close some filetypes with <esc>
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_esc"),
  pattern = {
    "fugitive",
    "git",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "<esc>", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("wrap_spell"),
  pattern = { "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  group = augroup("auto_create_dir"),
  callback = function(event)
    if event.match:match("^%w%w+://") then
      return
    end
    local file = vim.loop.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- disable line numbering and start in insert mode for terminal
vim.api.nvim_create_autocmd({ "TermOpen", "TermEnter" }, {
  group = augroup("terminal"),
  callback = function ()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.cmd("startinsert")
  end,
})

-- reload folds for treesitter bug
-- see https://github.com/nvim-treesitter/nvim-treesitter/issues/1337
vim.api.nvim_create_autocmd({ "BufReadPost" }, {
    group = augroup("folds"),
    callback = function()
        vim.cmd([[ norm zx
        norm zM ]])
    end
})
```

# EXCOMMANDS

Here I configure any custom commands.
___
```lua
local command = vim.api.nvim_create_user_command

command("Shell", function (args)
  local shell = args.args

  if (shell == "powershell") then
    shell = "powershell.exe"
  elseif (shell == "cmd") then
    shell = "cmd.exe"
  end
  vim.cmd("terminal " .. shell)
end, {
    nargs = 1,
    complete = function ()
      return {
        "powershell",
        "cmd",
        "zsh",
        "bash",
        "dash",
      }
    end,
  })
```

# SHM

Here I configure some commonly used personal information.
___
```lua
local shm = {}

shm.name = {
  'Simon H Moore',
  'Simon Hugh Moore',
  'Simon Moore',
  'SH Moore',
}

shm.initials = 'SHM'

shm.email = 'simon@simonhugh.xyz'
shm.workemail = 'simonm@vigoitsolutions.com'

shm.signiture = "Simon H Moore <simon@simonhugh.xyz>"
shm.worksigniture = "Simon H Moore <simonm@vigoitsolutions.com>"
```


# UTILS

Here go any helper utilities and functions.
___
```lua
local util = {}

util.number_ordinal = function(n)
  local last_digit = n % 10
  if last_digit == 1 and n ~= 11
  then
    return 'st'
  elseif last_digit == 2 and n ~= 12
  then
    return 'nd'
  elseif last_digit == 3 and n ~= 13
  then
    return 'rd'
  else
    return 'th'
  end
end

util.datef = function(datestr, date)
  local date = date or os.date("*t", os.time())
  local datestr = string.gsub(datestr, "%%o", M.number_ordinal(date.day))
  return os.date(datestr, os.time(date))
end
```


# SNIPPETS

Here I configure my custom snippets.
___
[Luasnip GitHub](https://github.com/L3MON4D3/LuaSnip)

### Luasnip API Variables

These are used to create snippets.
___
```lua
local ls = require("luasnip")
local snippet = ls.add_snippets
local s = ls.snippet
local t = ls.text_node
local f = ls.function_node
local i = ls.insert_node
local c = ls.choice_node
local d = ls.dynamic_node
local sn = ls.snippet_node
local fmt = require("luasnip.extras.fmt").fmt
```

## Utils

Here I configure snippet related utilities and functions.
___
```lua
local snip_utils = {}

snip_utils.get_name_choice = function()
  local nodes = {}
  for _, name in ipairs(shm.name) do
    table.insert(nodes, t(name))
  end
  return c(1, nodes)
end

snip_utils.shebang = {
  lua = "!/bin/lua",
  sh = "!/bin/sh",
  bash = "!/bin/bash",
  zsh = "!/bin/zsh",
}


snip_utils.get_date_choice = function (arg)
  return c(arg and arg or 1, {
        f(function() return utils.datef("%d%o %B %Y") end),
        f(function() return utils.datef(os.date "%d%o %b %Y") end),
        f(function() return utils.datef(os.date "%a %d%o %b %Y") end),
        f(function() return utils.datef(os.date "%A %d%o %b %Y") end),
        f(function() return utils.datef(os.date "%a %d%o %B %Y") end),
        f(function() return utils.datef(os.date "%A %d%o %B %Y") end),
        f(function() return os.date "%d-%m-%Y" end),
        f(function() return os.date "%d/%m/%Y" end),
        f(function() return os.date "%d-%m-%y" end),
        f(function() return os.date "%d/%m/%y" end),
      })
end

snip_utils.get_header = function(opts)
  opts = opts and opts or {}

  local sntable = {
      c = t(opts.commentstr and opts.commentstr or "# "),
      name = c(1, {
          f(function() return vim.fn.expand("%:t") end),
          f(function() return vim.fn.expand("%:h:t") .. "/" .. vim.fn.expand("%:t") end),
          f(function() return vim.fn.expand("%:t:r") end),
        }),
      author = c(2, {t(shm.signiture), t(shm.worksigniture)}),
      date = M.get_date_choice(3),
      desc = i(4, "Description"),
  }

  local formattable = {
      "{c}filename: {name}",
      "{c}author: {author}",
      "{c}date: {date}",
      "{c}desc: {desc}",
  }

  if opts.shebang then
    table.insert(formattable, 1, "{c}{shebang}")
    sntable.shebang = t(opts.shebang)
  end

  return fmt(table.concat(formattable, "\n"), sntable, {dedent = true})
end
```

## Snippets

```lua
local greeting_choice = function(arg)
  return c(arg and arg or 1, {
    t("Hope you are well."),
    t("I hope you are having a nice day."),
    t("I hope you are having a good morning."),
    t("I hope you are having a nice end to the week."),
    t("Nice speaking to you on the phone the other day."),
  })
end

local message_end = function(arg)
  return c(arg and arg or 1, {
    t("Thank you"),
    t("Kind Regards"),
  })
end


```

### All

Common snippets for all file types.
___
```lua
snippet("all", {
  s({
      trig = 'name',
      priority = 10000,
      desc = 'My name'
    },
    { snip_utils.get_name_choice()
    }),
  s({
      trig = 'email',
      priority = 10000,
      desc = 'My email'
    },
    {
      c(1, {
        t("simon@simonhugh.xyz"),
        t("simonm@vigoitsolutions.com"),
      }),
    }),
  s({
      trig = 'workemail',
      priority = 10000,
      desc = 'Work Email'
    },
    {
      t(shm.workemail)
    }),
  s({
      trig = 'sign',
      priority = 10000,
      desc = 'My signiture'
    },
    {
      c(1, {
        t(shm.signiture),
        t(shm.worksigniture),
      }),
    }),
  s({
      trig = 'worksign',
      priority = 10000,
      desc = 'Work Sign'
    },
    {
      t("Simon H Moore <simonm@vigoitsolutions.com>")
    }),
  s({
      trig = 'date',
      priority = 10000,
      desc = 'Current date'
    },
    { snip_utils.get_date_choice()
    }),
  s({
      trig = 'americandate',
      priority = 10000,
      desc = 'Current american date, month comes first',
    },
    {
      c(1, {
        f(function() return os.date "%m/%d/%Y" end),
        f(function() return os.date "%m-%d-%Y" end),
        f(function() return os.date "%m/%d/%y" end),
        f(function() return os.date "%m-%d-%y" end),
      })
    }),
  s({
      trig = 'time',
      priority = 10000,
      desc = 'Current time',
    },
    {
      c(1, {
        f(function() return os.date "%H:%M" end),
        f(function() return os.date "%I:%M %p" end),
        f(function() return os.date "%H:%M:%S" end),
        f(function() return os.date "%I:%M:%S %p" end),
      })
    }),
  s({
    trig = 'vigogreeting',
    desc = 'A greeting for vigo email'
  }, fmt([[
      Hi {name},

      {greeting}
      ]], {
          name = i(1, "Name"),
          greeting = greeting_choice(2),
        }
    )
  ),
  s({
    trig = "vigopass",
    desc = "Complete builds message"
  }, fmt([[
      Hi {name},

      {greeting}

      I am currently setting up your {device} and I need your password to continue. Could you send it to me please?
      If you feel uncomfortable sharing your password over email{passmsg}

      Could you also send me a list of apps you would like to see installed?

      {outmsg},
      Simon
      ]], {
          name = i(1, "Name"),
          --NOTE: Could separate out the greeting to be reused
          greeting = greeting_choice(2),
          device = c(3,{
            t("new laptop"),
            t("laptop"),
            t("new desktop"),
            t("desktop"),
            i(1, "device"),
          }),
          passmsg = c(4,{
            t(", you can call our office, or we can reset your password to a temporary one."),
            t(" you can also call our office."),
          }),
          outmsg = message_end(5),
        }
    )
  ),
  s({
    trig = "vigoPassReset",
    desc = "Email client for password reset"
  }, fmt([[
      Hi {name},

      {greeting}

      I will reset your password to: {password}

      Please confirm you have read and taken note of this password by replying to this email. We will only proceed with the password reset once you have replied.

      Important: Once we reset your password, you may be signed out of all sessions you are currently logged in. You can log back in using the new password mentioned above.

      {outmsg},
      Simon
      ]], {
          name = i(1, "Name"),
          --NOTE: Could separate out the greeting to be reused
          greeting = greeting_choice(2),
          password = i(3, "PASSWORD"),
          outmsg = message_end(4),
        }
    )
  ),
  s({
    trig = "vigocomplete",
    desc = "Complete builds message"
  }, fmt([[
      Hi {name},

      {greeting}

      We have completed setting up {name2} {device} and it is ready for collection, we are open Monday to Friday 9am to 5pm.
      Alternatively, I can arrange to have one of our mobile engineers drop the laptop of for you.

      {outmsg},
      Simon
      ]], {
          name = i(1, "Name"),
          --NOTE: Could separate out the greeting to be reused
          greeting = greeting_choice(2),
          name2 = i(3, "Name"),
          device = c(4, {t("laptop"), t("desktop")}),
          outmsg = message_end(5),
        }
    )
  ),
})
```

### Lua 

Snippets only for lua file types.
___
```lua
snippet("lua", {
  -- auto type require definition
s('req',
  fmt([[local {} = require("{}")]], { f(function(import_name)
    local parts = vim.split(import_name[1][1], ".", { plain = true })
    return parts[#parts] or ""
  end, { 1 }), i(1) })
),
-- import luasnip functions
s({
    trig = 'luasnip import',
    priority = 10000,
    desc = 'import luasnip functions',
  },
  {
    d(1, function()
      local import_table = {
        'local ls = require("luasnip")',
        'local s = ls.snippet',
        'local t = ls.text_node',
        'local i = ls.insert_node',
        'local f = ls.function_node',
        'local c = ls.choice_node',
        'local fmt = require("luasnip.extras.fmt").fmt',
        'local d = ls.dynamic_node',
        'local sn = ls.snippet_node',
        'local isn = ls.indent_snippet_node',
        'local r = ls.restore_node',
        'local events = require("luasnip.util.events")',
        'local ai = require("luasnip.nodes.absolute_indexer")',
        'local extras = require("luasnip.extras")',
        'local l = extras.lambda',
        'local rep = extras.rep',
        'local p = extras.partial',
        'local m = extras.match',
        'local n = extras.nonempty',
        'local dl = extras.dynamic_lambda',
        'local fmta = require("luasnip.extras.fmt").fmta',
        'local conds = require("luasnip.extras.expand_conditions")',
        'local postfix = require("luasnip.extras.postfix").postfix',
        'local types = require("luasnip.util.types")',
        'local parse = require("luasnip.util.parser").parse_snippet',
        'local ms = ls.multi_snippet',
        'local k = require("luasnip.nodes.key_indexer").new_key',
      }

      return sn(nil, c(1, {
        t({ unpack(import_table, 1, 7) }),
        t({ unpack(import_table, 1, 9) }),
        t(import_table),
      }))
    end)
    }
  ),
})
```

### GitCommit

Snippets for git commit file type, used for committing with [fugitive](#fugitive).
___
```lua
snippet("gitcommit", {
  -- conventional commit snippets
  -- see https://www.conventionalcommits.org/en/v1.0.0/#summary
  s({trig = "^br", regTrig = true}, t("BREAKING CHANGE: ")),
  s({trig = "^fe", regTrig = true}, fmt([[feat({}){}: {}]], { i(1, "scope"), c(3, {t(""),t("!")}), i(2, "new feature")})),
  s({trig = "^fi", regTrig = true}, fmt([[fix({}){}: {}]], { i(1, "scope"), c(3, {t(""),t("!")}), i(2, "bug fix")})),
  s({trig = "^do", regTrig = true}, fmt([[docs({}){}: {}]], { i(1, "scope"), c(3, {t(""),t("!")}), i(2, "documentation only change")})),
  s({trig = "^bu", regTrig = true}, fmt([[build({}){}: {}]], { i(1, "scope"), c(3, {t(""),t("!")}), i(2, "build system or external dependency change")})),
  s({trig = "^pe", regTrig = true}, fmt([[perf({}){}: {}]], { i(1, "scope"), c(3, {t(""),t("!")}), i(2, "performance improvement change")})),
  s({trig = "^re", regTrig = true}, fmt([[refactor({}){}: {}]], { i(1, "scope"), c(3, {t(""),t("!")}), i(2, "code change that neither fixes a bug or adds a feature")})),
  s({trig = "^st", regTrig = true}, fmt([[style({}){}: {}]], { i(1, "scope"), c(3, {t(""),t("!")}), i(2, "change that does not affect the meaning of the code")})),
  s({trig = "^pe", regTrig = true}, fmt([[perf({}){}: {}]], { i(1, "scope"), c(3, {t(""),t("!")}), i(2, "adding new or correcting existing test")})),
},{ type = "autosnippets" })
```

