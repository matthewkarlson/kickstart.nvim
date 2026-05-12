vim.pack.add { 'https://github.com/Vigemus/iron.nvim' }

local iron = require 'iron.core'

iron.setup {
  config = {
    scratch_repl = true,
    repl_definition = {
      python = {
        command = function()
          local ipython_args = { '--no-autoindent', '--ext', 'autoreload', '--InteractiveShellApp.exec_lines=%autoreload 2' }
          local cwd = vim.fn.getcwd()
          if vim.fn.filereadable(cwd .. '/housekeep/manage.py') == 1 then
            return vim.list_extend({ 'uv', 'run', 'housekeep/manage.py', 'shell_plus', '--ipython', '--' }, ipython_args)
          end
          local venv = vim.env.VIRTUAL_ENV or vim.env.CONDA_PREFIX
          if venv then
            return vim.list_extend({ venv .. '/bin/ipython' }, ipython_args)
          end
          return vim.list_extend({ 'ipython' }, ipython_args)
        end,
        format = require('iron.fts.common').bracketed_paste,
      },
    },
    repl_open_cmd = require('iron.view').split.vertical.botright(0.4),
  },
  keymaps = {
    send_motion = '<leader>rc',
    visual_send = '<leader>rc',
    send_line = '<leader>rl',
    send_paragraph = '<leader>rp',
    send_until_cursor = '<leader>ru',
    cr = '<leader>r<cr>',
    interrupt = '<leader>r<space>',
    exit = '<leader>rq',
    clear = '<leader>rx',
  },
  highlight = { italic = true },
  ignore_blank_lines = true,
}

vim.keymap.set('n', '<leader>rs', '<cmd>IronRepl python<cr>', { desc = 'REPL: open' })
vim.keymap.set('n', '<leader>rr', '<cmd>IronRestart<cr>', { desc = 'REPL: restart' })
vim.keymap.set('n', '<leader>rh', '<cmd>IronHide<cr>', { desc = 'REPL: hide' })
vim.keymap.set('n', '<leader>rf', '<cmd>IronFocus<cr>', { desc = 'REPL: focus' })
vim.keymap.set('n', '<leader>rF', function()
  local file = vim.fn.expand '%:p'
  require('iron.core').send('python', string.format('%%run %s', file))
end, { desc = 'REPL: run file via %run' })

-- Send visual selection or whole file via temp file + %run (avoids paste indentation issues)
local function run_via_tempfile(lines)
  local tmp = vim.fn.tempname() .. '.py'
  vim.fn.writefile(lines, tmp)
  require('iron.core').send('python', string.format('%%run %s', tmp))
end

vim.keymap.set('v', '<leader>rC', function()
  local start = vim.fn.line "'<"
  local finish = vim.fn.line "'>"
  local lines = vim.api.nvim_buf_get_lines(0, start - 1, finish, false)
  run_via_tempfile(lines)
end, { desc = 'REPL: run selection via tempfile %run' })
