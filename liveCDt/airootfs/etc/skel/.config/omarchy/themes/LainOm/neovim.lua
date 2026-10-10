-- Neovim Theme - Anime Pink
-- Tema per editor basato sui colori anime rosa/magenta

vim.cmd('hi clear')
vim.cmd('syntax reset')
vim.g.colors_name = 'anime_pink'

-- Palette colori estratta dall'immagine
local colors = {
    -- Colori base
    bg = '#0a0a0a',           -- Nero profondo
    fg = '#ffeef7',           -- Rosa molto chiaro
    bg_alt = '#1a1a1a',       -- Nero alternativo
    fg_alt = '#ffb3e6',       -- Rosa alternativo
    
    -- Colori principali
    pink = '#e91e63',         -- Rosa magenta principale
    bright_pink = '#ff4081',  -- Rosa brillante
    light_pink = '#ff99cc',   -- Rosa chiaro
    salmon = '#ff85a2',       -- Rosa salmone
    pale_pink = '#ffb3e6',    -- Rosa pallido
    deep_pink = '#d147a3',    -- Rosa profondo
    blush = '#ff6b9d',        -- Rosa intenso
    
    -- Grigi
    gray = '#424242',         -- Grigio medio
    dark_gray = '#2a2a2a',    -- Grigio scuro
    light_gray = '#686868',   -- Grigio chiaro
    
    -- Colori di supporto
    white = '#ffffff',        -- Bianco puro
    black = '#000000',        -- Nero puro
    transparent = 'NONE',     -- Trasparente
}

-- Funzione helper per definire highlight
local function hi(group, opts)
    local cmd = 'hi ' .. group
    if opts.fg then cmd = cmd .. ' guifg=' .. opts.fg end
    if opts.bg then cmd = cmd .. ' guibg=' .. opts.bg end
    if opts.style then cmd = cmd .. ' gui=' .. opts.style end
    if opts.sp then cmd = cmd .. ' guisp=' .. opts.sp end
    vim.cmd(cmd)
end

-- === HIGHLIGHTS BASE ===

-- Editor
hi('Normal', { fg = colors.fg, bg = colors.bg })
hi('NormalFloat', { fg = colors.fg, bg = colors.bg_alt })
hi('NormalNC', { fg = colors.fg_alt, bg = colors.bg })

-- Cursore e selezioni
hi('Cursor', { fg = colors.bg, bg = colors.bright_pink })
hi('CursorLine', { bg = colors.dark_gray })
hi('CursorColumn', { bg = colors.dark_gray })
hi('Visual', { bg = colors.deep_pink, fg = colors.white })
hi('VisualNOS', { bg = colors.deep_pink })

-- Linee e numeri
hi('LineNr', { fg = colors.light_gray })
hi('CursorLineNr', { fg = colors.bright_pink, style = 'bold' })
hi('SignColumn', { fg = colors.light_gray, bg = colors.bg })
hi('FoldColumn', { fg = colors.light_gray, bg = colors.bg })

-- Ricerca
hi('Search', { bg = colors.pink, fg = colors.white })
hi('IncSearch', { bg = colors.bright_pink, fg = colors.black })
hi('Substitute', { bg = colors.salmon, fg = colors.black })

-- Messaggi
hi('ErrorMsg', { fg = colors.blush, style = 'bold' })
hi('WarningMsg', { fg = colors.light_pink, style = 'bold' })
hi('ModeMsg', { fg = colors.bright_pink, style = 'bold' })
hi('MoreMsg', { fg = colors.pale_pink })

-- === SYNTAX HIGHLIGHTING ===

-- Commenti
hi('Comment', { fg = colors.light_gray, style = 'italic' })
hi('SpecialComment', { fg = colors.pale_pink, style = 'italic' })

-- Costanti
hi('Constant', { fg = colors.light_pink })
hi('String', { fg = colors.salmon })
hi('Character', { fg = colors.pale_pink })
hi('Number', { fg = colors.bright_pink })
hi('Boolean', { fg = colors.pink, style = 'bold' })
hi('Float', { fg = colors.bright_pink })

-- Identificatori
hi('Identifier', { fg = colors.fg })
hi('Function', { fg = colors.pink, style = 'bold' })

-- Statements
hi('Statement', { fg = colors.bright_pink, style = 'bold' })
hi('Conditional', { fg = colors.pink, style = 'bold' })
hi('Repeat', { fg = colors.pink, style = 'bold' })
hi('Label', { fg = colors.pale_pink })
hi('Operator', { fg = colors.bright_pink })
hi('Keyword', { fg = colors.pink, style = 'bold' })
hi('Exception', { fg = colors.blush, style = 'bold' })

-- Preprocessor
hi('PreProc', { fg = colors.deep_pink })
hi('Include', { fg = colors.pink })
hi('Define', { fg = colors.bright_pink })
hi('Macro', { fg = colors.pale_pink })
hi('PreCondit', { fg = colors.deep_pink })

-- Types
hi('Type', { fg = colors.pale_pink, style = 'bold' })
hi('StorageClass', { fg = colors.pink })
hi('Structure', { fg = colors.deep_pink })
hi('Typedef', { fg = colors.pink })

-- Specials
hi('Special', { fg = colors.bright_pink })
hi('SpecialChar', { fg = colors.blush })
hi('Tag', { fg = colors.pink })
hi('Delimiter', { fg = colors.fg_alt })
hi('Debug', { fg = colors.blush })

-- Underlined e Errori
hi('Underlined', { fg = colors.pale_pink, style = 'underline' })
hi('Ignore', { fg = colors.light_gray })
hi('Error', { fg = colors.blush, bg = colors.bg_alt, style = 'bold' })
hi('Todo', { fg = colors.black, bg = colors.bright_pink, style = 'bold' })

-- === DIFF ===
hi('DiffAdd', { fg = colors.salmon, bg = colors.dark_gray })
hi('DiffChange', { fg = colors.pale_pink, bg = colors.dark_gray })
hi('DiffDelete', { fg = colors.blush, bg = colors.dark_gray })
hi('DiffText', { fg = colors.white, bg = colors.pink })

-- === POPUP MENU ===
hi('Pmenu', { fg = colors.fg, bg = colors.bg_alt })
hi('PmenuSel', { fg = colors.white, bg = colors.pink })
hi('PmenuSbar', { bg = colors.gray })
hi('PmenuThumb', { bg = colors.bright_pink })

-- === STATUSLINE ===
hi('StatusLine', { fg = colors.white, bg = colors.pink })
hi('StatusLineNC', { fg = colors.light_gray, bg = colors.dark_gray })

-- === TABLINE ===
hi('TabLine', { fg = colors.fg_alt, bg = colors.dark_gray })
hi('TabLineFill', { bg = colors.bg_alt })
hi('TabLineSel', { fg = colors.white, bg = colors.pink, style = 'bold' })

-- === SPLITS ===
hi('VertSplit', { fg = colors.gray, bg = colors.bg })
hi('WinSeparator', { fg = colors.pink, bg = colors.bg })

-- === FOLDING ===
hi('Folded', { fg = colors.light_gray, bg = colors.dark_gray })

-- === SPELL ===
hi('SpellBad', { sp = colors.blush, style = 'undercurl' })
hi('SpellCap', { sp = colors.pale_pink, style = 'undercurl' })
hi('SpellLocal', { sp = colors.light_pink, style = 'undercurl' })
hi('SpellRare', { sp = colors.salmon, style = 'undercurl' })

-- === PLUGINS SPECIFICI ===

-- LSP
hi('LspReferenceText', { bg = colors.dark_gray })
hi('LspReferenceRead', { bg = colors.dark_gray })
hi('LspReferenceWrite', { bg = colors.dark_gray })

-- Diagnostics
hi('DiagnosticError', { fg = colors.blush })
hi('DiagnosticWarn', { fg = colors.light_pink })
hi('DiagnosticInfo', { fg = colors.pale_pink })
hi('DiagnosticHint', { fg = colors.salmon })

hi('DiagnosticSignError', { fg = colors.blush, bg = colors.bg })
hi('DiagnosticSignWarn', { fg = colors.light_pink, bg = colors.bg })
hi('DiagnosticSignInfo', { fg = colors.pale_pink, bg = colors.bg })
hi('DiagnosticSignHint', { fg = colors.salmon, bg = colors.bg })

-- GitSigns
hi('GitSignsAdd', { fg = colors.salmon, bg = colors.bg })
hi('GitSignsChange', { fg = colors.pale_pink, bg = colors.bg })
hi('GitSignsDelete', { fg = colors.blush, bg = colors.bg })

-- Telescope
hi('TelescopeNormal', { fg = colors.fg, bg = colors.bg_alt })
hi('TelescopeBorder', { fg = colors.pink, bg = colors.bg_alt })
hi('TelescopePromptBorder', { fg = colors.bright_pink, bg = colors.bg_alt })
hi('TelescopeResultsBorder', { fg = colors.pink, bg = colors.bg_alt })
hi('TelescopePreviewBorder', { fg = colors.pale_pink, bg = colors.bg_alt })

hi('TelescopeSelectionCaret', { fg = colors.bright_pink, bg = colors.dark_gray })
hi('TelescopeSelection', { fg = colors.white, bg = colors.dark_gray })
hi('TelescopeMatching', { fg = colors.bright_pink, style = 'bold' })

-- NvimTree
hi('NvimTreeNormal', { fg = colors.fg, bg = colors.bg_alt })
hi('NvimTreeFolderIcon', { fg = colors.pink })
hi('NvimTreeFolderName', { fg = colors.pale_pink })
hi('NvimTreeOpenedFolderName', { fg = colors.bright_pink, style = 'bold' })
hi('NvimTreeSpecialFile', { fg = colors.salmon, style = 'bold' })
hi('NvimTreeExecutableFile', { fg = colors.light_pink, style = 'bold' })

-- Indent Blankline
hi('IndentBlanklineChar', { fg = colors.dark_gray })
hi('IndentBlanklineContextChar', { fg = colors.pink })

-- Which Key
hi('WhichKey', { fg = colors.bright_pink, style = 'bold' })
hi('WhichKeyGroup', { fg = colors.pale_pink })
hi('WhichKeyDesc', { fg = colors.fg })
hi('WhichKeySeperator', { fg = colors.gray })

-- Terminal
vim.g.terminal_color_0 = colors.black
vim.g.terminal_color_1 = colors.blush
vim.g.terminal_color_2 = colors.salmon
vim.g.terminal_color_3 = colors.light_pink
vim.g.terminal_color_4 = colors.deep_pink
vim.g.terminal_color_5 = colors.pink
vim.g.terminal_color_6 = colors.pale_pink
vim.g.terminal_color_7 = colors.fg
vim.g.terminal_color_8 = colors.gray
vim.g.terminal_color_9 = colors.bright_pink
vim.g.terminal_color_10 = colors.salmon
vim.g.terminal_color_11 = colors.light_pink
vim.g.terminal_color_12 = colors.pale_pink
vim.g.terminal_color_13 = colors.bright_pink
vim.g.terminal_color_14 = colors.fg_alt
vim.g.terminal_color_15 = colors.whiteS