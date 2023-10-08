-- telescope.lua


-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

local ts = require('telescope.builtin')

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', ts.oldfiles, { desc = 'Find recently opened files' })
vim.keymap.set('n', '<leader>,', ts.buffers, { desc = 'Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  ts.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = 'Fuzzily search in current buffer' })

vim.keymap.set('n', '<leader>gf', ts.git_files, { desc = 'Search Git Files' })
vim.keymap.set('n', '<leader>gs', ts.git_status, { desc = 'Search Git Status' })
vim.keymap.set('n', '<leader>gc', ts.git_commits, { desc = 'Search Git Commits' })
vim.keymap.set('n', '<leader>ff', ts.find_files, { desc = 'Search Files' })
vim.keymap.set('n', '<leader>sh', ts.help_tags, { desc = 'Search Help' })
vim.keymap.set('n', '<leader>sw', ts.grep_string, { desc = 'Search Current Word' })
vim.keymap.set('n', '<leader>sg', ts.live_grep, { desc = 'Search by Grep' })
vim.keymap.set('n', '<leader>sd', ts.diagnostics, { desc = 'Search Diagnostics' })
vim.keymap.set('n', '<leader>sk', ts.keymaps, { desc = 'Search Keymaps' })


vim.keymap.set('n', '<leader>fd', function() ts.find_files({ cwd = '~/Documents' }) end, { desc = 'Find Documents' })
vim.keymap.set('n', '<leader>fp', function() ts.find_files({ cwd = '~/Projects' }) end, { desc = 'Find Projects' })
vim.keymap.set('n', '<leader>fc', function() ts.find_files({ cwd = '~/.config' }) end, { desc = 'Find Config' })
vim.keymap.set('n', '<leader>fb', function() ts.find_files({ cwd = '~/.local/bin' }) end, { desc = 'Find Local Bin' })
