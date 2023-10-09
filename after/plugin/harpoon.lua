-- after/harpoon.lua

-- enable telescope extension
require("telescope").load_extension('harpoon')

-- set keymaps
vim.keymap.set('n', '<leader>Ha', require('harpoon.mark').add_file, { desc = 'Harpoon Add File' })
vim.keymap.set('n', '<leader>H]', require('harpoon.ui').nav_next, { desc = 'Harpoon Next' })
vim.keymap.set('n', '<leader>H[', require('harpoon.ui').nav_prev, { desc = 'Harpoon Previous' })
vim.keymap.set("n", "<leader>fh", ':Telescope harpoon marks<cr>', { desc = "Find Harpoon" })
