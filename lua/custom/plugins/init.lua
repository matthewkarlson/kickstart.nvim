-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
-- Indent current line repeatedly in normal mode
vim.keymap.set('n', '>', '>>_', { noremap = true, silent = true })
vim.keymap.set('n', '<', '<<_', { noremap = true, silent = true })

-- Indent selected lines repeatedly in visual mode
vim.keymap.set('v', '>', '>gv', { noremap = true, silent = true })
vim.keymap.set('v', '<', '<gv', { noremap = true, silent = true })

vim.keymap.set('n', '<leader>w', ':w<CR>', { noremap = true, silent = true })
vim.diagnostic.config {
  virtual_text = false, -- Disable inline diagnostics
  signs = true, -- Keep signs in the gutter
  underline = true, -- Underline the error
  update_in_insert = false,
  float = {
    border = 'rounded', -- Add a rounded border for aesthetics
    focusable = false,
    header = '',
    prefix = '',
  },
}
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostics in a floating window' })

return {}
