-- gitsigns.lua


return {
  -- Adds git related signs to the gutter, as well as utilities for managing changes
  'lewis6991/gitsigns.nvim',
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
      vim.keymap.set('n', '[h', gs.prev_hunk, { buffer = bufnr, desc = '[G]o to [P]revious Hunk' })
      vim.keymap.set('n', ']h', gs.next_hunk, { buffer = bufnr, desc = '[G]o to [N]ext Hunk' })
      vim.keymap.set('n', '<leader>gs', gs.stage_hunk, { buffer = bufnr, desc = '[G]it [S]tage Hunk' })
      vim.keymap.set('n', '<leader>gS', gs.stage_buffer, { buffer = bufnr, desc = '[G]it [S]tage Entire Buffer' })
      vim.keymap.set('n', '<leader>gr', gs.reset_hunk, { buffer = bufnr, desc = '[G]it [R]eset Hunk' })
      vim.keymap.set('n', '<leader>gR', gs.reset_buffer, { buffer = bufnr, desc = '[G]it [R]eset Entire Buffer' })
      vim.keymap.set('v', '<leader>gs', function() gs.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end,
        { buffer = bufnr, desc = '[G]it [S]tage Selected Hunk' })

      vim.keymap.set('v', '<leader>gr', function() gs.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end,
        { buffer = bufnr, desc = '[G]it [R]eset Selected Hunk' })
      
      vim.keymap.set('n', '<leader>gu', gs.undo_stage_hunk, { buffer = bufnr, desc = '[G]it [U]ndo Stage Hunk' })
      vim.keymap.set('n', '<leader>gt', gs.toggle_deleted, { buffer = bufnr, desc = '[G]it [T]oggle Deleted' })
      vim.keymap.set('n', '<leader>gd', gs.diffthis, { buffer = bufnr, desc = '[G]it [D]iff Hunk' })
      vim.keymap.set('n', '<leader>gD', function() gs.diffthis('~') end, { buffer = bufnr, desc = '[G]it [D]iff Hunk' })
      vim.keymap.set('n', '<leader>gp', gs.preview_hunk, { buffer = bufnr, desc = '[G]it [P]review Hunk' })
      vim.keymap.set('n', '<leader>gb', gs.blame_line, { buffer = bufnr, desc = '[G]it [B]lame Line' })
      vim.keymap.set('n', '<leader>gB', gs.toggle_current_line_blame, { buffer = bufnr, desc = '[G]it [B]lame Line Toggle' })

      -- Text object
      vim.keymap.set({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'Hunk' })
      vim.keymap.set({'o', 'x'}, 'ah', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'Hunk' })
    end,
  },
}
