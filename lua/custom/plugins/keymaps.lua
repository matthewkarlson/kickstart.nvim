vim.keymap.set('n', '<leader>w', '<Cmd>wa<CR>', { desc = '[W]rite all buffers' })

vim.keymap.set('n', '<leader>sb', function()
  require('telescope.builtin').git_branches {
    show_remote_tracking_branches = false,
    sort_lastused = true,
  }
end, { desc = '[G]it [S]witch [B]ranch' })

vim.keymap.set('n', '<leader>gb', function()
  vim.ui.input({ prompt = 'New branch name: ' }, function(branch_name)
    if not branch_name or branch_name == '' then return end
    local result = vim.fn.system('git checkout -b ' .. vim.fn.shellescape(branch_name))
    if vim.v.shell_error ~= 0 then
      vim.notify('git checkout -b failed: ' .. result, vim.log.levels.ERROR)
    else
      vim.notify('Switched to new branch: ' .. branch_name, vim.log.levels.INFO)
    end
  end)
end, { desc = '[G]it new [B]ranch' })

vim.keymap.set('n', '<leader>sa', function()
  require('telescope.builtin').find_files {
    prompt_title = 'Branch Files (vs staging)',
    find_command = { 'git', 'diff', 'staging...HEAD', '--name-only' },
  }
end, { desc = '[S]earch [A]ctive files (diff vs staging)' })

vim.keymap.set('n', '<leader>yd', function()
  local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line '.' - 1 })
  if #diagnostics == 0 then
    vim.notify('No diagnostics on this line', vim.log.levels.INFO)
    return
  end
  local messages = vim.tbl_map(function(d) return d.message end, diagnostics)
  local text = table.concat(messages, '\n')
  vim.fn.setreg('+', text)
  vim.notify('Copied: ' .. text, vim.log.levels.INFO)
end, { desc = '[Y]ank [D]iagnostic message' })
