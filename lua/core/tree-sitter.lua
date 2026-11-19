-- vim.treesitter.language.register("cpp", "mfront")
-- vim.treesitter.language.register("cpp", "mtest")

-- Le highlighting est activé par défaut, mais tu peux l'activer explicitement via autocommand
vim.api.nvim_create_autocmd("FileType", {
    callback = function(args)
        if not pcall(vim.treesitter.start, args.buf) then
            return
        end
        -- Indentation treesitter uniquement si le langage fournit une query `indents` :
        -- latex (géré par vimtex), mfront et mtest gardent leur indentation actuelle.
        local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
        local ok, indents = pcall(vim.treesitter.query.get, lang, "indents")
        if ok and indents then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
    end,
})

-- vim.treesitter.language.add("mfront", {
--     path = "/Users/thibault/Documents/THESE/Mfront/Treesitter/tree-sitter-mfront_mtest/grammars/mfront/mfront.dylib",
--     symbol_name = "mfront",
-- })
--
-- vim.treesitter.language.add("mtest", {
--   path = "/path/to/tree-sitter-mtest/mtest.so",
--   symbol_name = "tree_sitter_mtest",
-- })
