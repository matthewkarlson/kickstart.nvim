-- `version` pins the branch: the repo's default branch is the deprecated
-- harpoon 1, and harpoon 2 has an entirely different API.
vim.pack.add {
  { src = 'https://github.com/ThePrimeagen/harpoon', version = 'harpoon2' },
  'https://github.com/nvim-lua/plenary.nvim',
}

local harpoon = require 'harpoon'

harpoon:setup()

vim.keymap.set('n', '<leader>a', function() harpoon:list():add() end, { desc = 'H[a]rpoon file' })
vim.keymap.set('n', '<C-e>', function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = 'Harpoon quick menu' })

for slot = 1, 4 do
  vim.keymap.set('n', '<leader>' .. slot, function() harpoon:list():select(slot) end, { desc = 'Harpoon file ' .. slot })
end

vim.keymap.set('n', ']h', function() harpoon:list():next() end, { desc = 'Next [H]arpoon file' })
vim.keymap.set('n', '[h', function() harpoon:list():prev() end, { desc = 'Prev [H]arpoon file' })
