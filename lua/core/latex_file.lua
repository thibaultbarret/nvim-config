-- Remove ':' '_' and add "@-@" to iskeyword for LaTeX files
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "tex", "latex", "plaintex" },
    callback = function()
        vim.opt_local.iskeyword:remove(":")
        vim.opt_local.iskeyword:remove("_")
        -- Conserver les caractères utiles pour LaTeX
        vim.opt_local.iskeyword:append("@-@") -- pour les packages avec @
    end,
})

-- Open automatically the fold containing \begin{document} in LaTeX files
