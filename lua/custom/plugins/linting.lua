-- Override nvim-lint linters for the housekeep project
local lint = require 'lint'

lint.linters_by_ft = {
  python = { 'flake8' },
}

-- Run flake8 through uv so it uses the project's own venv and config
local flake8 = require('lint').linters.flake8
flake8.cmd = 'uv'
table.insert(flake8.args, 1, 'flake8')
table.insert(flake8.args, 1, 'run')

-- Only run eslint when a project-local binary exists
local eslint_group = vim.api.nvim_create_augroup('eslint_local', { clear = true })
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
  group = eslint_group,
  pattern = { '*.js', '*.ts', '*.jsx', '*.tsx' },
  callback = function()
    if not vim.bo.modifiable then return end
    local found = vim.fn.findfile('node_modules/.bin/eslint', vim.fn.getcwd() .. ';')
    if found == '' then return end
    lint.linters.eslint.cmd = vim.fn.fnamemodify(found, ':p')
    lint.try_lint { 'eslint' }
  end,
})
