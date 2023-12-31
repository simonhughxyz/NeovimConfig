-- filetype.lua
--
-- Fileype specific plugins

local neorg_opts = {
          ["core.defaults"] = {}, -- Loads default behaviour
          ["core.concealer"] = {  -- Adds pretty icons to your documents
            config = {
              foldlevelstart = "1",
              icon_preset = "diamond",
            },
          },
          ["core.dirman"] = { -- Manages Neorg workspaces
            config = {
              workspaces = {
                documents = "~/Documents",
                journal = "~/Documents/journal",
                health = "~/Documents/health",
                career = "~/Documents/career",
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

if vim.fn.has("nvim-0.10") == 1 then
  neorg_opts["load"]["core.ui.calendar"] = {}
end

return {
  { "chrisbra/csv.vim",           ft = { "csv" } },
  { "ledger/vim-ledger",          ft = { "ledger" } },
  { "tmux-plugins/vim-tmux",      ft = { "tmux" } },
  -- { "baskerville/vim-sxhkdrc", ft = { "sxhkdrc" } },
  { "fourjay/vim-password-store", ft = { "pass" } },
  { "tmhedberg/SimpylFold",       ft = { "python" } },
  { "tridactyl/vim-tridactyl",    ft = { "trydactyl" } },
  { "neomutt/neomutt.vim",        ft = { "muttrc" } },
  { "pangloss/vim-javascript",    ft = { "javascript" } },
  { "leafgarland/typescript-vim", ft = { "typescript" } },
  { "MTDL9/vim-log-highlighting", ft = "log" },
  {
    "nvim-neorg/neorg",
    build = ":Neorg sync-parsers",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "Pocco81/true-zen.nvim",
      "nvim-neorg/neorg-telescope",
      "nvim-treesitter/nvim-treesitter",
      "nvim-treesitter/nvim-treesitter-textobjects",
      "nvim-cmp",
    },
    config = function()
      require("neorg").setup(neorg_opts)

      local neorg_callbacks = require("neorg.core.callbacks")

      neorg_callbacks.on_event("core.keybinds.events.enable_keybinds", function(_, keybinds)
        -- Map all the below keybinds only when the "norg" mode is active
        keybinds.map_event_to_mode("norg", {
          n = { -- Bind keys in normal mode
            { "<localleader>ff", "core.integrations.telescope.find_norg_files",  opts = { desc = 'Find Norg Files' } },
            { "<localleader>fl", "core.integrations.telescope.find_linkable",    opts = { desc = 'Find Linkable' } },
            { "<localleader>sh", "core.integrations.telescope.search_headings",  opts = { desc = 'Search Headings' } },
            { "<localleader>sw", "core.integrations.telescope.switch_workspace", opts = { desc = 'Switch Workspace' } },
          },

          i = { -- Bind in insert mode
            { "<C-l>",  "core.integrations.telescope.insert_link",      opts = { desc = 'Insert Link' } },
            { "<C-f>n", "core.integrations.telescope.insert_file_link", opts = { desc = 'Insert Neorg File Link' } },
          },
        }, {
          silent = true,
          noremap = true,
        })
      end)
    end,
  },
  { -- Generate table of contents for markdown
    'richardbizik/nvim-toc',
    ft = { 'markdown' },
    config = function()
      require('nvim-toc').setup({})
    end,
  },
  { -- preview markdown with glow
    "ellisonleao/glow.nvim",
    config = true,
    cmd = "Glow",
  },
  { -- preview markdown in browser
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
  },
  { -- add treesitter highlights to markdown code blocks
    'yaocccc/nvim-hl-mdcodeblock.lua',
    dependencies = {'nvim-treesitter/nvim-treesitter'},
    config = function()
      require('hl-mdcodeblock').setup({
        -- option
      })
    end
  },
}
