-- snippets/lua.lua

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local f = ls.function_node
local i = ls.insert_node
local c = ls.choice_node
local d = ls.dynamic_node
local sn = ls.snippet_node
local fmt = require("luasnip.extras.fmt").fmt

return {
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
    }),
}
