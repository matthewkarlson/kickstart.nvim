-- Override nvim-lint linters for the housekeep project
local lint = require 'lint'

lint.linters_by_ft = {
  python = { 'flake8' },
  javascript = { 'eslint' },
  typescript = { 'eslint' },
  javascriptreact = { 'eslint' },
  typescriptreact = { 'eslint' },
}

-- Run flake8 through uv so it uses the project's own venv and config
local flake8 = require('lint').linters.flake8
flake8.cmd = 'uv'
table.insert(flake8.args, 1, 'flake8')
table.insert(flake8.args, 1, 'run')
