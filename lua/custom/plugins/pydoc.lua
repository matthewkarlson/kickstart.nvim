-- `K` (LSP hover) reads pyright's typeshed stubs, which strip docstrings from
-- stdlib/builtin types (e.g. `defaultdict`) since they're just type signatures.
-- This shells out to Python's own `pydoc`, replaying the buffer's imports so
-- it can resolve the real, runtime docstring instead.
local function pydoc_hover()
  local expr = vim.fn.expand '<cexpr>'
  if expr == '' then return end

  local imports = {}
  local buf_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local line_index = 1
  while line_index <= #buf_lines do
    local line = buf_lines[line_index]
    if line:match '^%s*import%s' or line:match '^%s*from%s+%S+%s+import%s' then
      local statement = { line }
      local _, open_count = line:gsub('%(', '')
      local _, close_count = line:gsub('%)', '')
      while open_count > close_count and line_index < #buf_lines do
        line_index = line_index + 1
        local continuation = buf_lines[line_index]
        table.insert(statement, continuation)
        local _, more_open = continuation:gsub('%(', '')
        local _, more_close = continuation:gsub('%)', '')
        open_count = open_count + more_open
        close_count = close_count + more_close
      end
      table.insert(imports, table.concat(statement, '\n'))
    end
    line_index = line_index + 1
  end

  local cwd = vim.fn.getcwd()

  -- Importing Django app code (serializers, models) triggers Django's lazy
  -- settings/app-registry on import — django.setup() must run first, from the
  -- directory containing manage.py, or imports like djmoney's MoneyField fail.
  local django_setup = ''
  local run_cwd = cwd
  local env = nil
  local manage_py = nil
  for _, candidate in ipairs { cwd .. '/manage.py', cwd .. '/housekeep/manage.py' } do
    if vim.fn.filereadable(candidate) == 1 then
      manage_py = candidate
      break
    end
  end
  if manage_py and vim.fn.filereadable(manage_py) == 1 then
    run_cwd = vim.fn.fnamemodify(manage_py, ':h')
    env = { DJANGO_SETTINGS_MODULE = vim.env.DJANGO_SETTINGS_MODULE or 'housekeep.settings.dev.matt' }
    django_setup = 'import django\ntry:\n    django.setup()\nexcept Exception:\n    pass\n'
  end

  local script = django_setup
    .. table.concat(imports, '\n')
    .. '\n'
    .. string.format(
      [[
import pydoc, sys
try:
    pydoc.doc(%s, output=sys.stdout)
except Exception as e:
    print('No documentation found for %s: ' + str(e))
]],
      expr,
      expr
    )

  local cmd = vim.fn.filereadable(cwd .. '/pyproject.toml') == 1 and { 'uv', 'run', 'python3', '-c', script } or { 'python3', '-c', script }

  vim.system(cmd, { cwd = run_cwd, env = env, text = true }, function(result)
    vim.schedule(function()
      local output = result.stdout ~= '' and result.stdout or (result.stderr ~= '' and result.stderr or ('No documentation found for ' .. expr))

      local buf = vim.api.nvim_create_buf(false, true)
      vim.bo[buf].buftype = 'nofile'
      vim.bo[buf].filetype = 'python'
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(output, '\n'))

      local width = math.min(100, vim.o.columns - 4)
      local height = math.min(30, vim.o.lines - 4)
      local win = vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = width,
        height = height,
        row = math.floor((vim.o.lines - height) / 2),
        col = math.floor((vim.o.columns - width) / 2),
        style = 'minimal',
        border = 'rounded',
        title = ' pydoc: ' .. expr .. ' ',
      })
      vim.wo[win].wrap = true
      vim.keymap.set('n', 'q', '<cmd>close<CR>', { buffer = buf })
      vim.keymap.set('n', '<Esc>', '<cmd>close<CR>', { buffer = buf })
    end)
  end)
end

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'python',
  callback = function(event) vim.keymap.set('n', '<leader>K', pydoc_hover, { buffer = event.buf, desc = 'Python: real pydoc for word under cursor' }) end,
})
