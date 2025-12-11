vim.g.mapleader = " "
--
-- Récupérer les attributs de CursorLine et les appliquer à CursorColumn
vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function()
        local cursorline_hl = vim.api.nvim_get_hl(0, { name = "CursorLine" })
        vim.api.nvim_set_hl(0, "CursorColumn", cursorline_hl)
    end,
})

-- Appliquer immédiatement
local cursorline_hl = vim.api.nvim_get_hl(0, { name = "CursorLine" })
vim.api.nvim_set_hl(0, "CursorColumn", cursorline_hl)
local opt = vim.opt

-- Numero des lignes
opt.number = true
opt.relativenumber = true

-- Curseur
opt.cursorline = true
opt.cursorcolumn = true

-- Prise en compte de l'underscore et du colon comme separateur de mots
opt.iskeyword:remove("_")
opt.iskeyword:remove(":")

-- Fond
vim.opt.termguicolors = true
vim.opt.background = "dark"

-- Indentation
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true
opt.softtabstop = 4

-- Recherche
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true

-- Split
opt.splitright = true
opt.splitbelow = true

-- Pas de swapfile
opt.swapfile = false

-- Modifications a l'infini
opt.undofile = true

-- Caracteres speciaux
opt.list = true
opt.listchars:append({ nbsp = "␣", trail = "•", precedes = "«", extends = "»", tab = "> " })

opt.winborder = "rounded"
opt.updatetime = 100
opt.backupcopy = "yes"

opt.wildmenu = true
opt.wildmode = { "longest:full", "full" }
opt.wildoptions = "pum"

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "tex", "latex", "plaintex" },
    callback = function()
        vim.opt_local.iskeyword:remove(":")
        vim.opt_local.iskeyword:remove("_")
        -- Conserver les caractères utiles pour LaTeX
        vim.opt_local.iskeyword:append("@-@") -- pour les packages avec @
    end,
})
