-- Pitch Black: VSCode Dark+ syntax on a pure black background
-- Matches https://github.com/viktorqvarfordt/vscode-pitch-black-theme
vim.pack.add { 'https://github.com/Mofiqul/vscode.nvim' }

require('vscode').setup {
  style = 'dark',
  italic_comments = false,
  color_overrides = {
    -- Pure black everywhere (matching Pitch Black theme's #000 backgrounds)
    vscBack = '#000000',
    vscTabCurrent = '#000000',
    vscTabOther = '#000000',
    vscTabOutside = '#000000',
    vscLeftDark = '#000000',
    vscLeftMid = '#000000',
    -- Slight lift for popups so they remain visible against pure black
    vscPopupBack = '#1a1a1a',
  },
}

vim.cmd.colorscheme 'vscode'
