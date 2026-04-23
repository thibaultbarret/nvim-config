return {
    cmd = { "texlab" },
    flags = {
        debounce_text_changes = 500,
    },
    filetypes = { "tex", "plaintex", "bib" },
    root_markers = { ".git", ".latexmkrc", "latexmkrc", ".texlabroot", "texlabroot", "Tectonic.toml" },
    settings = {
        texlab = {
            build = {
                onSave = false,
                forwardSearchAfter = false,
            },
            chktex = {
                onOpenAndSave = false,
                onEdit = false,
            },
            diagnosticsDelay = 500,
            latexFormatter = "none",
            bibtexFormatter = "none",
        },
    },
    on_attach = function(client, bufnr)
        client.server_capabilities.semanticTokensProvider = nil

        vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
            buffer = bufnr,
            callback = function()
                local ns = vim.lsp.diagnostic.get_namespace(client.id)
                if vim.bo[bufnr].filetype == "tex" then
                    vim.diagnostic.config({
                        virtual_text = { severity = { min = vim.diagnostic.severity.ERROR } },
                        signs = { severity = { min = vim.diagnostic.severity.ERROR } },
                        underline = { severity = { min = vim.diagnostic.severity.ERROR } },
                    }, ns)
                else
                    vim.diagnostic.config({
                        virtual_text = true,
                        signs = true,
                        underline = true,
                    }, ns)
                end
            end,
        })
    end,
}
