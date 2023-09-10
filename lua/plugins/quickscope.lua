-- quickscope.lua
--
-- Show character highlights to help navigate

return {
  "unblevable/quick-scope",
  priority = 11000, -- needs to load before ColorScheme
  config = function()
    vim.cmd([[
            augroup qs_colors
              autocmd!
              autocmd ColorScheme * highlight QuickScopePrimary guifg='#aa00aa' gui=underline ctermfg=155 cterm=underline
              autocmd ColorScheme * highlight QuickScopeSecondary guifg='#a0f050' gui=underline ctermfg=81 cterm=underline
            augroup END
           ]])
    vim.keymap.set("n", "<leader>cq", "<cmd>QuickScopeToggle<cr>", { desc = "Toggle quick scope" })
  end,
}
