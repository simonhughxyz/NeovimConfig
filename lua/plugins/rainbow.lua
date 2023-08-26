-- rainbow.lua 
--
-- use different colors for matching brackets

return {
  "p00f/nvim-ts-rainbow",
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
}
