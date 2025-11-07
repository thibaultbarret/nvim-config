return {
    cmd = { "texlab" },
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
            diagnosticsDelay = 100,
            latexFormatter = "none",
        },
    },
    on_attach = function(client, bufnr)
        -- Sauvegarder le handler original
        local orig_handler = vim.diagnostic.handlers.virtual_text

        -- Créer un handler personnalisé
        vim.diagnostic.handlers.virtual_text = {
            show = function(namespace, bufnr_arg, diagnostics, opts)
                -- Filtrer les warnings
                local filtered = vim.tbl_filter(function(d)
                    return d.severity <= vim.diagnostic.severity.ERROR
                end, diagnostics)

                -- Appeler le handler original avec les diagnostics filtrés
                if orig_handler.show then
                    orig_handler.show(namespace, bufnr_arg, filtered, opts)
                end
            end,
            hide = orig_handler.hide,
        }
    end,
}
