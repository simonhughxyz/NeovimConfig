-- options.lua
--
-- Declare basic neovim options that are non plugin specific

local o = vim.opt

o.autowrite = true           -- Enable auto write
o.clipboard = "unnamedplus"  -- Sync with system clipboard
o.completeopt = "menu,menuone,noselect"
o.conceallevel = 3           -- Hide * markup for bold and italic
o.confirm = true             -- Confirm to save changes before exiting modified buffer
o.cursorline = true          -- Enable highlighting of the current line
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
