-- nvim-tree: file explorer panel
-- https://github.com/nvim-tree/nvim-tree.lua

local plugins = { 'https://github.com/nvim-tree/nvim-tree.lua' }

if vim.g.have_nerd_font then
  table.insert(plugins, 'https://github.com/nvim-tree/nvim-web-devicons')
end

vim.pack.add(plugins)

require('nvim-tree').setup {
  view = {
    side = 'left',
    width = 35,
  },
  renderer = {
    icons = {
      show = {
        file = vim.g.have_nerd_font,
        folder = vim.g.have_nerd_font,
        folder_arrow = vim.g.have_nerd_font,
        git = vim.g.have_nerd_font,
      },
    },
  },
  filters = {
    dotfiles = false,
  },
}

vim.keymap.set('n', '<leader>e', '<Cmd>NvimTreeToggle<CR>', { desc = 'Toggle file [E]xplorer' })
vim.keymap.set('n', '<leader>E', '<Cmd>NvimTreeFindFile<CR>', { desc = 'Reveal file in [E]xplorer' })
