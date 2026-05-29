return {
    "JoosepAlviste/nvim-ts-context-commentstring",
    lazy = true,
    config = function()
        require("ts_context_commentstring").setup({
            languages = {
                mfront = { __default = "// %s", __multiline = "/* %s */" },
                mtest = { __default = "// %s", __multiline = "/* %s */" },
            },
        })
    end,
}
