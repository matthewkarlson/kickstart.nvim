-- gh-review.nvim: PR review with editable diff buffers
-- https://github.com/gh-tui-tools/gh-review.nvim
--
-- Workflow:
--   <leader>or  - open PR for current branch (or :GHReview <number>)
--   <leader>os  - start a pending review
--   <leader>oS  - submit the review
--   <leader>of  - toggle changed files panel
--   <leader>od  - discard pending review
--   <leader>ox  - close review
--   In diff buffers: edit freely, :w saves to working tree
--   gc           - add comment on current line
--   ]t / [t      - jump between threads

vim.pack.add { 'https://github.com/gh-tui-tools/gh-review.nvim' }

require('which-key').add {
  { '<leader>o', group = '[O]cto/GH Review' },
  -- gh-review diff buffer keys (buffer-local, registered here for discoverability)
  { ']t',  desc = 'Next review thread',     mode = 'n' },
  { '[t',  desc = 'Prev review thread',     mode = 'n' },
  { 'gt',  desc = 'Open thread at cursor',  mode = 'n' },
  { 'K',   desc = 'Preview thread',         mode = 'n' },
  { 'gc',  desc = 'New review comment',     mode = { 'n', 'x' } },
  { 'gs',  desc = 'New suggestion',         mode = { 'n', 'x' } },
  { 'gf',  desc = 'Toggle files panel',     mode = 'n' },
  { 'gF',  desc = 'Go to file',             mode = 'n' },
}

vim.keymap.set('n', '<leader>or', '<Cmd>GHReview<CR>',      { desc = '[O]pen PR [R]eview' })
vim.keymap.set('n', '<leader>os', '<Cmd>GHReviewStart<CR>', { desc = '[O]pen review [S]tart' })
vim.keymap.set('n', '<leader>oS', '<Cmd>GHReviewSubmit<CR>',{ desc = '[O]pen review [S]ubmit' })
vim.keymap.set('n', '<leader>of', '<Cmd>GHReviewFiles<CR>', { desc = '[O]pen review [F]iles' })
vim.keymap.set('n', '<leader>od', '<Cmd>GHReviewDiscard<CR>',{ desc = '[O]pen review [D]iscard' })
vim.keymap.set('n', '<leader>ox', '<Cmd>GHReviewClose<CR>', { desc = '[O]pen review [X]close' })
