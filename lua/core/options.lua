vim.g.mapleader = " "
local opt = vim.opt
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

-- Line break

opt.wrap = true -- Active le retour à la ligne visuel
-- opt.linebreak = true -- Coupe aux espaces plutôt qu'au milieu d'un mot
opt.breakindent = true
opt.showbreak = "󰘍 "

--
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
--
-- Préserver l'état des folds lors de la sauvegarde
-- vim.api.nvim_create_autocmd("BufWritePre", {
--     pattern = "*",
--     callback = function()
--         -- Sauvegarder la vue (qui inclut l'état des folds)
--         vim.cmd("silent! mkview")
--     end,
-- })
--
-- vim.api.nvim_create_autocmd("BufWinEnter", {
--     pattern = "*",
--     callback = function()
--         -- Restaurer la vue sauvegardée
--         vim.cmd("silent! loadview")
--     end,
-- })
--
-- vim.api.nvim_create_autocmd("BufWinEnter", {
--     pattern = "*",
--     callback = function()
--         -- Petit délai pour laisser UFO créer les folds d'abord
--         vim.defer_fn(function()
--             -- Définir foldlevel élevé pour ne plus fermer automatiquement
--             vim.o.foldlevel = 99
--         end, 50)
--     end,
-- })
