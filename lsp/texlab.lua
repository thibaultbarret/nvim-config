return {
    cmd = { "texlab" },
    filetypes = { "tex", "plaintex", "bib" },
    root_markers = { ".git", ".latexmkrc", "latexmkrc", ".texlabroot", "texlabroot", "Tectonic.toml" },
    settings = {
        texlab = {
            build = {
                -- DÉSACTIVEZ la compilation texlab - VimTeX s'en charge
                onSave = false, -- Important !
                forwardSearchAfter = false,
            },
            chktex = {
                onOpenAndSave = false, -- Diagnostics seulement
                onEdit = false,
            },
            diagnosticsDelay = 100,
            -- Désactivez le formateur si vous utilisez autre chose
            latexFormatter = "none",
        },
    },
}
