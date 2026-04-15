vim.treesitter.language.register("cpp", "mfront")
vim.treesitter.language.register("cpp", "mtest")

-- Le highlighting est activé par défaut, mais tu peux l'activer explicitement via autocommand
vim.api.nvim_create_autocmd("FileType", {
    callback = function()
        pcall(vim.treesitter.start)
    end,
})
