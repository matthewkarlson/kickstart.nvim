local function get_visual_selection()
  local _, srow, scol = unpack(vim.fn.getpos "'<")
  local _, erow, ecol = unpack(vim.fn.getpos "'>")
  local lines = vim.api.nvim_buf_get_lines(0, srow - 1, erow, false)
  if #lines == 0 then return '' end
  lines[#lines] = lines[#lines]:sub(1, ecol)
  lines[1] = lines[1]:sub(scol)
  return table.concat(lines, '\n')
end

local function show_in_float(lines)
  local width = math.min(90, vim.o.columns - 4)
  local height = math.min(#lines + 2, vim.o.lines - 4)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].filetype = 'markdown'
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = 'minimal',
    border = 'rounded',
    title = ' Claude: Explain ',
    title_pos = 'center',
  })
  vim.wo[win].wrap = true
  vim.keymap.set('n', 'q', '<cmd>close<CR>', { buffer = buf, silent = true })
  vim.keymap.set('n', '<Esc>', '<cmd>close<CR>', { buffer = buf, silent = true })
end

local function explain_selection()
  local selection = get_visual_selection()
  if selection == '' then
    vim.notify('No text selected', vim.log.levels.WARN)
    return
  end

  local prompt = 'Explain this code in a concise and clear way:\n\n' .. selection
  vim.notify('Asking Claude...', vim.log.levels.INFO)

  vim.system(
    { 'claude', '-p', prompt, '--model', 'haiku' },
    { text = true },
    vim.schedule_wrap(function(result)
      if result.code ~= 0 then
        vim.notify('Claude error: ' .. (result.stderr or 'unknown error'), vim.log.levels.ERROR)
        return
      end
      local lines = vim.split(result.stdout, '\n', { plain = true })
      show_in_float(lines)
    end)
  )
end

vim.keymap.set('v', '<leader>ce', explain_selection, { desc = '[C]laude [E]xplain selection' })
