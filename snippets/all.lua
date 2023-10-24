-- snippets/all.lua

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local c = ls.choice_node
local f = ls.function_node

return {
  s('name', {
    c(1, {
      t("Simon H Moore"),
      t("Simon Hugh Moore"),
      t("Simon Moore"),
      t("Simon M"),
      t("Simon"),
    })
  }),
  s('email', {
    c(1, {
      t("simon@simonhugh.xyz"),
      t("simonm@vigoitsolutions.com"),
    }),
  }),
  s('wemail', { t("simonm@vigoitsolutions.com") }),
  s('sign', {
    c(1, {
      t("Simon H Moore <simon@simonhugh.xyz>"),
      t("Simon H Moore <simonm@vigoitsolutions.com>"),
    }),
  }),
  s('wsign', { t("Simon H Moore <simonm@vigoitsolutions.com>") }),
  s({
      trig = 'date',
      priority = 10000,
      desc = 'Current date'
    },
    {
      c(1, {
        f(function() return os.date "%d %b %Y" end),
        f(function() return os.date "%d %B %Y" end),
        f(function() return os.date "%a %d %b %Y" end),
        f(function() return os.date "%A %d %b %Y" end),
        f(function() return os.date "%a %d %B %Y" end),
        f(function() return os.date "%A %d %B %Y" end),
        f(function() return os.date "%d-%m-%Y" end),
        f(function() return os.date "%d/%m/%Y" end),
        f(function() return os.date "%d-%m-%y" end),
        f(function() return os.date "%d/%m/%y" end),
      })
    }),
  s({
      trig = 'americandate',
      priority = 10000,
      desc = 'Current american date, month comes first',
    },
    {
      c(1, {
        f(function() return os.date "%m/%d/%Y" end),
        f(function() return os.date "%m-%d-%Y" end),
        f(function() return os.date "%m/%d/%y" end),
        f(function() return os.date "%m-%d-%y" end),
      })
    }),
  s({
      trig = 'time',
      priority = 10000,
      desc = 'Current time',
    },
    {
      c(1, {
        f(function() return os.date "%H:%M" end),
        f(function() return os.date "%I:%M %p" end),
        f(function() return os.date "%H:%M:%S" end),
        f(function() return os.date "%I:%M:%S %p" end),
      })
    }),
}
