-- git.lua
--
-- git related plugins

return {
  -- Git plugin
  {
    'tpope/vim-fugitive',
    enabled = true,
  },

  { -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    enabled = true,
    opts = {
      -- See `:help gitsigns.txt`
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        vim.keymap.set('n', '[h', gs.prev_hunk, { buffer = bufnr, desc = 'Go to Previous Hunk' })
        vim.keymap.set('n', ']h', gs.next_hunk, { buffer = bufnr, desc = 'Go to Next Hunk' })
        vim.keymap.set('n', '<leader>hs', gs.stage_hunk, { buffer = bufnr, desc = 'Git Stage Hunk' })
        vim.keymap.set('n', '<leader>hS', gs.stage_buffer, { buffer = bufnr, desc = 'Git Stage Entire Buffer' })
        vim.keymap.set('n', '<leader>hr', gs.reset_hunk, { buffer = bufnr, desc = 'Git Reset Hunk' })
        vim.keymap.set('n', '<leader>hR', gs.reset_buffer, { buffer = bufnr, desc = 'Git Reset Entire Buffer' })
        vim.keymap.set('v', '<leader>hs', function() gs.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end,
          { buffer = bufnr, desc = 'Git Stage Selected Hunk' })

        vim.keymap.set('v', '<leader>gr', function() gs.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end,
          { buffer = bufnr, desc = 'Git Reset Selected Hunk' })

        vim.keymap.set('n', '<leader>hu', gs.undo_stage_hunk, { buffer = bufnr, desc = 'Git Undo Stage Hunk' })
        vim.keymap.set('n', '<leader>ht', gs.toggle_deleted, { buffer = bufnr, desc = 'Git Toggle Deleted' })
        vim.keymap.set('n', '<leader>hd', gs.diffthis, { buffer = bufnr, desc = 'Git Diff Hunk' })
        vim.keymap.set('n', '<leader>hD', function() gs.diffthis('~') end, { buffer = bufnr, desc = 'Git Diff Hunk' })
        vim.keymap.set('n', '<leader>hp', gs.preview_hunk, { buffer = bufnr, desc = 'Git Preview Hunk' })
        vim.keymap.set('n', '<leader>hb', gs.blame_line, { buffer = bufnr, desc = 'Git Blame Line' })
        vim.keymap.set('n', '<leader>hB', gs.toggle_current_line_blame,
          { buffer = bufnr, desc = 'Git Blame Line Toggle' })

        -- Text object
        vim.keymap.set({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'Hunk' })
        vim.keymap.set({ 'o', 'x' }, 'ah', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'Hunk' })
      end,
    },
  },
}
