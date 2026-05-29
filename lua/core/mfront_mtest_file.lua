vim.api.nvim_create_autocmd("FileType", {
    pattern = { "mfront", "mtest" },
    callback = function()
        vim.bo.commentstring = "// %s"
    end,
})
