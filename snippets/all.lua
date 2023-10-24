-- snippets/all.lua

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local c = ls.choice_node

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
}
