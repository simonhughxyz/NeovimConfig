-- shm/luasnip.lua

local shm = require("shm")

local ls = require("luasnip")
local c = ls.choice_node
local t = ls.text_node

local M = {}

M.get_name_choice = function()
  local nodes = {}
  for _, name in ipairs(shm.name) do
    table.insert(nodes, t(name))
  end
  return c(1, nodes)
end

return M
