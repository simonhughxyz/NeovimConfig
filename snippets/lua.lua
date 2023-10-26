-- snippets/lua.lua

local ls = require("luasnip")
local s = ls.snippet
local f = ls.function_node
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

return {
  -- auto type require definition
  s('require',
    fmt([[local {} = require("{}")]], { f(function(import_name)
      local parts = vim.split(import_name[1][1], ".", {plain = true})
      return parts[#parts] or ""
    end, { 1 } ), i(1) })
  ),
}
