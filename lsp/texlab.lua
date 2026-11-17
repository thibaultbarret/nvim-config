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
            ignoredPatterns = { "Unused label" },
        },
    },
    on_attach = function(client, bufnr)
        client.server_capabilities.semanticTokensProvider = nil
    end,
    handlers = {
        -- Ne garde que les erreurs de texlab dans les .tex (avertissements masqués),
        -- les .bib gardent tout. Propre à ce client : ltex n'est pas concerné.
        -- texlab envoie ses diagnostics en push uniquement (pas de pull).
        ["textDocument/publishDiagnostics"] = function(err, result, ctx)
            local bufnr = result and vim.uri_to_bufnr(result.uri)
            if bufnr and vim.bo[bufnr].filetype == "tex" then
                result.diagnostics = vim.tbl_filter(function(d)
                    return d.severity == vim.lsp.protocol.DiagnosticSeverity.Error
                end, result.diagnostics)
            end
            return vim.lsp.diagnostic.on_publish_diagnostics(err, result, ctx)
        end,
    },
}
