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
    end,
  },
}
