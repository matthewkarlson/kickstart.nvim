vim.pack.add {
  { src = 'https://github.com/NeogitOrg/neogit', version = vim.version.range '*' },
  'https://github.com/nvim-lua/plenary.nvim',
}

require('neogit').setup {
  graph_style = 'unicode',
  integrations = { diffview = false },
}

vim.keymap.set('n', '<leader>gs', '<cmd>Neogit<CR>', { desc = '[G]it [S]tatus' })

-- Pre-populate commit message with ticket number extracted from branch name
-- (e.g. feature/hk-1234-some-description → [HK-1234] )
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'gitcommit', 'NeogitCommitMessage' },
  callback = function()
    vim.schedule(function()
      local first_line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] or ''
      if first_line ~= '' then
        return
      end

      local branch = vim.fn.system('git branch --show-current 2>/dev/null'):gsub('\n', '')
      local ticket_num = branch:match('[Hh][Kk]%-(%d+)')
      if not ticket_num then
        return
      end

      local prefix = '[HK-' .. ticket_num .. '] '
      vim.api.nvim_buf_set_lines(0, 0, 1, false, { prefix })
      vim.api.nvim_win_set_cursor(0, { 1, #prefix })
    end)
  end,
})

-- Wipe the NeogitConsole buffer when hidden so it's never reused with a stale
-- terminal attached (nvim_open_term fails on a buffer that is already buftype=terminal)
vim.api.nvim_create_autocmd('BufHidden', {
  pattern = 'NeogitConsole',
  callback = function(ev)
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(ev.buf) then
        vim.api.nvim_buf_delete(ev.buf, { force = true })
      end
    end)
  end,
})
