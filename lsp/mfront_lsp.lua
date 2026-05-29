return {
    cmd = {
        "/Users/thibault/Documents/THESE/Mfront/LSP/.venv/bin/python3",
        "-m",
        "mfront_lsp",
    },
    filetypes = { "mfront", "mtest" },
    root_dir = function(bufnr, cb)
        cb(vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":h"))
    end,
    -- root_markers = { ".git" },
    cmd_env = {
        PYTHONPATH = "/Users/thibault/Documents/THESE/Mfront/LSP",
    },
    on_attach = function(client, bufnr)
        vim.api.nvim_set_hl(0, "@lsp.type.variable.mfront", { link = "@lsp.type.parameter.mfront" })
        vim.api.nvim_set_hl(0, "@lsp.type.enumMember.mfront", { fg = "#e5c07b", italic = true })
    end,
}
