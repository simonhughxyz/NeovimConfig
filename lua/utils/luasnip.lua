-- shm/luasnip.lua

local shm = require("shm")
local utils = require("utils")

local fmt = require("luasnip.extras.fmt").fmt
local ls = require("luasnip")
local c = ls.choice_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

local M = {}

M.get_name_choice = function()
  local nodes = {}
  for _, name in ipairs(shm.name) do
    table.insert(nodes, t(name))
  end
  return c(1, nodes)
end

M.shebang = {
  lua = "!/bin/lua",
  sh = "!/bin/sh",
  bash = "!/bin/bash",
  zsh = "!/bin/zsh",
}

M.get_date_choice = function (arg)
  return c(arg and arg or 1, {
        f(function() return utils.datef("%d%o %B %Y") end),
        f(function() return utils.datef(os.date "%d%o %b %Y") end),
        f(function() return utils.datef(os.date "%a %d%o %b %Y") end),
        f(function() return utils.datef(os.date "%A %d%o %b %Y") end),
        f(function() return utils.datef(os.date "%a %d%o %B %Y") end),
        f(function() return utils.datef(os.date "%A %d%o %B %Y") end),
        f(function() return os.date "%d-%m-%Y" end),
        f(function() return os.date "%d/%m/%Y" end),
        f(function() return os.date "%d-%m-%y" end),
        f(function() return os.date "%d/%m/%y" end),
      })
end

M.get_header = function(opts)
  opts = opts and opts or {}

  local sntable = {
      c = t(opts.commentstr and opts.commentstr or "# "),
      name = c(1, {
          f(function() return vim.fn.expand("%:t") end),
          f(function() return vim.fn.expand("%:h:t") .. "/" .. vim.fn.expand("%:t") end),
          f(function() return vim.fn.expand("%:t:r") end),
        }),
      author = c(2, {t(shm.signiture), t(shm.worksigniture)}),
      date = M.get_date_choice(3),
      desc = i(4, "Description"),
  }

  local formattable = {
      "{c}filename: {name}",
      "{c}author: {author}",
      "{c}date: {date}",
      "{c}desc: {desc}",
  }

  if opts.shebang then
    table.insert(formattable, 1, "{c}{shebang}")
    sntable.shebang = t(opts.shebang)
  end

  return fmt(table.concat(formattable, "\n"), sntable, {dedent = true})
end

return M
