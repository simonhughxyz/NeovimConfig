-- snippets/all.lua

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local c = ls.choice_node
local f = ls.function_node

local shm = require("shm")
local lls = require("shm.luasnip")

return {
  s({
      trig = 'name',
      priority = 10000,
      desc = 'My name'
    },
    { lls.get_name_choice()
    }),
  s({
      trig = 'email',
      priority = 10000,
      desc = 'My email'
    },
    {
      c(1, {
        t("simon@simonhugh.xyz"),
        t("simonm@vigoitsolutions.com"),
      }),
    }),
  s({
      trig = 'workemail',
      priority = 10000,
      desc = 'Work Email'
    },
    {
      t(shm.workemail)
    }),
  s({
      trig = 'sign',
      priority = 10000,
      desc = 'My signiture'
    },
    {
      c(1, {
        t(shm.signiture),
        t(shm.worksigniture),
      }),
    }),
  s({
      trig = 'worksign',
      priority = 10000,
      desc = 'Work Sign'
    },
    {
      t("Simon H Moore <simonm@vigoitsolutions.com>")
    }),
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
