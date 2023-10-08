-- neorg.lua

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
