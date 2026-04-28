---
title: Neovim Config
description: My personal neovim config
author: Simon H Moore
categories: 
  - config
  - neovim
  - lua
  - markdown
tangle:
  source: ./README.md
  target: ./lua/config.lua
created: 2024-03-06T23:01:44+0100
updated: 2026-04-27T00:00:00+0100
version: 2.0.0
---

# INSTALL INSTRUCTIONS

This file is the literate source. All `lua` fenced code blocks below are tangled (in document order) into `lua/config.lua` by `tangle.lua`.

___

1. Tangle `README.md` into `lua/config.lua`:
```sh
nvim --headless -l tangle.lua
```
On a fresh clone you can also just open Neovim — `init.lua` runs the tangler automatically when `lua/config.lua` is missing.

2. Open Neovim. Lazy will bootstrap itself and install all plugins.
```sh
nvim
```
You may need to reopen Neovim once or twice while Lazy installs and sets up plugins.

3. Inside Neovim, after editing `README.md`, regenerate the config with:
```vim
:Tangle
```


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

| Variable | Value   | Descriptions           |
|----------+---------+------------------------|
| o        | vim.opt | Inbuilt vim options    |
| g        | vim.g   | Inbuilt global options |
| cmd      | vim.cmd | Run vim ex commands    |


```lua
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

B = function(v)
  vim.cmd("new")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(vim.inspect(v), "\n"))
  return v
end
```


## Pack Helper Function

`plug({...})` accumulates plugin specs into the `plugins` table. The actual
install / load / lazy-trigger registration happens in the `# PACK` section,
which feeds these specs to `vim.pack` (Neovim 0.12's built-in package manager).
The spec shape mirrors what lazy.nvim accepted, so per-plugin call sites are
unchanged.

`lazy_keys_index` is populated by the lazy-key trigger registrar in `# PACK`
and consulted by the `map()` wrapper in `# KEYMAPS` to avoid clobbering keys
that a deferred plugin will eventually claim.
___
```lua
local plugins         = {}
local lazy_keys_index = {}

-- Try to require the plugin's main Lua module. Repo names don't always match
-- the module name (e.g. catgoose/nvim-colorizer.lua → require("colorizer")),
-- so we try a few sensible variants and use the first that works.
local function require_main(plugin)
  if plugin.main then return require(plugin.main) end
  local repo = plugin[1] or plugin.name or ""
  local last = repo:match(".*/(.*)") or repo
  local seen, candidates = {}, {}
  local function add(c)
    if c and c ~= "" and not seen[c] then
      seen[c] = true
      candidates[#candidates + 1] = c
    end
  end
  local function variants(s)
    add(s)
    add((s:gsub("%.nvim$", "")))
    add((s:gsub("%.lua$", "")))
    add((s:gsub("%.nvim$", ""):gsub("%.lua$", "")))
    add((s:gsub("^nvim%-", ""):gsub("%.nvim$", ""):gsub("%.lua$", "")))
    add((s:gsub("^vim%-", ""):gsub("%.nvim$", ""):gsub("%.lua$", "")))
  end
  add(plugin.name)
  variants(last)
  variants(last:lower())   -- also try lowercased (e.g. nvim-FeMaco.lua → femaco)
  for _, c in ipairs(candidates) do
    local ok, mod = pcall(require, c)
    if ok then return mod end
  end
  error(("could not require plugin '%s' (tried: %s)"):format(repo, table.concat(candidates, ", ")))
end

local function wrap_config(plugin)
  local user_config = plugin.config

  -- nil + opts, `true`, or `{}` → auto-setup via require(main).setup(opts).
  if user_config == nil or user_config == true
     or (type(user_config) == "table" and vim.tbl_isempty(user_config)) then
    user_config = function(p, opts) require_main(p).setup(opts) end
  end

  if type(user_config) == "function" then
    plugin.config = function(...)
      local ok, err = pcall(user_config, ...)
      if not ok then
        vim.notify(("Plugin '%s' setup failed:\n%s"):format(plugin.name or plugin[1], err), vim.log.levels.ERROR)
      end
    end
  end
end

function plug(plugin)
  -- wrap_config when there's anything to set up — config OR opts.
  if plugin.config ~= nil or plugin.opts ~= nil then
    wrap_config(plugin)
  end
  plugins[#plugins + 1] = plugin
end
```


# OPTIONS

Configure inbuilt Neovim options.
___
```lua
o.autowrite = true           -- Enable auto write
o.clipboard = "unnamedplus"  -- Sync with system clipboard
o.completeopt = "menu,menuone,noselect" -- Completion options for better experience
o.conceallevel = 3           -- Hide * markup for bold and italic
o.confirm = true             -- Confirm to save changes before exiting modified buffer
o.cursorline = true          -- Enable highlighting of the current line
o.breakindent = true         -- Every wrapped line will honor indent
o.expandtab = true           -- Use spaces instead of tabs
o.formatoptions = "jcroqlnt" -- Format options for automatic formatting
o.grepformat = "%f:%l:%c:%m" -- Format for grep output
o.grepprg = "rg --vimgrep"   -- Use ripgrep for grep command
o.ignorecase = true          -- Ignore case in search patterns
o.inccommand = "nosplit"     -- Preview incremental substitute
o.laststatus = 0             -- Never show status line
o.list = true                -- Show some invisible characters (tabs, trailing spaces)
o.mouse = "a"                -- Enable mouse mode
o.number = true              -- Print line number
o.pumblend = 10              -- Popup blend transparency
o.pumheight = 10             -- Maximum number of entries in a popup
o.relativenumber = true      -- Relative line numbers
o.scrolloff = 4              -- Lines of context around cursor
o.sessionoptions = { "buffers", "curdir", "tabpages", "winsize" } -- Session save options
o.shiftround = true          -- Round indent to multiple of shiftwidth
o.shiftwidth = 2             -- Size of an indent
o.shortmess:append({ W = true, I = true, c = true }) -- Reduce message verbosity
o.showmode = false           -- Don't show mode since we have a statusline
o.sidescrolloff = 8          -- Columns of context around cursor
o.signcolumn = "yes"         -- Always show the signcolumn, otherwise it would shift the text each time
o.smartcase = true           -- Don't ignore case with capitals
o.smartindent = true         -- Insert indents automatically
o.spelllang = { "en" }       -- Spell checking language
o.splitbelow = true          -- Put new windows below current
o.splitright = true          -- Put new windows right of current
o.tabstop = 2                -- Number of spaces tabs count for
o.termguicolors = true       -- True color support
o.timeoutlen = 300           -- Time to wait for a mapped sequence to complete
o.undofile = true            -- Save undo history to file
o.undolevels = 10000         -- Maximum number of changes that can be undone
o.updatetime = 200           -- Save swap file and trigger CursorHold
o.wildmode = "longest:full,full" -- Command-line completion mode
o.winminwidth = 5            -- Minimum window width
o.wrap = false               -- Disable line wrap

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

A retro groove color scheme with warm, earthy tones designed for comfortable long coding sessions. Gruvbox provides excellent contrast and readability while being easy on the eyes.

This colorscheme implementation offers:
- **Warm color palette**: Carefully selected browns, oranges, and muted colors that reduce eye strain
- **Treesitter integration**: Full support for modern syntax highlighting with semantic tokens
- **Transparency support**: Optional transparent background for terminal integration
- **Comprehensive language support**: Optimized colors for all major programming languages
- **Dark and light variants**: Multiple contrast levels to suit different lighting conditions
- **Accessibility focused**: High contrast ratios and colorblind-friendly palette choices
  
  **Usage**: The colorscheme is automatically applied on startup. The configuration includes transparency mode and custom overrides for better markdown and code block visibility.
  
  **Help**: The theme provides consistent highlighting across all file types while maintaining the distinctive Gruvbox aesthetic that has made it popular among developers worldwide.
  
  For example, comments appear in a muted gray-brown, strings in warm green, and keywords in bright orange, creating a cohesive and pleasant coding environment.
___
  [GitHub](https://github.com/ellisonleao/gruvbox.nvim)

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

## Colorizer

A high-performance color highlighter that displays colors directly in your code for better visual feedback. Colorizer automatically detects and highlights color codes, making it easier to work with CSS, web development, and any files containing color values.

This plugin provides:
- **Real-time color preview**: See actual colors rendered inline for hex codes, RGB values, and named colors
- **Multiple format support**: Handles #RGB, #RRGGBB, #RRGGBBAA, rgb(), hsl(), and CSS color names
- **Performance optimized**: Fast highlighting that doesn't slow down your editor
- **Customizable display**: Choose between background highlighting, foreground text, or virtual text display
- **Wide language support**: Works with CSS, HTML, JavaScript, Lua, and many other file types
- **Non-intrusive**: Only highlights valid color codes without interfering with syntax highlighting
  
  **Usage**: Colors are automatically highlighted when you open supported files. The plugin runs in the background and updates highlights as you type.
  
  **Help**: The colorizer makes it instantly clear what colors your code represents, eliminating guesswork when working with color values in web development, theming, or configuration files.
  
  For example, `#ff0000` will show with a red background, `rgb(0, 255, 0)` with green, and `blue` with the corresponding blue color.
___
  [GitHub](https://github.com/catgoose/nvim-colorizer.lua)

```lua
plug({
  "catgoose/nvim-colorizer.lua",
  enabled = true,
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    user_default_options = {
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
    filetypes = { "*" },
  },
})
```

## Rainbow

A Neovim plugin that provides rainbow parentheses highlighting using Tree-sitter for enhanced code readability. Rainbow colorizes matching brackets, parentheses, and delimiters with different colors to make nested code structures easier to navigate and understand.

This plugin offers:
- **Tree-sitter integration**: Uses modern Tree-sitter parsing for accurate bracket detection and highlighting
- **Multiple delimiter support**: Highlights parentheses, brackets, braces, and other delimiters with distinct colors
- **Extended mode**: Optional highlighting of non-bracket delimiters like HTML tags and language-specific constructs
- **Performance optimized**: Efficient highlighting that works smoothly even with large files
- **Customizable colors**: Configure your own color schemes or use the default rainbow palette
- **Language awareness**: Intelligent highlighting that respects language syntax and context
  
  **Usage**: Rainbow highlighting is automatically applied when you open supported files. The plugin cycles through colors for each nesting level, making it easy to match opening and closing delimiters.
  
  **Help**: The rainbow colors help reduce visual confusion when working with deeply nested code structures, making it easier to spot mismatched brackets and understand code hierarchy at a glance.
  
  For example, in nested function calls like `func(array[index(key)])`, each level of brackets will appear in a different color, making the structure immediately clear.
___
  [GitHub](https://github.com/HiPhish/rainbow-delimiters.nvim)

```lua
plug({
  "HiPhish/rainbow-delimiters.nvim",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    local rainbow_delimiters = require('rainbow-delimiters')
    
    vim.g.rainbow_delimiters = {
      strategy = {
        [''] = rainbow_delimiters.strategy['global'],
        vim = rainbow_delimiters.strategy['local'],
      },
      query = {
        [''] = 'rainbow-delimiters',
        lua = 'rainbow-delimiters',
      },
      priority = {
        [''] = 110,
        lua = 210,
      },
      highlight = {
        'RainbowDelimiterRed',
        'RainbowDelimiterYellow',
        'RainbowDelimiterBlue',
        'RainbowDelimiterOrange',
        'RainbowDelimiterGreen',
        'RainbowDelimiterViolet',
        'RainbowDelimiterCyan',
      },
    }
  end,
})
```

## Sentiment

A modern and enhanced replacement for Neovim's built-in matchparen functionality that provides intelligent bracket and delimiter highlighting. Sentiment offers superior performance and visual feedback for matching pairs in your code.

This plugin enhances code navigation by:
- **Smart pair detection**: Accurately highlights matching brackets, parentheses, braces, and other delimiters
- **Performance optimized**: Faster and more efficient than the default matchparen plugin
- **Visual clarity**: Clear highlighting that makes it easy to identify matching pairs at a glance
- **Customizable appearance**: Configure colors and styles to match your preferred theme
- **Language awareness**: Intelligent handling of different programming language syntaxes
- **Non-intrusive design**: Subtle highlighting that doesn't interfere with your workflow
  
  **Usage**: Matching pairs are automatically highlighted when your cursor is positioned on or near brackets, parentheses, or other delimiters. The plugin works seamlessly in the background.
  
  **Help**: The highlighting helps you quickly identify the scope of code blocks, function calls, and nested structures, reducing errors and improving code comprehension.
  
  For example, when your cursor is on an opening `[`, the corresponding closing `](`, the corresponding closing `)` will be highlighted, making it easy to see the extent of code blocks and nested structures.
___
  [GitHub](https://github.com/utilyre/sentiment.nvim)
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

# UI

Here we configure the user interface for Neovim.
___

## Lualine

A blazing fast and highly customizable statusline plugin for Neovim written in pure Lua. Lualine provides a beautiful and informative status bar that displays essential information about your editing session while maintaining excellent performance.

This statusline implementation offers:
- **Lightning-fast performance**: Written in Lua with minimal overhead, ensuring your editor stays responsive
- **Extensive customization**: Configure colors, components, separators, and layout to match your workflow
- **Rich component library**: Display mode, branch, diagnostics, file info, LSP status, and much more
- **Theme integration**: Seamlessly integrates with your colorscheme or use custom themes
- **Extension support**: Built-in support for popular plugins like fugitive, fzf, and nvim-tree
- **Winbar support**: Optional window-local statuslines for better file navigation
- **Tabline functionality**: Replace Neovim's default tabline with a customizable alternative

**Usage**: The statusline is automatically displayed and updates in real-time. The configuration includes custom themes, component positioning, and integration with LSP diagnostics and Git information.

**Help**: Run `:help lualine` for comprehensive documentation. The plugin displays current mode, Git branch, file path, diagnostics, and cursor position by default.

For example, the statusline shows your current Vim mode (Normal, Insert, Visual), Git branch with diff statistics, file encoding, and line/column position, all with color-coded indicators for quick visual reference.
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
          section_separators = { left = "", right = "" },
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
@end


## ufo

```lua
plug({
  'kevinhwang91/nvim-ufo',
  dependencies = 'kevinhwang91/promise-async',
  config = function()
      local ufo = require("ufo")
      
      vim.o.foldcolumn = "0" -- show fold column
      vim.o.foldlevel = 99   -- start unfolded
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true
      -- vim.o.foldlevelstart = 0     -- 0 means all folds start closed
      -- vim.o.foldlevel = 0          -- current fold level

      -- Set up keymaps
      vim.keymap.set("n", "zR", ufo.openAllFolds,         { desc = "Open all folds" })
      vim.keymap.set("n", "zM", ufo.closeAllFolds,        { desc = "Close all folds" })
      vim.keymap.set("n", "zr", ufo.openFoldsExceptKinds, { desc = "Open folds (selective)" })
      vim.keymap.set("n", "zm", ufo.closeFoldsWith,       { desc = "Close folds (selective)" })
      vim.keymap.set('n', 'K', function()
          local ok, ufo = pcall(require, 'ufo')
          local line = vim.fn.line('.')
          if vim.fn.foldclosed(line) ~= -1 and ok then
              -- Cursor is on a folded line
              local winid = ufo.peekFoldedLinesUnderCursor()
              if not winid then
                  print("No folded lines to peek")
              end
          else
                pcall(vim.lsp.buf.hover)
          end
      end)

      -- Function to pick the right provider for UFO
      local function provider_selector(bufnr)
        local clients = vim.lsp.get_clients({ bufnr = bufnr })
        for _, client in ipairs(clients) do
          if client.server_capabilities.foldingRangeProvider then
            return "lsp"
          end
        end
        return "treesitter"
      end

      -- local capabilities = vim.lsp.protocol.make_client_capabilities()
      -- capabilities.textDocument.foldingRange = {
      --     dynamicRegistration = false,
      --     lineFoldingOnly = true
      -- }
      -- local language_servers = vim.lsp.get_clients() -- or list servers manually like {'gopls', 'clangd'}
      -- for _, ls in ipairs(language_servers) do
      --     require('lspconfig')[ls].setup({
      --         capabilities = capabilities
      --         -- you can add other fields for setting up lsp server in this table
      --     })
      -- end

      -- Set provider selector
      ufo.setup({
        close_fold_kinds_for_ft = {
            -- Python
            python = {
                "class_definition",
                "function_definition",
                "if_statement",
                "for_statement",
                "while_statement",
                "try_statement",
                "with_statement",
                "import_statement",
                "import_from_statement",
                "decorated_definition",
                "string",
                "argument_list",
                "parenthesized_expression",
                "dictionary",
                -- "parameters",
            },

            -- Lua
            lua = {
                "function_definition",
                "if_statement",
                "for_statement",
                "while_statement",
                "repeat_statement",
                "table_constructor",
                "do_statement",
            },

            -- Bash / Shell
            bash = {
                "function_definition",
                "if_statement",
                "for_statement",
                "while_statement",
                "until_statement",
                "case_statement",
                "compound_command",
            },

            -- C / C++ / Objective-C
            c = {
                "function_definition",
                "if_statement",
                "for_statement",
                "while_statement",
                "switch_statement",
                "struct_definition",
                "enum_definition",
                "compound_statement",
            },
            cpp = {
                "function_definition",
                "if_statement",
                "for_statement",
                "while_statement",
                "switch_statement",
                "class_definition",
                "struct_definition",
                "enum_definition",
                "compound_statement",
            },

            -- JavaScript / TypeScript
            javascript = {
                "function",
                "method_definition",
                "class_declaration",
                "if_statement",
                "for_statement",
                "while_statement",
                "switch_statement",
                "try_statement",
                "block",
            },
            typescript = {
                "function",
                "method_definition",
                "class_declaration",
                "if_statement",
                "for_statement",
                "while_statement",
                "switch_statement",
                "try_statement",
                "block",
            },

            -- Rust
            rust = {
                "function_item",
                "impl_item",
                "struct_item",
                "enum_item",
                "trait_item",
                "mod_item",
                "if_expression",
                "for_expression",
                "while_expression",
                "loop_expression",
                "block",
            },

            -- Go
            go = {
                "function_declaration",
                "method_declaration",
                "type_spec",
                "if_statement",
                "for_statement",
                "switch_statement",
                "select_statement",
                "block",
            },

            -- Markdown
            markdown = {
                "atx_heading",
                "setext_heading",
                "fenced_code_block",
                "list_item",
                "blockquote",
            },
        },

        provider_selector = function(bufnr, filetype, buftype)
        return {provider_selector(), "indent"} 
        end,

        fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
          local newVirtText = {}
          local suffix = (' 󰁂 %d '):format(endLnum - lnum)
          local sufWidth = vim.fn.strdisplaywidth(suffix)
          local targetWidth = width - sufWidth
          local curWidth = 0
          for _, chunk in ipairs(virtText) do
              local chunkText = chunk[1]
              local chunkWidth = vim.fn.strdisplaywidth(chunkText)
              if targetWidth > curWidth + chunkWidth then
                  table.insert(newVirtText, chunk)
              else
                  chunkText = truncate(chunkText, targetWidth - curWidth)
                  local hlGroup = chunk[2]
                  table.insert(newVirtText, {chunkText, hlGroup})
                  chunkWidth = vim.fn.strdisplaywidth(chunkText)
                  -- str width returned from truncate() may less than 2nd argument, need padding
                  if curWidth + chunkWidth < targetWidth then
                      suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
                  end
                  break
              end
              curWidth = curWidth + chunkWidth
          end
          table.insert(newVirtText, {suffix, 'MoreMsg'})
          return newVirtText
        end,
      })
  end
})
```

# OBSIDIAN

A markdown-native notes manager. Replaces neorg's `core.dirman`, `core.journal`, `core.completion`, `core.esupports.metagen` (frontmatter) and link-following workflows. Workspaces map 1:1 to the previous neorg workspaces.
___
[GitHub](https://github.com/epwalsh/obsidian.nvim)
```lua
plug({
  "epwalsh/obsidian.nvim",
  version = "*",
  lazy = true,
  ft = "markdown",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "hrsh7th/nvim-cmp",
  },
  opts = {
    workspaces = {
      { name = "documents", path = "~/Documents" },
      { name = "notes",     path = "~/Documents/Notes" },
      { name = "career",    path = "~/Documents/Career" },
      { name = "profiles",  path = "~/Documents/Profiles" },
    },
    daily_notes = {
      folder = "journal",
      date_format = "%Y-%m-%d",
    },
    completion = {
      nvim_cmp = true,
      min_chars = 2,
    },
    note_frontmatter_func = function(note)
      local out = { id = note.id, aliases = note.aliases, tags = note.tags }
      out.author = "Simon H Moore <simon@simonhugh.xyz>"
      if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
        for k, v in pairs(note.metadata) do out[k] = v end
      end
      return out
    end,
    ui = { enable = false }, -- defer rendering to render-markdown.nvim
  },
})
```

# RENDER-MARKDOWN

Replaces neorg's `core.concealer` and the old `headlines.nvim` block. Conceals heading prefixes with bullets, styles code blocks, tables, checkboxes, and quotes — all natively for markdown.
___
[GitHub](https://github.com/MeanderingProgrammer/render-markdown.nvim)
```lua
plug({
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  ft = { "markdown" },
  opts = {
    heading = {
      icons = { "◉ ", "○ ", "✸ ", "✿ ", "❯ ", "❯ " },
      backgrounds = { "Headline1", "Headline2", "Headline2", "Headline2", "Headline2", "Headline2" },
    },
    code = {
      style = "normal",
      width = "block",
      min_width = 85,
    },
    bullet = {
      icons = { "•", "◦", "▪", "▫" },
    },
  },
  config = function(_, opts)
    vim.cmd [[highlight Headline1 guibg=#1e2718]]
    vim.cmd [[highlight Headline2 guibg=#21262d]]
    -- Subtle dark inset for code blocks: slightly darker than bg, distinct
    -- without glare. Inline `code` gets the Headline2 tone for visual unity.
    vim.cmd [[highlight RenderMarkdownCode       guibg=#1c2026]]
    vim.cmd [[highlight RenderMarkdownCodeInline guibg=#21262d]]
    require("render-markdown").setup(opts)
  end,
})
```

# OTTER

Embedded LSP for fenced code blocks inside markdown — gives `lua`, `python`, `bash` blocks real LSP/completion/diagnostics. Previously bundled as a neorg dependency; now standalone.
___
[GitHub](https://github.com/jmbuhr/otter.nvim)
```lua
plug({
  "jmbuhr/otter.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "hrsh7th/nvim-cmp",
  },
  ft = { "markdown" },
  config = true,
})
```

# EDIT CODE BLOCK

Open the fenced code block under the cursor in a dedicated floating buffer
with the inner block's filetype set, edit it with full LSP / completion as
that filetype, and on `:w` splice the changes back into the host buffer.

Replaces `nvim-FeMaco.lua` (unmaintained since 2024-04, broken by nvim 0.12's
treesitter API) with a small native function. No dependency to break — uses
`vim.treesitter` and floating windows directly.
___
```lua
local function edit_code_block()
  local bufnr = vim.api.nvim_get_current_buf()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local node = vim.treesitter.get_node({ bufnr = bufnr, pos = { row - 1, col } })
  while node and node:type() ~= "fenced_code_block" do node = node:parent() end
  if not node then
    vim.notify("Not in a code block", vim.log.levels.WARN)
    return
  end

  local lang, content
  for child in node:iter_children() do
    if child:type() == "info_string" then
      lang = vim.treesitter.get_node_text(child, bufnr):match("%S+")
    elseif child:type() == "code_fence_content" then
      content = child
    end
  end
  if not content then
    vim.notify("Empty code block", vim.log.levels.WARN)
    return
  end

  local sr, _, er = content:range()
  local lines = vim.api.nvim_buf_get_lines(bufnr, sr, er, false)

  local scratch = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(scratch, 0, -1, false, lines)
  if lang and lang ~= "" then vim.bo[scratch].filetype = lang end
  vim.bo[scratch].buftype = "acwrite"      -- so :w fires BufWriteCmd
  vim.api.nvim_buf_set_name(scratch, ("femaco://%s/%s"):format(lang or "code", sr))

  local w = math.floor(vim.o.columns * 0.8)
  local h = math.min(#lines + 4, math.floor(vim.o.lines * 0.8))
  vim.api.nvim_open_win(scratch, true, {
    relative = "editor", width = w, height = h,
    row = math.floor((vim.o.lines - h) / 2),
    col = math.floor((vim.o.columns - w) / 2),
    style = "minimal", border = "rounded",
    title = " " .. (lang or "code") .. " — :w to apply, :q to discard ",
    title_pos = "center",
  })

  vim.api.nvim_create_autocmd("BufWriteCmd", {
    buffer = scratch,
    callback = function()
      local new_lines = vim.api.nvim_buf_get_lines(scratch, 0, -1, false)
      vim.api.nvim_buf_set_lines(bufnr, sr, er, false, new_lines)
      er = sr + #new_lines                 -- track shrink/grow for repeat saves
      vim.bo[scratch].modified = false
    end,
  })
end

vim.keymap.set("n", "<localleader>cg", edit_code_block, { desc = "Edit code block" })
```

# SNACKS

A collection of small QoL plugins for Neovim.
___

```lua
plug({
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    -- Keep only the useful non-picker modules
    bigfile = { enabled = true },
    indent = {
      indent = {
        enabled = true,
        priority = 1,
        char = "▎",
      },
      animate = { enabled = false },
      scope = {
        enabled = true, -- enable highlighting the current scope
        priority = 200,
        char = "▎",
      },
    },
    -- Enable snacks notify
    notifier = { 
      enabled = true,
      timeout = 1000,
      width = { min = 20, max = 50 },
      height = { max = 50 },
      style = "compact",
      top_down = true,
    },
    -- Enable snacks input to replace dressing.nvim
    input = { enabled = true },
    -- Enable snacks words for navigation (]]  [[)
    words = { 
      enabled = true,
      debounce = 200,
    },
    -- Enable quickfile for better performance
    quickfile = { enabled = true },
    -- Enable picker instead of telescope
    picker = { enabled = true },
    -- Keep disabled
    dashboard = { enabled = false },
    explorer = { enabled = false },
    scope = { enabled = false },
    scroll = { enabled = false },
    statuscolumn = { enabled = false },
    scratch = {
      enabled = true,
      ft = "markdown",
      root = "~/Documents/Notes/scratch",
      filekey = {
          id = nil, ---@type string? unique id used instead of name for the filename hash
          cwd = true, -- use current working directory
          branch = true, -- use current branch name
          count = false, -- use vim.v.count1
        },
    }
  },
  config = function(_, opts)
    require("snacks").setup(opts)
    vim.notify = Snacks.notifier.notify

    -- Add snacks picker keymaps
    local pick = Snacks.picker
  
    -- Scratch buffer
    vim.keymap.set('n', '<leader>.', Snacks.scratch.open, { desc = 'Scratch pad' })
    vim.keymap.set('n', '<leader>fs', Snacks.scratch.select, { desc = 'Find scratch pad' })

    -- terminal
    vim.keymap.set({'n', 'i', 't'}, '<c-b>', Snacks.terminal.toggle, { desc = 'Toggle terminal' })

    -- Shortcuts
    vim.keymap.set('n', '<leader>,', pick.buffers, { desc = 'Buffers' })
    vim.keymap.set('n', '<leader>/', pick.grep_word, { desc = 'Grep word' })

    -- Find Files
    vim.keymap.set('n', '<leader>ff', pick.smart,  { desc = 'Files' })
    vim.keymap.set('n', '<leader>fr', pick.recent, { desc = 'Recent files' })

    vim.keymap.set('n', '<leader>fd', function() pick.files({ cwd = '~/Documents' }) end, { desc = 'Documents' })
    vim.keymap.set('n', '<leader>fD', function() pick.files({ cwd = '~/Downloads' }) end, { desc = 'Downloads' })
    vim.keymap.set('n', '<leader>fp', function() pick.files({ cwd = '~/Projects' }) end,  { desc = 'Projects' })
    vim.keymap.set('n', '<leader>fc', function() pick.files({ cwd = vim.fn.stdpath('config') }) end, { desc = 'Config' })
    vim.keymap.set('n', '<leader>fB', function() pick.files({ cwd = '~/.local/bin' }) end, { desc = 'Local bin' })

    -- Search for content, help and functions
    vim.keymap.set('n', '<leader>st', function() pick.commands() end, { desc = 'Commands' })
    vim.keymap.set('n', '<leader>sP', pick.pick,        { desc = 'Pickers' })
    vim.keymap.set('n', '<leader>sh', pick.help,        { desc = 'Help' })
    vim.keymap.set('n', '<leader>sw', pick.grep_word,   { desc = 'Current word' })
    vim.keymap.set('n', '<leader>sg', pick.grep,        { desc = 'Grep' })
    vim.keymap.set('n', '<leader>sd', pick.diagnostics, { desc = 'Diagnostics' })
    vim.keymap.set('n', '<leader>sk', pick.keymaps,     { desc = 'Keymaps' })
    vim.keymap.set('n', "<leader>s'", pick.marks,       { desc = 'Marks' })
    vim.keymap.set('n', '<leader>s"', pick.registers,   { desc = 'Registers' })
    vim.keymap.set('n', '<leader>su', pick.undo,        { desc = 'Undo history' })
    vim.keymap.set('n', '<leader>sc', pick.cliphist,    { desc = 'Clipboard history' })

    -- git
    vim.keymap.set('n', '<leader>gfg', pick.git_files,  { desc = 'Files' })
    vim.keymap.set('n', '<leader>gfs', pick.git_status, { desc = 'Status' })
    vim.keymap.set('n', '<leader>gsll', pick.git_log,       { desc = 'Log' })
    vim.keymap.set('n', '<leader>gslf', pick.git_log_file,  { desc = 'Log (file)' })
    vim.keymap.set('n', '<leader>gslL', pick.git_log_line,  { desc = 'Log (line)' })
    vim.keymap.set('n', '<leader>gsg', pick.git_grep,     { desc = 'Grep' })
    vim.keymap.set('n', '<leader>gss', pick.git_stash,    { desc = 'Stash' })
    vim.keymap.set('n', '<leader>gsb', pick.git_branches, { desc = 'Branches' })

    -- github
    vim.keymap.set('n', '<leader>Gp', pick.gh_pr,  { desc = 'Pull requests' })
    vim.keymap.set('n', '<leader>GP', function() pick.gh_pr({ state= "all" }) end,    { desc = 'All PRs' })
    vim.keymap.set('n', '<leader>Gi', pick.gh_issue, { desc = 'Issues' })
    vim.keymap.set('n', '<leader>GI', function() pick.gh_issue({ state= "all" }) end, { desc = 'All issues' })
    vim.keymap.set('n', '<leader>Gb', Snacks.gitbrowse.open, { desc = 'Browse repo' })

  end,
  keys = {
    {
      "<leader>;n",
      function() Snacks.notifier.show_history() end,
      desc = "Notification history"
    },
    {
      "]]",
      function() Snacks.words.jump(vim.v.count1) end,
      desc = "Next reference"
    },
    {
      "[[", 
      function() Snacks.words.jump(-vim.v.count1) end,
      desc = "Prev reference"
    },
  }
})
```


# VIM-ILLUMINATE

Automatically highlighting other uses of the word under the cursor using either LSP, Tree-sitter, or regex matching.
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
  end,
})
```


# FILE NAVIGATION

## Oil

A revolutionary file explorer that treats your filesystem like a regular Neovim buffer, allowing you to edit directories with the same commands you use for text editing. Oil transforms file management into a native Neovim experience with unparalleled efficiency.

This file explorer provides:
- **Buffer-based editing**: Navigate and modify your filesystem using familiar Vim motions and commands
- **Direct manipulation**: Rename files by editing text, delete with `dd`, copy with `yy`, and paste with `p`
- **Floating window support**: Quick access via floating windows that don't disrupt your workflow
- **Cross-platform compatibility**: Works seamlessly on Windows, macOS, and Linux systems
- **Undo/redo support**: Full undo history for filesystem operations with standard Vim commands
- **Integration friendly**: Works with your existing Neovim plugins and colorschemes
- **Performance optimized**: Fast directory loading and responsive navigation even in large directories

**Usage**: Open with `<leader>o` for a floating window or `<leader>O` for current working directory. Edit filenames directly in the buffer, use `dd` to delete files, and save with `:w` to apply changes.

**Help**: Run `:help oil` for complete documentation. The plugin treats directories as editable buffers where standard Vim operations translate to filesystem actions.

For example, to rename multiple files, simply edit their names in the buffer using standard text editing commands, then save to apply all changes atomically.
___
[GitHub](https://github.com/stevearc/oil.nvim)
```lua
plug({
   "stevearc/oil.nvim",
   dependencies = { "nvim-tree/nvim-web-devicons" },
   lazy = true,
   config = function ()
     require("oil").setup({
       default_file_explorer = true,
     })

   end,
   cmd = "Oil",
   keys = {
     { "<leader>o", function() require("oil").toggle_float() end,              desc = "Oil (float)" },
     { "<leader>O", function() require("oil").toggle_float(vim.fn.getcwd()) end, desc = "Oil (cwd)" },
   }
})
```

## Neo-Tree

A comprehensive and modern file explorer for Neovim that provides an intuitive tree-based interface for navigating your filesystem, buffers, and Git status. Neo-Tree offers a feature-rich sidebar experience with extensive customization options.

This file manager delivers:
- **Multiple source types**: Browse filesystem, open buffers, Git status, and LSP document symbols in unified interface
- **Rich visual indicators**: File type icons, Git status markers, and diagnostic indicators for comprehensive project overview
- **Advanced navigation**: Fuzzy finding, bookmarks, and quick access to recently used files
- **Git integration**: Visual Git status with staging/unstaging capabilities directly from the tree
- **Customizable interface**: Configurable mappings, filters, and display options to match your workflow
- **Performance optimized**: Lazy loading and efficient rendering for large directory structures
- **Plugin ecosystem**: Extensive integration with popular Neovim plugins and LSP servers

**Usage**: Toggle with `<leader>e` for filesystem view or `<leader>be` for buffer explorer. Navigate with standard Vim motions, open files with `<Enter>`, and use various actions via intuitive key mappings.

**Help**: Run `:help neo-tree` for detailed documentation. The plugin provides context-sensitive help and customizable key mappings for all operations.

For example, press `a` to create new files/directories, `d` to delete, `r` to rename, and `c` to copy, all while seeing real-time Git status and file type information.
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
        require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd() })
      end,
      desc = "Explorer",
    },
    {
      "<leader>be",
      function()
        require("neo-tree.command").execute({ toggle = true, source = "buffers"  })
      end,
      desc = "Buffer explorer",
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

## Project.nvim

An intelligent project management plugin that automatically detects and manages your project workspaces, providing seamless project switching and workspace organization. Project.nvim eliminates the hassle of manual directory management and enhances your development workflow.

This project manager offers:
- **Automatic project detection**: Intelligently identifies projects using Git repositories, LSP roots, and custom patterns
- **Smart directory switching**: Automatically changes working directory when switching between projects
- **Recent project history**: Maintains a history of recently accessed projects for quick switching
- **Multiple detection methods**: Supports Git, LSP, and custom file patterns for flexible project identification
- **Integration ready**: Works seamlessly with telescope, dashboard, and other popular plugins
- **Session persistence**: Optional integration with session management for complete workspace restoration
- **Customizable patterns**: Define your own project root indicators for specialized workflows

**Usage**: Projects are automatically detected when you open files. Use `<leader>sp` to search and switch between recent projects. The plugin maintains context and working directory automatically.

**Help**: Run `:help project_nvim` for configuration options. The plugin works silently in the background, tracking your project usage patterns.

For example, when you open a file in a Git repository, Project.nvim automatically sets that repository as your current project and remembers it for future quick access via the project picker.
___
[GitHub](https://github.com/ahmedkhalf/project.nvim)
```lua
plug({
  "ahmedkhalf/project.nvim",
  event = "VeryLazy",
  config = function()
    require("project_nvim").setup({
      detection_methods = { "pattern" },
      patterns = { ".project", ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json" },
      silent_chdir = false,
    })
  end,
  keys = {
    {
      "<leader>sp",
      function() 
        local projects = require("project_nvim").get_recent_projects()
        Snacks.picker.pick({
          items = projects,
          format = function(item) return vim.fn.fnamemodify(item, ":t") .. " (" .. item .. ")" end,
          preview = false,
        }, function(item)
          vim.cmd("cd " .. item)
        end)
      end,
      desc = 'Projects',
    },
  },
})
```

# BUFFER NAVIGATION

## EYELINER

An innovative motion enhancement plugin that provides unique visual indicators for f/F/t/T movements, making character-based navigation significantly faster and more accurate. Eyeliner eliminates guesswork in horizontal navigation by highlighting optimal jump targets.

This navigation enhancer provides:
- **Unique character highlighting**: Each reachable character gets a distinct visual indicator during f/F/t/T motions
- **Smart target selection**: Prioritizes the most efficient jump targets based on distance and frequency
- **Customizable appearance**: Configure highlight colors and styles to match your visual preferences
- **Performance optimized**: Minimal overhead with highlights that appear only when needed
- **Dimming support**: Optional dimming of non-target characters for better focus
- **Multi-line awareness**: Intelligent handling of line boundaries and wrapped text
- **Integration friendly**: Works seamlessly with existing motion plugins and colorschemes

**Usage**: Simply use f, F, t, or T motions as normal. Eyeliner automatically highlights available targets with unique indicators, making it easy to identify the exact character to jump to.

**Help**: The plugin works transparently with Vim's built-in motions. Customize highlight colors and behavior through the setup configuration.

For example, when you press `f` to find a character, Eyeliner highlights each occurrence of that character on the current line with different colors, allowing you to instantly see which one to target.
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

## Nvim Spider

Enhanced word motions that move by subwords and skip insignificant punctuation, making navigation through code more precise and efficient.

This plugin improves Vim's standard `w`, `e`, `b`, and `ge` motions by:
- **Subword navigation**: Stops at each meaningful part of camelCase, PascalCase, snake_case, and kebab-case identifiers
- **Smart punctuation handling**: Skips over insignificant punctuation marks that don't add semantic meaning
- **Programming-optimized**: Perfect for navigating through variable names, function names, and code identifiers
- **Customizable patterns**: Allows configuration of what constitutes word boundaries
  
  **Usage**: The plugin automatically replaces the default `w`, `e`, `b`, and `ge` motions. Use them as normal - they will now be smarter about stopping at meaningful word boundaries.
  
  **Help**: Run `:help spider` in Neovim for detailed documentation and configuration options.
  
  For example, with `myVariableName.someMethod()`, the `w` motion will stop at each meaningful part: `my`, `Variable`, `Name`, `some`, `Method` rather than jumping over entire compound words.
___
  [GitHub](https://github.com/chrisgrieser/nvim-spider)
```lua
plug({
  "chrisgrieser/nvim-spider",
  event = "VeryLazy",
  config = function()
    vim.keymap.set({ "n", "o", "x" }, "w",  "<cmd>lua require('spider').motion('w')<cr>",  { desc = "Word forward" })
    vim.keymap.set({ "n", "o", "x" }, "e",  "<cmd>lua require('spider').motion('e')<cr>",  { desc = "Word end" })
    vim.keymap.set({ "n", "o", "x" }, "b",  "<cmd>lua require('spider').motion('b')<cr>",  { desc = "Word back" })
    vim.keymap.set({ "n", "o", "x" }, "ge", "<cmd>lua require('spider').motion('ge')<cr>", { desc = "Word end back" })
  end,
})
```

# GIT

## Fugitive

A Git wrapper so awesome, it should be illegal. Fugitive is the premier Vim plugin for Git, providing a comprehensive interface for Git operations directly within Neovim.
  
  This plugin transforms Neovim into a powerful Git client by:
- **Complete Git workflow integration**: Stage, commit, push, pull, and merge without leaving your editor
- **Interactive Git status**: Browse and manipulate your repository state with intuitive commands
- **Advanced diff viewing**: Compare branches, commits, and working directory changes with sophisticated diff tools
- **Blame integration**: See line-by-line authorship and commit history inline with your code
- **Branch management**: Create, switch, and merge branches seamlessly
- **Conflict resolution**: Resolve merge conflicts with visual three-way diffs
  
  **Usage**: Access Git operations through `:Git` commands or use the configured keybindings. The plugin provides both command-line Git access and specialized buffers for interactive Git operations.
  
  **Help**: Run `:help fugitive` in Neovim for comprehensive documentation and command reference.
  
  For example, `:Git` opens an interactive status window where you can stage files with `s`, unstage with `u`, and commit with `cc`, all while seeing a live diff of your changes.
___
  [GitHub](https://github.com/tpope/vim-fugitive)
```lua
plug({
  'tpope/vim-fugitive',
  enabled = true,
  lazy = true,
  keys = {
    { "<leader>gg", "<cmd>Git<cr>",       desc = "Open fugitive" },
    { "<leader>gp", "<cmd>Git push<cr>",  desc = "Push" },
    { "<leader>gP", "<cmd>Git pull<cr>",  desc = "Pull" },
    { "<leader>gl", "<cmd>Git log<cr>",   desc = "Log" },
    { "<leader>gd", "<cmd>Git diff<cr>",  desc = "Diff" },
  }
})
```

## Gitsigns

Super fast git decorations implemented purely in Lua. Gitsigns provides comprehensive Git integration for Neovim buffers, displaying visual indicators and enabling seamless Git workflow management.
  
  This plugin enhances your Git workflow by:
- **Visual Git indicators**: Display added, modified, and deleted lines with customizable signs in the gutter
- **Hunk navigation**: Jump between Git hunks with intuitive keybindings for efficient code review
- **Interactive staging**: Stage and unstage individual hunks or entire buffers without leaving your editor
- **Inline blame information**: View Git blame data directly in your buffer to understand code history
- **Real-time diff preview**: Preview changes with floating windows before committing
- **Branch and status integration**: See current branch and repository status at a glance
- **Conflict resolution support**: Visual aids for resolving merge conflicts
  
  **Usage**: Git signs appear automatically in the gutter when editing tracked files. Use the configured keybindings to navigate hunks (`]h`/`[h`), stage changes (`<leader>hs`), and preview modifications (`<leader>hp`).
  
  **Help**: Run `:help gitsigns` in Neovim for comprehensive documentation and configuration options.
  
  For example, when you modify a tracked file, you'll see `~` signs for changed lines, `+` for additions, and `-` for deletions, allowing you to quickly identify and manage your changes.
___
  [GitHub](https://github.com/lewis6991/gitsigns.nvim)
```lua
plug({
  'lewis6991/gitsigns.nvim',
  opts = {
    -- See `:help gitsigns.txt`
    on_attach = function(bufnr)
      local gs = package.loaded.gitsigns
      vim.keymap.set('n', '[h', gs.prev_hunk, { buffer = bufnr, desc = 'Prev hunk' })
      vim.keymap.set('n', ']h', gs.next_hunk, { buffer = bufnr, desc = 'Next hunk' })
      vim.keymap.set('n', '<leader>hs', gs.stage_hunk,   { buffer = bufnr, desc = 'Stage hunk' })
      vim.keymap.set('n', '<leader>hS', gs.stage_buffer, { buffer = bufnr, desc = 'Stage buffer' })
      vim.keymap.set('n', '<leader>hr', gs.reset_hunk,   { buffer = bufnr, desc = 'Reset hunk' })
      vim.keymap.set('n', '<leader>hR', gs.reset_buffer, { buffer = bufnr, desc = 'Reset buffer' })
      vim.keymap.set('v', '<leader>hs', function() gs.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end,
        { buffer = bufnr, desc = 'Stage selection' })

      vim.keymap.set('v', '<leader>gr', function() gs.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end,
        { buffer = bufnr, desc = 'Reset selection' })

      vim.keymap.set('n', '<leader>hu', gs.undo_stage_hunk,          { buffer = bufnr, desc = 'Undo stage' })
      vim.keymap.set('n', '<leader>ht', gs.toggle_deleted,           { buffer = bufnr, desc = 'Toggle deleted' })
      vim.keymap.set('n', '<leader>hd', gs.diffthis,                 { buffer = bufnr, desc = 'Diff hunk' })
      vim.keymap.set('n', '<leader>hD', function() gs.diffthis('~') end, { buffer = bufnr, desc = 'Diff hunk (prev)' })
      vim.keymap.set('n', '<leader>hp', gs.preview_hunk,             { buffer = bufnr, desc = 'Preview hunk' })
      vim.keymap.set('n', '<leader>hb', gs.blame_line,               { buffer = bufnr, desc = 'Blame line' })
      vim.keymap.set('n', '<leader>hB', gs.toggle_current_line_blame,{ buffer = bufnr, desc = 'Toggle blame' })

      -- Text object
      vim.keymap.set({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'Inner hunk' })
      vim.keymap.set({ 'o', 'x' }, 'ah', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'Around hunk' })
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
  lazy = true,
  cmd = {
     "DiffviewOpen",
     "DiffviewClose",
     "DiffviewLog",
     "DiffviewRefresh",
     "DiffviewFocusFiles",
     "DiffviewFileHistory",
     "DiffviewToggleFiles",
    },
  keys = {
    {
      "<leader>dd",
      "<cmd>DiffviewOpen<cr>",
      desc = "Diff view",
    }
  },
})
```


## Octo

A comprehensive GitHub integration plugin that brings the full power of GitHub directly into your Neovim workflow. Octo transforms your editor into a complete GitHub client, enabling seamless issue management, pull request reviews, and repository interactions without leaving your development environment.

This GitHub integration provides:
- **Issue management**: Create, edit, comment on, and close GitHub issues with full markdown support
- **Pull request workflow**: Review PRs, add comments, approve changes, and manage the entire review process
- **Repository browsing**: Navigate repositories, view file histories, and explore codebases directly from Neovim
- **Collaborative features**: Real-time collaboration with team members through comments and discussions
- **Search capabilities**: Find issues, PRs, and code across repositories with powerful search functionality
- **Notification handling**: Stay updated with GitHub notifications and activity feeds
- **Multi-repository support**: Work with multiple repositories and organizations seamlessly

**Usage**: Access GitHub features through Octo commands like `:Octo issue list`, `:Octo pr checkout`, and `:Octo review start`. The plugin integrates with your picker (Snacks) for enhanced navigation and selection.

**Help**: Run `:help octo` for comprehensive documentation. The plugin requires GitHub CLI authentication and provides extensive customization options for workflows.

For example, use `:Octo pr list` to browse pull requests, `:Octo issue create` to file new issues, and `:Octo review start` to begin code reviews, all with full syntax highlighting and markdown support.
___
[GitHub](https://github.com/pwntester/octo.nvim)
```lua
plug({
  'pwntester/octo.nvim',
  cmd = "Octo",
  dependencies = {
    'nvim-lua/plenary.nvim',
    'folke/snacks.nvim',
    'nvim-tree/nvim-web-devicons',
  },
  config = function ()
    require"octo".setup({
      picker = "snacks"
    })
  end
})
```


# LSP

## Mason

Package manager for LSP servers, DAP adapters, linters and formatters.
___
[GitHub](https://github.com/williamboman/mason.nvim)
```lua
plug({ "williamboman/mason.nvim", config = true })

plug({
  "williamboman/mason-lspconfig.nvim",
  dependencies = { "williamboman/mason.nvim" },
  opts = {
    ensure_installed = { "lua_ls", "bashls", "pyright", "html", "clangd", "marksman" },
  },
})
```

## LSP

Language server configuration using the native `vim.lsp` API (nvim 0.11+). `nvim-lspconfig` provides server defaults (cmd, root_dir, filetypes); `vim.lsp.config` / `vim.lsp.enable` wire everything together without the old `setup()` pattern.
___
[GitHub](https://github.com/neovim/nvim-lspconfig)
```lua
plug({
  "neovim/nvim-lspconfig",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "SmiteshP/nvim-navic",
    "kosayoda/nvim-lightbulb",
    "folke/which-key.nvim",
  },
  config = function()
    -- Global capabilities merged into every server
    vim.lsp.config("*", {
      capabilities = vim.tbl_deep_extend("force",
        require("cmp_nvim_lsp").default_capabilities(),
        { textDocument = { foldingRange = { dynamicRegistration = false, lineFoldingOnly = true } } }
      ),
    })

    -- Per-server overrides (only what differs from lspconfig defaults)
    vim.lsp.config("lua_ls", {
      settings = {
        Lua = {
          runtime    = { version = "LuaJIT" },
          workspace  = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
          diagnostics = { globals = { "vim" } },
          telemetry  = { enable = false },
        },
      },
    })

    -- Enable servers (lspconfig supplies cmd/root_dir/ft for each)
    vim.lsp.enable({ "lua_ls", "bashls", "pyright", "html", "clangd", "marksman" })

    -- Per-buffer keymaps and navic breadcrumbs
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local bufnr = args.buf
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        local function map(lhs, rhs, desc, mode)
          vim.keymap.set(mode or "n", lhs, rhs, { buffer = bufnr, desc = desc })
        end

        -- Navigation
        map("gd", vim.lsp.buf.definition,  " Definition")
        map("gD", vim.lsp.buf.declaration, " Declaration")
        map("[d",  function() vim.diagnostic.jump({ count = -1 }) end, "← Prev diagnostic")
        map("]d",  function() vim.diagnostic.jump({ count = 1 })  end, "→ Next diagnostic")

        -- Actions
        map("<localleader>lf", function() vim.lsp.buf.format({ async = false, timeout_ms = 10000 }) end, "Format buffer", { "n", "x" })
        map("<localleader>la", vim.lsp.buf.code_action,      "Code action")
        map("<localleader>lh", vim.lsp.buf.hover,            "Hover")
        map("<localleader>lH", vim.lsp.buf.signature_help,   "Signature help")
        map("<localleader>ls", vim.lsp.buf.workspace_symbol, "Workspace symbols")
        map("<localleader>lr", vim.lsp.buf.references,       "References")
        map("<localleader>li", vim.lsp.buf.implementation,   " Implementation")
        map("<localleader>lR", vim.lsp.buf.rename,           "Rename")
        map("<localleader>lI", "<cmd>LspInfo<CR>",           "LSP info")

        -- Picker search (Snacks)
        local pick = require("snacks").picker
        map("<localleader>ss", pick.lsp_symbols,           "Symbols")
        map("<localleader>sS", pick.lsp_workspace_symbols, "Workspace symbols")
        map("<localleader>sr", pick.lsp_references,        "References")

        -- Which-key group labels
        require("which-key").add({
          { "<localleader>l", group = "LSP" },
          { "<localleader>s", group = "Search" },
        }, { buffer = bufnr })

        -- Breadcrumbs
        if client.server_capabilities.documentSymbolProvider then
          require("nvim-navic").attach(client, bufnr)
        end
      end,
    })

    -- Code-action lightbulb indicator
    require("nvim-lightbulb").setup({
      autocmd = { enabled = true },
      virtual_text = { enabled = true, text = "" },
    })
  end,
})
```

## Completion

nvim-cmp with LuaSnip snippets.
___
[GitHub](https://github.com/hrsh7th/nvim-cmp)
```lua
plug({
  "hrsh7th/nvim-cmp",
  event = { "InsertEnter", "CmdlineEnter" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-nvim-lua",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-cmdline",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-emoji",
    "hrsh7th/cmp-calc",
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
    "onsails/lspkind.nvim",
  },
  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")

    require("luasnip.loaders.from_vscode").lazy_load()

    cmp.setup({
      snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
      mapping = cmp.mapping.preset.insert({
        ["<CR>"]  = cmp.mapping.confirm({ select = false }),
        ["<C-u>"] = cmp.mapping.scroll_docs(-4),
        ["<C-d>"] = cmp.mapping.scroll_docs(4),
        ["<C-l>"] = cmp.mapping(function(fallback)
          if luasnip.expand_or_jumpable() then luasnip.expand_or_jump() else fallback() end
        end, { "i", "s" }),
        ["<C-h>"] = cmp.mapping(function(fallback)
          if luasnip.jumpable(-1) then luasnip.jump(-1) else fallback() end
        end, { "i", "s" }),
      }),
      sources = {
        { name = "nvim_lsp" },
        { name = "nvim_lua" },
        { name = "luasnip" },
        { name = "buffer" },
        { name = "path" },
        { name = "calc" },
        { name = "emoji" },
      },
      formatting = {
        fields = { "abbr", "kind", "menu" },
        format = require("lspkind").cmp_format({ mode = "symbol_text", maxwidth = 50, ellipsis_char = "..." }),
      },
    })

    cmp.setup.cmdline("/", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = { { name = "buffer" } },
    })
    cmp.setup.cmdline(":", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
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

  -- required by nvim-dap-ui
  'nvim-neotest/nvim-nio',

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
  vim.keymap.set('n', '<F5>', dap.continue,  { desc = 'Start / continue' })
  vim.keymap.set('n', '<F1>', dap.step_into, { desc = 'Step into' })
  vim.keymap.set('n', '<F2>', dap.step_over, { desc = 'Step over' })
  vim.keymap.set('n', '<F3>', dap.step_out,  { desc = 'Step out' })
  vim.keymap.set('n', '<F4>', dap.step_back, { desc = 'Step back' })
  vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint, { desc = 'Toggle breakpoint' })
  vim.keymap.set('n', '<leader>dB', dap.set_breakpoint,    { desc = 'Set breakpoint' })
  vim.keymap.set('n', '<leader>dl', dap.run_last,          { desc = 'Run last' })
  vim.keymap.set('n', '<leader>dc', function()
    dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
  end, { desc = 'Conditional breakpoint' })

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
  vim.keymap.set('n', '<F7>', dapui.toggle, { desc = 'Session result' })

  dap.listeners.after.event_initialized['dapui_config'] = dapui.open
  dap.listeners.before.event_terminated['dapui_config'] = dapui.close
  dap.listeners.before.event_exited['dapui_config'] = dapui.close

  -- Setup golang dap
  require('dap-go').setup()

  -- Setup python dap
  if mason_registry.is_installed("debugpy") then
    local debugpy_package = mason_registry.get_package("debugpy")
    local debug_py_path = debugpy_package:get_install_path() .. "/venv/bin/python"
    require('dap-python').setup(debug_py_path)
  end
end,
})
```


# REPL

## iron.nvim

A powerful and flexible REPL (Read-Eval-Print Loop) management plugin that provides seamless integration between Neovim and interactive programming environments. Iron.nvim transforms your editor into a comprehensive development environment by enabling direct code execution and interaction with language interpreters.

This REPL manager delivers:
- **Multi-language support**: Works with Python, R, Lua, JavaScript, and many other interpreted languages
- **Flexible execution modes**: Send individual lines, code blocks, visual selections, or entire files to the REPL
- **Smart code block detection**: Automatically identifies and sends code blocks marked with language-specific delimiters
- **Multiple REPL instances**: Manage different REPL sessions for various projects or languages simultaneously
- **Customizable layouts**: Configure REPL windows as splits, floating windows, or separate tabs
- **DAP integration**: Seamlessly works with nvim-dap for debugging workflows when a debug session is active
- **Persistent sessions**: Maintain REPL state across Neovim sessions for continuous development

**Usage**: Use the configured keybindings to toggle REPLs (`<leader>rr`), send code selections (`<leader>rsc`), execute entire files (`<leader>rsf`), and manage REPL sessions. The plugin supports both manual code sending and automatic execution of code blocks.

**Help**: Run `:help iron` for comprehensive documentation. The plugin is particularly useful for data science workflows, interactive development, and exploratory programming where immediate feedback is essential.

For example, in Python development, you can send function definitions to an IPython REPL, test them interactively, and iterate on your code without leaving your editor, making it perfect for data analysis and machine learning workflows.
___
[GitHub](https://github.com/Vigemus/iron.nvim)

```lua
 plug({
   'Vigemus/iron.nvim',
   
   config = function()
      local iron = require("iron.core")
      local view = require("iron.view")
      local common = require("iron.fts.common")

      iron.setup({
        config = {
          -- Whether a repl should be discarded or not
          scratch_repl = false,
          -- Your repl definitions come here
          repl_definition = {
            sh = {
              -- Can be a table or a function that
              -- returns a table (see below)
              command = {"zsh"}
            },
            python = {
              command = { "ipython", "--no-autoindent" },
              format = common.bracketed_paste_python,
              block_dividers = { "# %%", "#%%" },
              env = {PYTHON_BASIC_REPL = "1"} --this is needed for python3.13 and up.
            }
          },
          -- set the file type of the newly created repl to ft
          -- bufnr is the buffer id of the REPL and ft is the filetype of the 
          -- language being used for the REPL. 
          repl_filetype = function(bufnr, ft)
            return ft
            -- or return a string name such as the following
            -- return "iron"
          end,
          -- Send selections to the DAP repl if an nvim-dap session is running.
          dap_integration = true,
          -- How the repl window will be displayed
          -- See below for more information
          repl_open_cmd = view.split.vertical.botright(50),

          -- repl_open_cmd can also be an array-style table so that multiple 
          -- repl_open_commands can be given.
          -- When repl_open_cmd is given as a table, the first command given will
          -- be the command that `IronRepl` initially toggles.
          -- Moreover, when repl_open_cmd is a table, each key will automatically
          -- be available as a keymap (see `keymaps` below) with the names 
          -- toggle_repl_with_cmd_1, ..., toggle_repl_with_cmd_k
          -- For example,
          -- 
          -- repl_open_cmd = {
          --   view.split.vertical.rightbelow("%40"), -- cmd_1: open a repl to the right
          --   view.split.rightbelow("%25")  -- cmd_2: open a repl below
          -- }

        },
        -- keymaps set manually below so we can control desc symbols
        highlight = {
          italic = true
        },
        ignore_blank_lines = true,
      })

      -- NOTE: keymaps defined here (not via iron keymaps={}) so desc symbols show in which-key
      local ic = require("iron.core")
      local function map(lhs, fn, desc, mode)
        vim.keymap.set(mode or "n", lhs, fn, { desc = desc })
      end
      map("<leader>rr",   function() vim.cmd("IronRepl") end,                        "Toggle REPL")
      map("<leader>rR",   function() vim.cmd("IronRestart") end,                     "Restart REPL")
      map("<leader>rsc",  function() ic.run_motion("send_motion") end,               "Send motion")
      map("<leader>rsc",  ic.visual_send,                                            "Send selection", "v")
      map("<leader>rsf",  ic.send_file,                                              "Send file")
      map("<leader>rsl",  ic.send_line,                                              "Send line")
      map("<leader>rsp",  ic.send_paragraph,                                         "Send paragraph")
      map("<leader>rsu",  ic.send_until_cursor,                                      "Send to cursor")
      map("<leader>rsm",  ic.send_mark,                                              "Send mark")
      map("<leader>rsb",  function() ic.send_code_block(false) end,                  "Send block")
      map("<leader>rsn",  function() ic.send_code_block(true) end,                   "Send block + move")
      map("<leader>rmc",  function() ic.run_motion("mark_motion") end,               "Mark")
      map("<leader>rmc",  ic.mark_visual,                                            "Mark selection", "v")
      map("<leader>rmd",  require("iron.marks").drop_last,                           "Remove mark")
      map("<leader>rs<cr>",function() ic.send(nil, string.char(13)) end,             "Send CR")
      map("<leader>ri",   function() ic.send(nil, string.char(03)) end,              "Interrupt")
      map("<leader>rq",   ic.close_repl,                                             "Exit REPL")
      map("<leader>rc",   function() ic.send(nil, string.char(12)) end,              "Clear REPL")
   end

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

A powerful and extensible increment/decrement plugin that goes far beyond Vim's built-in `<C-a>` and `<C-x>` functionality. Dial.nvim provides intelligent manipulation of numbers, dates, boolean values, and custom patterns with context-aware behavior.

This enhancement plugin offers:
- **Smart number handling**: Increment/decrement decimal, hexadecimal, binary, and octal numbers with proper formatting preservation
- **Date and time manipulation**: Intelligent handling of various date formats, times, and calendar operations
- **Boolean and keyword cycling**: Toggle between true/false, yes/no, on/off, and custom word pairs
- **Custom augend support**: Define your own increment/decrement patterns for domain-specific workflows
- **Visual mode operations**: Apply increment/decrement operations across multiple lines and selections
- **Sequence generation**: Create numbered sequences and patterns with `g<C-a>` and `g<C-x>`
- **Context awareness**: Different behaviors based on file type and cursor position

**Usage**: Use `<C-a>` and `<C-x>` for basic increment/decrement, `g<C-a>` and `g<C-x>` for sequence operations. The plugin automatically detects the type of value under the cursor and applies appropriate transformations.

**Help**: Run `:help dial` for comprehensive documentation. The plugin supports extensive customization for adding new increment/decrement patterns.

For example, with the cursor on "Monday", pressing `<C-a>` changes it to "Tuesday", on "true" it becomes "false", and on dates like "2024-01-15" it increments to "2024-01-16".
___
[GitHub](https://github.com/monaqa/dial.nvim)
```lua
plug({
 'monaqa/dial.nvim',
 event = "VeryLazy",
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
         elements = { "True", "False" },
         word = true,   -- if false, "sand" is incremented into "sor", "doctor" into "doctand", etc.
         cyclic = true, -- "or" is incremented into "and".
         preserve_case = true,
       },
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
       augend.constant.new {
         elements = { "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday" },
         word = true,
         cyclic = true,
         preserve_case = true,
       },
       augend.constant.new {
         elements = { "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" },
         word = true,
         cyclic = true,
         preserve_case = true,
       },
       augend.constant.new {
         elements = { "first", "second", "third", "fourth", "fifth", "sixth", "seventh", "eighth", "ninth", "tenth" },
         word = true,
         cyclic = true,
         preserve_case = true,
       },
       augend.constant.new {
         elements = { "left", "right" },
         word = true,
         cyclic = true,
         preserve_case = true,
       },
       augend.constant.new {
         elements = { "up", "down" },
         word = true,
         cyclic = true,
         preserve_case = true,
       },
       augend.constant.new {
         elements = { "top", "bottom" },
         word = true,
         cyclic = true,
         preserve_case = true,
       },
       augend.constant.new {
         elements = { "start", "end" },
         word = true,
         cyclic = true,
         preserve_case = true,
       },
       augend.constant.new {
         elements = { "enable", "disable" },
         word = true,
         cyclic = true,
         preserve_case = true,
       },
       augend.constant.new {
         elements = { "on", "off" },
         word = true,
         cyclic = true,
         preserve_case = true,
       },
       augend.constant.new {
         elements = { "width", "height" },
         word = true,
         cyclic = true,
         preserve_case = true,
       },
       augend.constant.new {
         elements = { "horizontal", "vertical" },
         word = true,
         cyclic = true,
         preserve_case = true,
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
  event = "VeryLazy",
  opts = {
    keymaps = {
      useDefault = true,
      disable = { "gc" },
    }
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
    { "<leader>j", function() require("treesj").toggle() end, desc = "Split-join lines" },
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
  event = "VeryLazy",
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
        { desc = "" .. case.desc }
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

## Flatten

A smart session management plugin that prevents nested Neovim instances when opening files from terminal buffers, providing seamless file editing without disrupting your workflow. Flatten automatically detects when you're trying to open files from within a terminal and handles them intelligently.

This session manager provides:
- **Nested session prevention**: Automatically opens files in the existing Neovim instance instead of creating nested sessions
- **Terminal integration**: Seamlessly works with terminal buffers and external commands that invoke Neovim
- **Git workflow optimization**: Perfect for Git operations like commits, rebases, and interactive staging that spawn editors
- **Blocking mode support**: Handles blocking operations where the terminal waits for the editor to close
- **Toggleterm integration**: Smart integration with toggleterm plugin for enhanced terminal workflow
- **Automatic cleanup**: Intelligently manages buffer lifecycle for temporary files like Git commits
- **Window management**: Flexible options for how and where opened files appear in your workspace

**Usage**: The plugin works automatically in the background. When you run commands like `git commit` or `nvim file.txt` from a terminal buffer, files open in your existing session instead of creating nested instances.

**Help**: Run `:help flatten` for configuration options. The plugin is particularly useful for Git workflows and any terminal-based operations that need to open files for editing.

For example, when you run `git commit` from a terminal buffer, the commit message file opens in your current Neovim session, and the terminal waits until you save and close the file before continuing.
___
[GitHub](https://github.com/willothy/flatten.nvim)
```lua
plug({
  "willothy/flatten.nvim",
  dependencies = { "folke/snacks.nvim" },
  opts = function()
    ---@type SnacksTerminal?
    local saved_terminal

    local Snacks = require("snacks")

    return {
      window = {
        open = "alternate",
      },
      hooks = {
        should_block = function(argv)
          return vim.tbl_contains(argv, "-b")
        end,
        pre_open = function()
          -- get the currently open snacks terminal
          saved_terminal = Snacks.terminal.get()
        end,
        post_open = function(bufnr, winnr, ft, is_blocking)
          if is_blocking and saved_terminal then
            -- hide the terminal while blocking
            Snacks.terminal.toggle(saved_terminal, { open = false })
          else
            if winnr and vim.api.nvim_win_is_valid(winnr) then
              vim.api.nvim_set_current_win(winnr)
            end
          end

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
          vim.schedule(function()
            if saved_terminal then
              Snacks.terminal.toggle(saved_terminal, { open = true })
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
plug({
  "https://github.com/dhruvasagar/vim-table-mode",
  cmd = { "TableModeToggle", "TableModeEnable", "TableModeDisable", "Tableize" },
  ft = { "markdown", "text", "org" },
})
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
    { "]t",         function() require("todo-comments").jump_next() end, desc = "Next todo" },
    { "[t",         function() require("todo-comments").jump_prev() end, desc = "Prev todo" },
    { "<leader>xt", "<cmd>TodoTrouble<cr>",                              desc = "Todo list" },
    { "<leader>xT", "<cmd>TodoTrouble keywords=TODO,FIX,FIXME<cr>",      desc = "Fixme list" },
    { "<leader>st", "<cmd>TodoTelescope<cr>",                            desc = "Todo" },
    { "<leader>sT", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>",    desc = "Fixme" },
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
  enabled = false,
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
    { "<leader>xx", function() require("trouble").open() end,                              desc = "Trouble" },
    { "<leader>xw", function() require("trouble").open("workspace_diagnostics") end,      desc = "Workspace diagnostics" },
    { "<leader>xd", function() require("trouble").open("document_diagnostics") end,       desc = "Document diagnostics" },
    { "<leader>xq", function() require("trouble").open("quickfix") end,                   desc = "Quickfix" },
    { "<leader>xl", function() require("trouble").open("loclist") end,                    desc = "Location list" },
    { "gR",         function() require("trouble").open("lsp_references") end,             desc = "LSP references" },
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
  opts = {
    -- NOTE: which-key v3 only honours `plugin`, `pattern` (regex on desc) and
    -- filetype rules in `icons.rules` — there is no `lhs` field. Per-key icons
    -- are attached directly on each `spec` entry as `icon = { icon, color }`.
    spec = {
      -- Leader groups (with icons)
      { "<leader>;",       group = "Command",          icon = { icon = "󰞷",  color = "cyan"   } },
      { "<leader><Tab>",   group = "Tabs",             icon = { icon = "󰓩",  color = "cyan"   } },
      { "<leader><Space>", icon = { icon = "󰘳",  color = "purple" } },
      { "<leader>a",       group = "Aider",            icon = { icon = "󰧑",  color = "purple" } },
      { "<leader>b",       group = "Buffer",           icon = { icon = "󰓩",  color = "cyan"   } },
      { "<leader>c",       group = "Case",             icon = { icon = "󰬴",  color = "yellow" } },
      { "<leader>C",       group = "Case (LSP rename)",icon = { icon = "󰬴",  color = "yellow" } },
      { "<leader>d",       group = "Debug",            icon = { icon = "󰃤",  color = "red"    } },
      { "<leader>f",       group = "Find",             icon = { icon = "󰍉",  color = "blue"   } },
      { "<leader>g",       group = "Git",              icon = { icon = "󰊢",  color = "orange" } },
      { "<leader>G",       group = "GitHub",           icon = { icon = "󰊢",  color = "orange" } },
      { "<leader>gf",      group = "Git files",        icon = { icon = "󰊢",  color = "orange" } },
      { "<leader>gs",      group = "Git search",       icon = { icon = "󰊢",  color = "orange" } },
      { "<leader>gsl",     group = "Git log",          icon = { icon = "󰊢",  color = "orange" } },
      { "<leader>h",       group = "Hunk",             icon = { icon = "󱖣",  color = "orange" } },
      { "<leader>r",       group = "REPL",             icon = { icon = "󰆍",  color = "teal"   } },
      { "<leader>rm",      group = "Mark",             icon = { icon = "󰸤",  color = "teal"   } },
      { "<leader>rs",      group = "Send",             icon = { icon = "󰒊",  color = "teal"   } },
      { "<leader>s",       group = "Search",           icon = { icon = "󰍉",  color = "blue"   } },
      { "<leader>t",       group = "Table",            icon = { icon = "󰓫",  color = "cyan"   } },
      { "<leader>u",       group = "UI",               icon = { icon = "󰏘",  color = "purple" } },
      { "<leader>w",       group = "Window",           icon = { icon = "󱂬",  color = "azure"  } },
      { "<leader>x",       group = "Diagnostics",      icon = { icon = "󰒡",  color = "red"    } },
      { "<localleader>c",  group = "Code",             icon = { icon = "󰅩",  color = "cyan"   } },
      { "<localleader>l",  group = "LSP",              icon = { icon = "󰒋",  color = "blue"   } },
      { "<localleader>s",  group = "Search",           icon = { icon = "󰍉",  color = "blue"   } },
      -- Bracket / motion / g-prefix groups
      { "[",               group = "Prev",             icon = { icon = "󰒮",  color = "grey"   } },
      { "]",               group = "Next",             icon = { icon = "󰒭",  color = "grey"   } },
      { "g",               group = "Go to",            icon = { icon = "󰊕",  color = "grey"   } },
      { "z",               group = "Fold",             icon = { icon = "󰘖",  color = "grey"   } },
      -- Single-key leader bindings
      { "<leader>,",       icon = { icon = "󰓩",  color = "cyan"   } },
      { "<leader>/",       icon = { icon = "󰍉",  color = "blue"   } },
      { "<leader>.",       icon = { icon = "󰴒",  color = "green"  } },
      { "<leader>-",       icon = { icon = "󱂬",  color = "azure"  } },
      { "<leader>|",       icon = { icon = "󱂬",  color = "azure"  } },
      { "<leader>`",       icon = { icon = "󰓩",  color = "cyan"   } },
      { "<leader>e",       icon = { icon = "󰙅",  color = "green"  } },
      { "<leader>o",       icon = { icon = "󰙅",  color = "green"  } },
      { "<leader>O",       icon = { icon = "󰙅",  color = "green"  } },
      { "<leader>p",       icon = { icon = "󰅇",  color = "yellow" } },
      { "<leader>j",       icon = { icon = "󰗈",  color = "grey"   } },
      { "<leader>K",       icon = { icon = "󰋗",  color = "grey"   } },
      { "<leader>S",       icon = { icon = "󰓆",  color = "grey"   } },
      { "<leader>q",       icon = { icon = "󰗼",  color = "red"    } },
      { "<leader>l",       icon = { icon = "󰉹",  color = "grey"   } },
      -- Two-key leader bindings (override prefix icons)
      { "<leader>bb",      icon = { icon = "󰓩",  color = "cyan"   } },
      { "<leader>dd",      icon = { icon = "󰊢",  color = "orange" } }, -- diffview overrides debug prefix
      { "<leader>fn",      icon = { icon = "󰈤",  color = "green"  } },
      { "<leader>qq",      icon = { icon = "󰐦",  color = "red"    } },
      { "<leader>;l",      icon = { icon = "󰒲",  color = "grey"   } },
      { "<leader>;n",      icon = { icon = "󰂚",  color = "grey"   } },
      { "<leader>ui",      icon = { icon = "󰙔",  color = "grey"   } },
      { "<leader>ur",      icon = { icon = "󰑐",  color = "grey"   } },
      -- Window / Ctrl bindings
      { "<S-h>",           icon = { icon = "󰓩",  color = "cyan"   } },
      { "<S-l>",           icon = { icon = "󰓩",  color = "cyan"   } },
      { "<C-h>",           icon = { icon = "󱂬",  color = "azure"  } },
      { "<C-j>",           icon = { icon = "󱂬",  color = "azure"  } },
      { "<C-k>",           icon = { icon = "󱂬",  color = "azure"  } },
      { "<C-l>",           icon = { icon = "󱂬",  color = "azure"  } },
      { "<C-s>",           icon = { icon = "󰆓",  color = "green"  } },
      { "<c-b>",           icon = { icon = "󰆍",  color = "teal"   } },
      -- Function keys (debug)
      { "<F1>",            icon = { icon = "󰃤",  color = "red"    } },
      { "<F2>",            icon = { icon = "󰃤",  color = "red"    } },
      { "<F3>",            icon = { icon = "󰃤",  color = "red"    } },
      { "<F4>",            icon = { icon = "󰃤",  color = "red"    } },
      { "<F5>",            icon = { icon = "󰃤",  color = "red"    } },
      { "<F7>",            icon = { icon = "󰃤",  color = "red"    } },
      -- Bracket navigation specifics
      { "[h",              icon = { icon = "󱖣",  color = "orange" } },
      { "]h",              icon = { icon = "󱖣",  color = "orange" } },
      { "[b",              icon = { icon = "󰓩",  color = "cyan"   } },
      { "]b",              icon = { icon = "󰓩",  color = "cyan"   } },
      { "[d",              icon = { icon = "󰒡",  color = "red"    } },
      { "]d",              icon = { icon = "󰒡",  color = "red"    } },
      { "[D",              icon = { icon = "󰒡",  color = "red"    } },
      { "]D",              icon = { icon = "󰒡",  color = "red"    } },
      { "[q",              icon = { icon = "󰒡",  color = "orange" } },
      { "]q",              icon = { icon = "󰒡",  color = "orange" } },
      { "[l",              icon = { icon = "󰒡",  color = "orange" } },
      { "]l",              icon = { icon = "󰒡",  color = "orange" } },
      { "[t",              icon = { icon = "󰄭",  color = "yellow" } },
      { "]t",              icon = { icon = "󰄭",  color = "yellow" } },
      { "[p",              icon = { icon = "󰅇",  color = "yellow" } },
      { "]p",              icon = { icon = "󰅇",  color = "yellow" } },
      { "[P",              icon = { icon = "󰅇",  color = "yellow" } },
      { "]P",              icon = { icon = "󰅇",  color = "yellow" } },
      { "[y",              icon = { icon = "󰅇",  color = "yellow" } },
      { "]y",              icon = { icon = "󰅇",  color = "yellow" } },
      { "[<Space>",        icon = { icon = "󰆎",  color = "grey"   } },
      { "]<Space>",        icon = { icon = "󰆎",  color = "grey"   } },
      -- Treesitter textobject moves (plugin sets keymaps with no desc)
      { "]m",  desc = "Next function start", icon = { icon = "󰊕", color = "grey" } },
      { "]]",  desc = "Next class start",    icon = { icon = "󰊕", color = "grey" } },
      { "]M",  desc = "Next function end",   icon = { icon = "󰊕", color = "grey" } },
      { "][",  desc = "Next class end",      icon = { icon = "󰊕", color = "grey" } },
      { "[m",  desc = "Prev function start", icon = { icon = "󰊕", color = "grey" } },
      { "[[",  desc = "Prev class start",    icon = { icon = "󰊕", color = "grey" } },
      { "[M",  desc = "Prev function end",   icon = { icon = "󰊕", color = "grey" } },
      { "[]",  desc = "Prev class end",      icon = { icon = "󰊕", color = "grey" } },
      -- g-prefix specifics
      { "gd",              icon = { icon = "󰿙",  color = "blue"   } },
      { "gD",              icon = { icon = "󰿙",  color = "blue"   } },
      { "gR",              icon = { icon = "󰈇",  color = "blue"   } },
      { "gr",              icon = { icon = "󰒋",  color = "blue"   } },
      { "gO",              icon = { icon = "󰍉",  color = "blue"   } },
      { "gw",              icon = { icon = "󰍉",  color = "blue"   } },
      { "gx",              icon = { icon = "󰌷",  color = "azure"  } },
      { "gc",              icon = { icon = "󰅩",  color = "grey"   } },
      { "gb",              icon = { icon = "󰅩",  color = "grey"   } },
      { "gp",              icon = { icon = "󰅇",  color = "yellow" } },
      { "gP",              icon = { icon = "󰅇",  color = "yellow" } },
      { "ge",              icon = { icon = "󰕞",  color = "grey"   } },
      -- Spider subword motions / search
      { "w",               icon = { icon = "󰕞",  color = "grey"   } },
      { "e",               icon = { icon = "󰕞",  color = "grey"   } },
      { "b",               icon = { icon = "󰕞",  color = "grey"   } },
      { "n",               icon = { icon = "󰍉",  color = "blue"   } },
      { "N",               icon = { icon = "󰍉",  color = "blue"   } },
      { "y",               icon = { icon = "󰅇",  color = "yellow" } },
      { "p",               icon = { icon = "󰅇",  color = "yellow" } },
      { "P",               icon = { icon = "󰅇",  color = "yellow" } },
      -- Treesitter swap (conflicts with Aider group — shown as individual keys)
      { "<leader>A", desc = "Swap param back", mode = "n", icon = { icon = "󰓡", color = "yellow" } },
    },
  },
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
  event = "VeryLazy",
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
        sync_with_numbered_registers = true,
        cancel_event = "update",
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
  keys = {
    {
      "<leader>p",
      "<cmd>YankyRingHistory<cr>",
      desc = "Yank history"
    },
    { "y",  "<Plug>(YankyYank)",                      mode = { "n", "x" }, desc = "Yank" },
    { "p",  "<Plug>(YankyPutAfter)",                  mode = { "n", "x" }, desc = "Put after" },
    { "P",  "<Plug>(YankyPutBefore)",                 mode = { "n", "x" }, desc = "Put before" },
    { "gp", "<Plug>(YankyGPutAfter)",                 mode = { "n", "x" }, desc = "Put after selection" },
    { "gP", "<Plug>(YankyGPutBefore)",                mode = { "n", "x" }, desc = "Put before selection" },
    { "[y", "<Plug>(YankyCycleForward)",                                    desc = "Cycle yank history" },
    { "]y", "<Plug>(YankyCycleBackward)",                                   desc = "Cycle yank history" },
    { "]p", "<Plug>(YankyPutIndentAfterLinewise)",                          desc = "Put indented after" },
    { "[p", "<Plug>(YankyPutIndentBeforeLinewise)",                         desc = "Put indented before" },
    { "]P", "<Plug>(YankyPutIndentAfterLinewise)",                          desc = "Put indented after" },
    { "[P", "<Plug>(YankyPutIndentBeforeLinewise)",                         desc = "Put indented before" },
    { ">p", "<Plug>(YankyPutIndentAfterShiftRight)",                        desc = "Put + indent right" },
    { "<p", "<Plug>(YankyPutIndentAfterShiftLeft)",                         desc = "Put + indent left" },
    { ">P", "<Plug>(YankyPutIndentBeforeShiftRight)",                       desc = "Put before + indent right" },
    { "<P", "<Plug>(YankyPutIndentBeforeShiftLeft)",                        desc = "Put before + indent left" },
    { "=p", "<Plug>(YankyPutAfterFilter)",                                  desc = "Put (filtered)" },
    { "=P", "<Plug>(YankyPutBeforeFilter)",                                 desc = "Put before (filtered)" },
  },
})
```
@end

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

# AI

## Aider

AI-powered coding assistant that helps you edit code in your terminal. Aider can make coordinated edits across multiple files, understand your codebase, and work with you to implement features, fix bugs, and refactor code using various AI models.

This plugin provides:
- **AI-powered code editing**: Get intelligent suggestions and automated code changes
- **Multi-file coordination**: Make changes across multiple files in a single session
- **Git integration**: Automatically commits changes with descriptive commit messages
- **Multiple AI models**: Support for GPT-4, Claude, and other leading AI models
- **Context awareness**: Understands your entire codebase for better suggestions
- **Interactive sessions**: Chat with AI about your code and get real-time assistance

**Usage**: Use the configured keybindings to toggle Aider, send code selections, add/drop files, and manage your AI coding sessions. The plugin integrates seamlessly with your existing workflow.

**Help**: Aider works best when you provide clear, specific instructions about what you want to accomplish. It can help with everything from small bug fixes to large feature implementations.

For example, you can ask Aider to "refactor this function to use async/await" or "add error handling to this API call" and it will make the appropriate changes across your codebase.
___
[GitHub](https://github.com/GeorgesAlkhouri/nvim-aider)
```lua
plug({
    "GeorgesAlkhouri/nvim-aider",
    cmd = "Aider",
    -- Example key mappings for common actions:
    keys = {
      { "<leader>a/", "<cmd>Aider toggle<cr>",        desc = "Toggle",          },
      { "<leader>as", "<cmd>Aider send<cr>",          desc = "Send",            mode = { "n", "v" } },
      { "<leader>ac", "<cmd>Aider command<cr>",       desc = "Commands",        },
      { "<leader>ab", "<cmd>Aider buffer<cr>",        desc = "Send buffer",     },
      { "<leader>a+", "<cmd>Aider add<cr>",           desc = "Add file",        },
      { "<leader>a-", "<cmd>Aider drop<cr>",          desc = "Drop file",       },
      { "<leader>ar", "<cmd>Aider add readonly<cr>",  desc = "Add read-only",   },
      { "<leader>aR", "<cmd>Aider reset<cr>",         desc = "Reset session",   },
      { "<leader>a+", "<cmd>AiderTreeAddFile<cr>",    desc = "Add file (tree)", ft = "NvimTree" },
      { "<leader>a-", "<cmd>AiderTreeDropFile<cr>",   desc = "Drop file (tree)",ft = "NvimTree" },
    },
    dependencies = {
      "folke/snacks.nvim",
      --- The below dependencies are optional
      "catppuccin/nvim",
      "nvim-tree/nvim-tree.lua",
      --- Neo-tree integration
      {
        "nvim-neo-tree/neo-tree.nvim",
        opts = function(_, opts)
          -- Example mapping configuration (already set by default)
          -- opts.window = {
          --   mappings = {
          --     ["+"] = { "nvim_aider_add", desc = "add to aider" },
          --     ["-"] = { "nvim_aider_drop", desc = "drop from aider" }
          --     ["="] = { "nvim_aider_add_read_only", desc = "add read-only to aider" }
          --   }
          -- }
          require("nvim_aider.neo_tree").setup(opts)
        end,
      },
    },
    config = true,
    opts = {
      auto_reload = true,
    },
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
  branch = 'master', -- archived v0.9 API; shim below patches its handlers for nvim 0.12
  priority = 5000,
  dependencies = {
    { 'nvim-treesitter/nvim-treesitter-textobjects', branch = 'master' },
    { "JoosepAlviste/nvim-ts-context-commentstring", lazy = true }
  },
  build = ':TSUpdate',
  config = function(_, opts)
    require('nvim-treesitter.configs').setup(opts)

    -- nvim 0.12 changed treesitter directive/predicate handlers to receive
    -- `captures` as table<int, TSNode[]> (arrays of nodes). nvim-treesitter
    -- master is archived and still treats `match[id]` as a single node, so
    -- markdown injections, locals, etc. crash with "attempt to call method
    -- 'range' (a nil value)". Re-register the 6 affected handlers with the
    -- new signature; force = true overrides the broken originals.
    local q = require('vim.treesitter.query')
    local function first(captures, id)
      local v = captures[id]
      if type(v) == 'table' then return v[1] end
      return v
    end

    local html_script_lang = {
      importmap = 'json',
      module = 'javascript',
      ['application/ecmascript'] = 'javascript',
      ['text/ecmascript'] = 'javascript',
    }
    local md_lang_alias = {
      ex = 'elixir', pl = 'perl', sh = 'bash', uxn = 'uxntal', ts = 'typescript',
    }
    local function md_info_to_lang(alias)
      local m = vim.filetype.match { filename = 'a.' .. alias }
      return m or md_lang_alias[alias] or alias
    end

    q.add_predicate('nth?', function(captures, _pat, _bufnr, pred)
      local node = first(captures, pred[2])
      local n = tonumber(pred[3])
      if node and node:parent() and node:parent():named_child_count() > n then
        return node:parent():named_child(n) == node
      end
      return false
    end, { force = true })

    q.add_predicate('is?', function(captures, _pat, bufnr, pred)
      local node = first(captures, pred[2])
      local types = { unpack(pred, 3) }
      if not node then return true end
      local _, _, kind = require('nvim-treesitter.locals').find_definition(node, bufnr)
      return vim.tbl_contains(types, kind)
    end, { force = true })

    q.add_predicate('kind-eq?', function(captures, _pat, _bufnr, pred)
      local node = first(captures, pred[2])
      local types = { unpack(pred, 3) }
      if not node then return true end
      return vim.tbl_contains(types, node:type())
    end, { force = true })

    q.add_directive('set-lang-from-mimetype!', function(captures, _pat, bufnr, pred, metadata)
      local node = first(captures, pred[2])
      if not node then return end
      local v = vim.treesitter.get_node_text(node, bufnr)
      local configured = html_script_lang[v]
      if configured then
        metadata['injection.language'] = configured
      else
        local parts = vim.split(v, '/', {})
        metadata['injection.language'] = parts[#parts]
      end
    end, { force = true })

    q.add_directive('set-lang-from-info-string!', function(captures, _pat, bufnr, pred, metadata)
      local node = first(captures, pred[2])
      if not node then return end
      local alias = vim.treesitter.get_node_text(node, bufnr):lower()
      metadata['injection.language'] = md_info_to_lang(alias)
    end, { force = true })

    q.add_directive('downcase!', function(captures, _pat, bufnr, pred, metadata)
      local id = pred[2]
      local node = first(captures, id)
      if not node then return end
      local text = vim.treesitter.get_node_text(node, bufnr, { metadata = metadata[id] }) or ''
      if not metadata[id] then metadata[id] = {} end
      metadata[id].text = string.lower(text)
    end, { force = true })
  end,
  opts = {
    -- Add languages to be installed here that you want installed for treesitter
    ensure_installed = {
      'lua',
      'vim',
      'vimdoc',
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
    prefix = "",
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
    -- register all text objects with which-key using new spec format
    local wk = require("which-key")
    wk.add({
      mode = { "o", "x" },
      { "i ", desc = "Whitespace" },
      { 'i"', desc = 'Balanced "' },
      { "i'", desc = "Balanced '" },
      { "i`", desc = "Balanced `" },
      { "i(", desc = "Balanced (" },
      { "i)", desc = "Balanced ) + space" },
      { "i>", desc = "Balanced > + space" },
      { "i<", desc = "Balanced <" },
      { "i]", desc = "Balanced ] + space" },
      { "i[", desc = "Balanced [" },
      { "i}", desc = "Balanced } + space" },
      { "i{", desc = "Balanced {" },
      { "i?", desc = "User prompt" },
      { "i_", desc = "Underscore" },
      { "ia", desc = "Argument" },
      { "ib", desc = "Bracket ), ], }" },
      { "ic", desc = "Class" },
      { "if", desc = "Function" },
      { "io", desc = "Block/cond/loop" },
      { "iq", desc = "Quote" },
      { "it", desc = "Tag" },
      { "in", group = "Inside next" },
      { "il", group = "Inside last" },
      { "a ", desc = "Whitespace" },
      { 'a"', desc = 'Balanced "' },
      { "a'", desc = "Balanced '" },
      { "a`", desc = "Balanced `" },
      { "a(", desc = "Balanced (" },
      { "a)", desc = "Balanced )" },
      { "a>", desc = "Balanced >" },
      { "a<", desc = "Balanced <" },
      { "a]", desc = "Balanced ]" },
      { "a[", desc = "Balanced [" },
      { "a}", desc = "Balanced }" },
      { "a{", desc = "Balanced {" },
      { "a?", desc = "User prompt" },
      { "a_", desc = "Underscore" },
      { "aa", desc = "Argument" },
      { "ab", desc = "Bracket ), ], }" },
      { "ac", desc = "Class" },
      { "af", desc = "Function" },
      { "ao", desc = "Block/cond/loop" },
      { "aq", desc = "Quote" },
      { "at", desc = "Tag" },
      { "an", group = "Around next" },
      { "al", group = "Around last" },
    })
  end,
})
```

# PACK

Process the accumulated `plugins` table with Neovim's built-in `vim.pack`.
This block reimplements the lazy.nvim features actually used in this config:
parallel install, dependency ordering, `event`/`cmd`/`ft`/`keys` lazy-loading,
priority, build hooks, and `config = true|fn|opts` dispatch. See [Pack Helper
Function](#pack-helper-function) for `plug()`.
___
[`:help vim.pack`](https://neovim.io/doc/user/pack.html#vim.pack)

```lua
-- State shared across the loader -----------------------------------------
local install_specs   = {}    -- list of { src, name, version } for vim.pack.add
local eager_queue     = {}    -- specs to load now, sorted by priority
local lazy_pending    = {}    -- name -> spec (waiting for trigger or dep)
local loaded          = {}    -- name -> true once :packadd has run
local build_hooks     = {}    -- name -> string|function from spec.build
local specs_by_name   = {}    -- name -> { spec, deps = { dep_name, ... } }
local toplevel_names  = {}    -- name -> true for plugins registered via plug()
local pending_dep_refs = {}   -- bare-name dep refs to resolve in pass 2
local cmd_stubs       = {}    -- name -> { cmd_name, ... } (so load_plugin can clear them)
local idx_counter     = 0     -- insertion counter for stable sort

-- VeryLazy: fire `User VeryLazy` once after the UI is ready.
vim.api.nvim_create_autocmd("UIEnter", {
  once = true,
  callback = function()
    vim.schedule(function()
      vim.api.nvim_exec_autocmds("User", { pattern = "VeryLazy" })
    end)
  end,
})

-- Build hooks: run on install/update of any plugin that declared `build`.
vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    local d = ev.data
    if d.kind ~= "install" and d.kind ~= "update" then return end
    local hook = build_hooks[d.spec.name]
    if not hook then return end
    -- Most build steps need the plugin sourced (e.g. :TSUpdate is a plugin command).
    pcall(vim.cmd.packadd, d.spec.name)
    if type(hook) == "function" then
      pcall(hook)
    elseif type(hook) == "string" then
      if hook:sub(1, 1) == ":" then
        vim.cmd(hook:sub(2))
      else
        vim.fn.system(hook)
      end
    end
  end,
})

-- Spec helpers -----------------------------------------------------------
local function spec_name(spec)
  return spec.name or (spec[1] and spec[1]:match(".*/(.*)"))
end

local function spec_src(spec)
  local s = spec[1]
  if not s then return nil end
  if s:match("^https?://") or s:match("^git@") then return s end
  return "https://github.com/" .. s
end

local function resolve_version(spec)
  -- lazy `version = "*"` or `false` mean "default" → nil for vim.pack.
  local v = spec.version
  if v == "*" or v == false then v = nil end
  return v or spec.tag or spec.branch
end

local function resolve_opts(spec)
  local o = spec.opts
  if type(o) == "function" then o = o(spec, {}) end
  return o or {}
end

-- Idempotent loader called by every trigger and by the eager flush.
local function load_plugin(name)
  if loaded[name] then return end
  loaded[name] = true
  local rec = specs_by_name[name]
  if not rec then return end
  for _, dep_name in ipairs(rec.deps) do load_plugin(dep_name) end
  if rec.spec.init then pcall(rec.spec.init) end
  -- Drop our cmd stubs so the plugin's setup can create the real commands
  -- with the same name without colliding (nvim_create_user_command errors
  -- on duplicate when force=false, which is the default in most plugins).
  for _, c in ipairs(cmd_stubs[name] or {}) do
    pcall(vim.api.nvim_del_user_command, c)
  end
  cmd_stubs[name] = nil
  pcall(vim.cmd.packadd, name)
  if rec.spec.config then pcall(rec.spec.config, rec.spec, resolve_opts(rec.spec)) end
end

-- Trigger registrars -----------------------------------------------------

-- Dedupe re-fires: many plugins share BufReadPost / FileType, and naïvely
-- calling nvim_exec_autocmds inside each callback causes "nesting too deep".
local refire_pending = {}
local function schedule_refire(events, buf)
  local key = table.concat(events, ",") .. ":" .. (buf or 0)
  if refire_pending[key] then return end
  refire_pending[key] = true
  vim.schedule(function()
    refire_pending[key] = nil
    pcall(vim.api.nvim_exec_autocmds, events, { buffer = buf, modeline = false })
  end)
end

local function register_event(spec, name)
  local raw = type(spec.event) == "table" and spec.event or { spec.event }
  local events, patterns = {}, nil
  for _, e in ipairs(raw) do
    if e == "VeryLazy" then
      events[#events + 1] = "User"
      patterns = "VeryLazy"
    else
      events[#events + 1] = e
    end
  end
  local id
  id = vim.api.nvim_create_autocmd(events, {
    pattern = patterns,
    callback = function(args)
      pcall(vim.api.nvim_del_autocmd, id)   -- self-delete before loading
      load_plugin(name)
      if patterns ~= "VeryLazy" then
        schedule_refire(events, args.buf)
      end
    end,
  })
end

local function register_cmd(spec, name)
  local cmds = type(spec.cmd) == "table" and spec.cmd or { spec.cmd }
  cmd_stubs[name] = cmds
  for _, c in ipairs(cmds) do
    vim.api.nvim_create_user_command(c, function(a)
      load_plugin(name)   -- this clears our stubs and runs setup → real cmd exists
      vim.cmd({
        cmd = c,
        args = a.fargs,
        bang = a.bang,
        range = (a.range > 0) and { a.line1, a.line2 } or nil,
        mods = a.smods,
      })
    end, { nargs = "*", bang = true, range = true, complete = "file" })
  end
end

local function register_ft(spec, name)
  local fts = type(spec.ft) == "table" and spec.ft or { spec.ft }
  local id
  id = vim.api.nvim_create_autocmd("FileType", {
    pattern = fts,
    callback = function(args)
      pcall(vim.api.nvim_del_autocmd, id)   -- self-delete before loading
      load_plugin(name)
      schedule_refire({ "FileType" }, args.buf)
    end,
  })
end

local function register_keys(spec, name)
  for _, k in ipairs(spec.keys) do
    local lhs, rhs, mode, desc, expr, silent, remap
    if type(k) == "string" then
      lhs, mode = k, "n"
    else
      lhs, rhs = k[1], k[2]
      mode = k.mode or "n"
      desc, expr, silent, remap = k.desc, k.expr, k.silent, k.remap
    end
    local modes = type(mode) == "table" and mode or { mode }
    for _, m in ipairs(modes) do lazy_keys_index[m .. ":" .. lhs] = true end

    if rhs then
      vim.keymap.set(mode, lhs, function()
        load_plugin(name)
        if type(rhs) == "function" then return rhs() end
        local keys = vim.api.nvim_replace_termcodes(rhs, true, true, true)
        vim.api.nvim_feedkeys(keys, "m", false)
      end, { desc = desc, silent = silent ~= false, expr = expr, remap = remap })
    else
      vim.keymap.set(mode, lhs, function()
        for _, m in ipairs(modes) do pcall(vim.keymap.del, m, lhs) end
        load_plugin(name)
        local keys = vim.api.nvim_replace_termcodes(lhs, true, true, true)
        vim.api.nvim_feedkeys(keys, "m", false)
      end, { desc = desc, silent = silent ~= false, remap = remap })
    end
  end
end

-- Recursive spec processor ----------------------------------------------
-- `is_dep` is true when called recursively for a dependency: such specs
-- never go into eager_queue — their parent's load_plugin handles loading.
local function process(spec, is_dep)
  if type(spec) == "string" then spec = { spec } end
  if type(spec) ~= "table" or spec.enabled == false then return nil end

  -- Nested form `plug({ { "owner/repo", ... } })` — outer table is a list
  -- of specs. Recurse on each.
  if type(spec[1]) == "table" then
    for _, sub in ipairs(spec) do process(sub, is_dep) end
    return nil
  end

  local name = spec_name(spec)
  if not name then return nil end
  if specs_by_name[name] then return name end

  -- Recurse dependencies first so they install/load before the parent.
  -- Accept: string (single dep), list of strings/tables, or nested specs.
  -- Bare-name string deps (no "/") are name references resolved in pass 2.
  -- Deps that match a top-level plug() call are not recursed here — the main
  -- loop will process the full spec; we only record the dep_name for ordering.
  local dep_names = {}
  if spec.dependencies then
    local deps = spec.dependencies
    if type(deps) == "string" then deps = { deps } end
    for _, dep in ipairs(deps) do
      if type(dep) == "string" and not dep:find("/") then
        pending_dep_refs[#pending_dep_refs + 1] = { parent = name, ref = dep }
      else
        local dep_spec = type(dep) == "string" and { dep } or dep
        local dn = spec_name(dep_spec)
        if dn and toplevel_names[dn] then
          dep_names[#dep_names + 1] = dn
        else
          dn = process(dep, true)   -- recurse with is_dep=true
          if dn then dep_names[#dep_names + 1] = dn end
        end
      end
    end
  end

  idx_counter = idx_counter + 1
  spec._idx = idx_counter

  local src = spec_src(spec)
  if src then
    install_specs[#install_specs + 1] = {
      src = src,
      name = name,
      version = resolve_version(spec),
    }
  end

  if spec.build then build_hooks[name] = spec.build end
  specs_by_name[name] = { spec = spec, deps = dep_names }

  -- Route: explicit triggers OR `lazy = true` → defer; otherwise eager.
  -- Dep stubs (is_dep=true) never go to eager_queue: load_plugin recurses
  -- through their parent's deps when the parent fires.
  local has_trigger = spec.event or spec.cmd or spec.ft or spec.keys
  if has_trigger or spec.lazy == true then
    lazy_pending[name] = spec
    if spec.event then register_event(spec, name) end
    if spec.cmd   then register_cmd(spec, name)   end
    if spec.ft    then register_ft(spec, name)    end
    if spec.keys  then register_keys(spec, name)  end
  elseif not is_dep then
    eager_queue[#eager_queue + 1] = spec
  end
  return name
end

-- Pass 1a: collect names of all top-level plug() calls so dep recursion
-- defers to the full spec when a dep references a top-level plugin.
local function collect_toplevel(spec)
  if type(spec) == "string" then spec = { spec } end
  if type(spec) ~= "table" or spec.enabled == false then return end
  if type(spec[1]) == "table" then
    for _, sub in ipairs(spec) do collect_toplevel(sub) end
    return
  end
  local nm = spec_name(spec)
  if nm then toplevel_names[nm] = true end
end
for _, spec in ipairs(plugins) do collect_toplevel(spec) end

-- Pass 1b: process each top-level spec.
for _, spec in ipairs(plugins) do process(spec) end

-- Pass 2: resolve bare-name dep references (e.g. mini.ai → "nvim-treesitter-textobjects").
for _, r in ipairs(pending_dep_refs) do
  if specs_by_name[r.ref] and specs_by_name[r.parent] then
    table.insert(specs_by_name[r.parent].deps, r.ref)
  end
end

-- Sort eager queue: priority desc, insertion order asc on ties.
table.sort(eager_queue, function(a, b)
  local pa, pb = a.priority or 50, b.priority or 50
  if pa ~= pb then return pa > pb end
  return a._idx < b._idx
end)

-- Build the set of plugins that should source plugin/* at startup: eager
-- plugins plus their transitive dependencies. Lazy plugins stay off rtp
-- entirely until a trigger fires; load_plugin will :packadd them then.
local eager_set = {}
local function mark_eager(nm)
  if eager_set[nm] then return end
  eager_set[nm] = true
  local rec = specs_by_name[nm]
  if rec then
    for _, dn in ipairs(rec.deps) do mark_eager(dn) end
  end
end
for _, s in ipairs(eager_queue) do mark_eager(spec_name(s)) end

-- Manual eager pin: SNIPPETS section does `require("luasnip")` at top-level
-- (outside any plug() config function), so LuaSnip must be on rtp at startup.
mark_eager("LuaSnip")

-- Single batched install. The load callback only :packadds eager plugins
-- (sources their plugin/* now); everything else stays installed-but-dormant.
-- Split install_specs into two batches: eager and lazy.
-- - Eager batch uses load=false → vim.pack runs `:packadd!` for each, which
--   adds the dir to rtp without sourcing plugin/. Nvim's "loading rtp plugins"
--   phase later sources plugin/* of every rtp entry — by which point all eager
--   plugins are on rtp, so cross-plugin requires resolve correctly.
-- - Lazy batch uses load=function (no-op) → plugin stays installed but OFF rtp;
--   load_plugin will :packadd it (sourcing plugin/) when its trigger fires.
local eager_install, lazy_install = {}, {}
for _, s in ipairs(install_specs) do
  if eager_set[s.name] then table.insert(eager_install, s)
  else                      table.insert(lazy_install, s) end
end
vim.pack.add(eager_install, { confirm = false, load = false })
vim.pack.add(lazy_install,  { confirm = false, load = function() end })

-- Eager plugins run init/config now in priority order.
for _, s in ipairs(eager_queue) do load_plugin(spec_name(s)) end

-- :Pack opens the vim.pack update buffer; rebound from old <leader>;l → :Lazy.
vim.api.nvim_create_user_command("Pack", function() vim.pack.update() end,
  { desc = "Update plugins via vim.pack" })
vim.keymap.set("n", "<leader>;l", "<cmd>Pack<cr>", { desc = "Pack update" })
```

# KEYMAPS

Here I configure my native neovim keybindings, these are any key binds not involved with any plugin.
___
```lua
local function map(mode, lhs, rhs, opts)
  -- Skip if a deferred plugin has already claimed this lhs via `keys = {...}`.
  local modes = type(mode) == "table" and mode or { mode }
  for _, m in ipairs(modes) do
    if lazy_keys_index[m .. ":" .. lhs] then return end
  end
  opts = opts or {}
  opts.silent = opts.silent ~= false
  if opts.remap and not vim.g.vscode then
    opts.remap = nil
  end
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- better up/down
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Move to window using the <ctrl> hjkl keys
map("n", "<C-h>", "<C-w>h", { desc = "Left window",  remap = true })
map("n", "<C-j>", "<C-w>j", { desc = "Lower window", remap = true })
map("n", "<C-k>", "<C-w>k", { desc = "Upper window", remap = true })
map("n", "<C-l>", "<C-w>l", { desc = "Right window", remap = true })

-- Resize window using <ctrl> arrow keys
map("n", "<C-Up>",    "<cmd>resize +2<cr>",          { desc = "Height +" })
map("n", "<C-Down>",  "<cmd>resize -2<cr>",          { desc = "Height -" })
map("n", "<C-Left>",  "<cmd>vertical resize -2<cr>", { desc = "Width -" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Width +" })

-- Move Lines
map("n", "<A-j>", "<cmd>m .+1<cr>==",       { desc = "Move line down" })
map("n", "<A-k>", "<cmd>m .-2<cr>==",       { desc = "Move line up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi",{ desc = "Move line down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi",{ desc = "Move line up" })
map("v", "<A-j>", ":m '>+1<cr>gv=gv",       { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv",       { desc = "Move selection up" })

-- Navigate through buffers
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>",     { desc = "Next buffer" })
map("n", "[b",    "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "]b",    "<cmd>bnext<cr>",     { desc = "Next buffer" })

map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Alternate buffer" })
map("n", "<leader>`",  "<cmd>e #<cr>", { desc = "Alternate buffer" })

-- Clear search with <esc>
map({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Clear search" })

-- Clear search, diff update and redraw
-- taken from runtime/lua/_editor.lua
map(
  "n",
  "<leader>ur",
  "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>",
  { desc = "Redraw / clear search / diff update" }
)

map({ "n", "x" }, "gw", "*N", { desc = "Search word" })

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
map("n", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next match" })
map("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next match" })
map("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next match" })
map("n", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev match" })
map("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev match" })
map("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev match" })

-- Add undo break-points
map("i", ",", ",<c-g>u")
map("i", ".", ".<c-g>u")
map("i", ";", ";<c-g>u")

-- save file
map({ "i", "v", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save" })

--keywordprg
map("n", "<leader>K", "<cmd>norm! K<cr>", { desc = "Keywordprg" })

-- better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- new file
map("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New file" })

map("n", "<leader>xl", "<cmd>lopen<cr>", { desc = "Location list" })
map("n", "<leader>xq", "<cmd>copen<cr>", { desc = "Quickfix list" })

-- quit
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })

-- highlights under cursor
map("n", "<leader>ui", vim.show_pos, { desc = "Inspect pos" })


-- Terminal Mappings
map("t", "<esc><esc>",  "<c-\\><c-n>",        { desc = "Normal mode" })
map("t", "<c-[><c-[>",  "<c-\\><c-n>",        { desc = "Normal mode" })
map("t", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Left window" })
map("t", "<C-j>", "<cmd>wincmd j<cr>", { desc = "Lower window" })
map("t", "<C-k>", "<cmd>wincmd k<cr>", { desc = "Upper window" })
map("t", "<C-l>", "<cmd>wincmd l<cr>", { desc = "Right window" })
map("t", "<C-/>", "<cmd>close<cr>",    { desc = "Hide terminal" })
map("t", "<c-_>", "<cmd>close<cr>",    { desc = "which_key_ignore" })

-- windows
map("n", "<leader>ww", "<C-W>p", { desc = "Other window",  remap = true })
map("n", "<leader>wd", "<C-W>c", { desc = "Delete window", remap = true })
map("n", "<leader>w-", "<C-W>s", { desc = "Split below",   remap = true })
map("n", "<leader>w|", "<C-W>v", { desc = "Split right",   remap = true })
map("n", "<leader>-",  "<C-W>s", { desc = "Split below",   remap = true })
map("n", "<leader>|",  "<C-W>v", { desc = "Split right",   remap = true })

-- tabs
map("n", "<leader><tab>G",     "<cmd>tablast<cr>",   { desc = "Last tab" })
map("n", "<leader><tab>g",     "<cmd>tabfirst<cr>",  { desc = "First tab" })
map("n", "<leader><tab><tab>", "<cmd>tabnew<cr>",    { desc = "New tab" })
map("n", "<leader><tab>]",     "<cmd>tabnext<cr>",   { desc = "Next tab" })
map("n", "<leader><tab>d",     "<cmd>tabclose<cr>",  { desc = "Close tab" })
map("n", "<leader><tab>[",     "<cmd>tabprevious<cr>",{ desc = "Prev tab" })
map("n", "<leader><tab>s",     "<cmd>tab split<cr>", { desc = "Split tab" })

-- Convenience
map('n', '\\', ':%s//g<left><left>', { desc = "Search buffer" })
map('v', '\\', ':s//g<Left><Left>',  { desc = "Search selection" })
map("n", "<leader>S", "<cmd>set spell!<cr>", { desc = "Toggle spell" })

-- Insert file name
map("i", "<C-f>f", '<C-R>=expand("%:t")<cr>',     { desc = "Filename" })
map("i", "<C-f>F", '<C-R>=expand("%:t:r")<cr>',   { desc = "Filename (no ext)" })
map("i", "<C-f>e", '<C-R>=expand("%:e")<cr>',     { desc = "Extension" })
map("i", "<C-f>p", '<C-R>=expand("%:p:h")<cr>',   { desc = "Abs path" })
map("i", "<C-f>P", '<C-R>=expand("%:h")<cr>',     { desc = "Rel path" })
map("i", "<C-f>d", '<C-R>=expand("%:p:h:t")<cr>', { desc = "Parent dir" })
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
    local file = vim.uv.fs_realpath(event.match) or event.match
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

command("Tangle", function()
  dofile(vim.fn.stdpath("config") .. "/tangle.lua")
  vim.notify("Tangled README.md -> lua/config.lua. Restart Neovim to load changes.", vim.log.levels.INFO)
end, { desc = "Re-tangle README.md into lua/config.lua" })
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


# FILETYPE OPTIONS




## Markdown

```lua
  vim.api.nvim_create_autocmd("FileType", {
  group = augroup("ftplugin"),
  pattern = "markdown",
  callback = function()
      vim.opt_local.wrap = true
      -- Close all header folds on open. Deferred so UFO has applied
      -- treesitter fold ranges first; otherwise foldlevel=0 lands
      -- before there are any folds to close.
      vim.schedule(function()
        vim.opt_local.foldlevel = 0
      end)
  end,
  })
```
