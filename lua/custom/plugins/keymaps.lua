vim.keymap.set('n', '<leader>w', '<Cmd>wa<CR>', { desc = '[W]rite all buffers' })

-- Quickfix navigation. Telescope's `<C-q>` (all results) and `<M-q>` (selected
-- results) fill the list; these walk it.
vim.keymap.set('n', ']q', '<Cmd>cnext<CR>zz', { desc = 'Next [Q]uickfix item' })
vim.keymap.set('n', '[q', '<Cmd>cprev<CR>zz', { desc = 'Prev [Q]uickfix item' })

-- Shadows the `<C-v>` alias for blockwise visual, which `<C-v>` itself still covers.
vim.keymap.set('n', '<C-q>', function()
  -- `<leader>q` fills the location list, which also reports buftype 'quickfix',
  -- so match on the window's loclist flag rather than the buffer's type.
  local is_open = vim.iter(vim.fn.getwininfo()):any(
    function(win) return win.quickfix == 1 and win.loclist == 0 and win.tabnr == vim.fn.tabpagenr() end
  )
  vim.cmd(is_open and 'cclose' or 'copen')
end, { desc = 'Toggle [Q]uickfix list' })

vim.keymap.set('n', '<leader>sm', function() require('telescope.builtin').marks() end, { desc = '[S]earch [M]arks' })

vim.keymap.set('n', '<leader>sb', function()
  require('telescope.builtin').git_branches {
    show_remote_tracking_branches = false,
    sort_lastused = true,
  }
end, { desc = '[G]it [S]witch [B]ranch' })

vim.keymap.set('n', '<leader>sB', function()
  require('telescope.builtin').git_branches {
    show_remote_tracking_branches = true,
    sort_lastused = true,
  }
end, { desc = '[G]it [S]witch [B]ranch (includes remote origin)' })

vim.keymap.set('n', '<leader>gb', function()
  vim.ui.input({ prompt = 'New branch name: ' }, function(branch_name)
    if not branch_name or branch_name == '' then return end
    local result = vim.fn.system('git checkout -b ' .. vim.fn.shellescape(branch_name))
    if vim.v.shell_error ~= 0 then
      vim.notify('git checkout -b failed: ' .. result, vim.log.levels.ERROR)
    else
      vim.notify('Switched to new branch: ' .. branch_name, vim.log.levels.INFO)
    end
  end)
end, { desc = '[G]it new [B]ranch' })

vim.keymap.set('n', '<leader>sa', function()
  local pickers = require 'telescope.pickers'
  local finders = require 'telescope.finders'
  local conf = require('telescope.config').values
  local previewers = require 'telescope.previewers'
  local putils = require 'telescope.previewers.utils'
  local make_entry = require 'telescope.make_entry'

  local files_str = vim.fn.system(
    '(git diff --name-only origin/staging...HEAD; git diff --name-only HEAD; git diff --cached --name-only; git ls-files --others --exclude-standard) | sort -u'
  )
  local files = vim.tbl_filter(
    function(f) return f ~= '' end,
    vim.split(vim.trim(files_str), '\n', { plain = true })
  )

  local diff_previewer = previewers.new_buffer_previewer {
    title = 'Diff vs staging',
    define_preview = function(self, entry)
      local function show_diff(bufnr, cmd)
        putils.job_maker(cmd, bufnr, {
          callback = function(b)
            vim.bo[b].filetype = 'diff'
            vim.schedule(function()
              if not vim.api.nvim_win_is_valid(self.state.winid) then return end
              local lines = vim.api.nvim_buf_get_lines(b, 0, -1, false)
              for i, line in ipairs(lines) do
                if line:match '^@@' then
                  vim.api.nvim_win_set_cursor(self.state.winid, { i, 0 })
                  break
                end
              end
              -- If no diff output, file is untracked — show it as a new-file diff
              if #lines == 0 or (#lines == 1 and lines[1] == '') then
                show_diff(b, { 'git', 'diff', '--no-index', '/dev/null', entry.value })
              end
            end)
          end,
        })
      end
      show_diff(self.state.bufnr, { 'git', 'diff', 'origin/staging', '--', entry.value })
    end,
  }

  pickers.new({}, {
    prompt_title = 'Branch Files (vs staging)',
    finder = finders.new_table {
      results = files,
      entry_maker = make_entry.gen_from_file(),
    },
    sorter = conf.file_sorter {},
    previewer = diff_previewer,
  }):find()
end, { desc = '[S]earch [A]ctive files (diff vs staging)' })

vim.keymap.set('n', '<leader>yd', function()
  local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line '.' - 1 })
  if #diagnostics == 0 then
    vim.notify('No diagnostics on this line', vim.log.levels.INFO)
    return
  end
  local messages = vim.tbl_map(function(d) return d.message end, diagnostics)
  local text = table.concat(messages, '\n')
  vim.fn.setreg('+', text)
  vim.notify('Copied: ' .. text, vim.log.levels.INFO)
end, { desc = '[Y]ank [D]iagnostic message' })
