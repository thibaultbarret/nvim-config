return {
    cmd = {
        "/Users/thibault/Documents/THESE/LaTeX/pgfplots_tikz_lsp/.venv/bin/python3",
        "-m",
        "pgfplots_tikz_lsp",
    },
    filetypes = { "tex" },
    root_dir = vim.fs.root(0, { ".git" }) or vim.fn.getcwd(),
    on_attach = function(client, bufnr)
        vim.lsp.semantic_tokens.start(bufnr, client.id)
    end,
}
