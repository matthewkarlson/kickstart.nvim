local state = { buf = nil, win = nil }

local function dismiss()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_close(state.win, false)
    state.win = nil
  end
end

local function create_buf()
  local buf = vim.api.nvim_create_buf(false, true)
  local cwd = vim.fn.getcwd()
  vim.api.nvim_buf_call(buf, function()
    vim.fn.termopen('claude', {
      cwd = cwd,
      on_exit = function()
        state.buf = nil
        state.win = nil
      end,
    })
  end)
  vim.api.nvim_buf_set_name(buf, 'claude-code-terminal')
  local opts = { buffer = buf, silent = true }
  -- Single-key dismiss from terminal mode: nvim owns <C-\><C-n> before Claude sees it
  vim.keymap.set('t', '<C-\\><C-n>', dismiss, opts)
  -- Fallback if already in normal mode
  vim.keymap.set('n', 'q', dismiss, opts)
  vim.keymap.set('n', '<Esc>', dismiss, opts)
  return buf
end

local function toggle_claude()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    dismiss()
    return
  end

  if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) then
    state.buf = create_buf()
  end

  local width = math.floor(vim.o.columns * 0.88)
  local height = math.floor(vim.o.lines * 0.88)
  state.win = vim.api.nvim_open_win(state.buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = 'minimal',
    border = 'rounded',
    title = ' Claude Code ',
    title_pos = 'center',
  })
  vim.schedule(function()
    if state.win and vim.api.nvim_win_is_valid(state.win) then
      vim.api.nvim_set_current_win(state.win)
      vim.api.nvim_chan_send(vim.bo[state.buf].channel, '')
      vim.cmd 'startinsert'
    end
  end)
end

local function get_visual_selection()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local lines = vim.api.nvim_buf_get_lines(0, start_pos[2] - 1, end_pos[2], false)
  if #lines == 0 then return '' end
  local end_col = math.min(end_pos[3], #lines[#lines])
  if #lines == 1 then
    lines[1] = lines[1]:sub(start_pos[3], end_col)
  else
    lines[1] = lines[1]:sub(start_pos[3])
    lines[#lines] = lines[#lines]:sub(1, end_col)
  end
  return table.concat(lines, '\n')
end

vim.keymap.set('n', '<leader>cc', toggle_claude, { desc = '[C]laude [C]ode toggle' })

vim.keymap.set('v', '<leader>cc', function()
  local text = get_visual_selection()
  if not state.win or not vim.api.nvim_win_is_valid(state.win) then
    toggle_claude()
  end
  vim.schedule(function()
    if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
      vim.api.nvim_chan_send(vim.bo[state.buf].channel, text)
    end
  end)
end, { desc = '[C]laude [C]ode send selection' })
