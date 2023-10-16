-- filetype.lua
--
-- Fileype specific plugins

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
    },
    config = function()
      require("neorg").setup {
        load = {
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
                health = "~/Documents/health",
                career = "~/Documents/career",
              },
              default_workspace = "documents",
            },
          },
          ["core.completion"] = {
            config = {
              engine = 'nvim-cmp',
            }
          },
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
              workspace = "home",
              strategy = "nested",
            }
          },
          ["core.summary"] = {},
          ["core.esupports.hop"] = {},
        },
      }

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
}
