vim.keymap.set('n', '<leader>w', '<Cmd>wa<CR>', { desc = '[W]rite all buffers' })

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
