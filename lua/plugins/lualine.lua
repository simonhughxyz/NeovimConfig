-- lualine.lua
--
-- Statusline plugin

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

return {
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
          lualine_c = { "filename" },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { "filename" },
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {},
        },
        tabline = {},
        winbar = {
          lualine_c = { "filename", "navic" },
        },
        inactive_winbar = {
          lualine_c = { "filename" },
        },
        extensions = {},
      }
    end,
  },
}
