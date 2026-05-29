-- vim.treesitter.language.register("cpp", "mfront")
-- vim.treesitter.language.register("cpp", "mtest")

-- Le highlighting est activé par défaut, mais tu peux l'activer explicitement via autocommand
vim.api.nvim_create_autocmd("FileType", {
    callback = function()
        pcall(vim.treesitter.start)
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
