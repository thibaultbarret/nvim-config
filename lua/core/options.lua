vim.g.mapleader = " "

local opt = vim.opt

-- Numero des lignes
opt.number = true
opt.relativenumber = true
opt.cursorline = true

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
