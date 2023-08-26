-- colorizer.lua
--
-- Highlight colors

return {
  "norcalli/nvim-colorizer.lua",
  enabled = true,
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
}
