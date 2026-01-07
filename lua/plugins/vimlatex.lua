return {
    "lervag/vimtex",
    lazy = false,
    config = function()
        vim.g.vimtex_syntax_enabled = 1 -- S'assurer que la syntaxe est activée (c'est le défaut)
        vim.g.vimtex_syntax_conceal_disable = 0 -- Optionnel
        vim.g.vimtex_view_method = "skim"
        vim.g.vimtex_view_skim_sync = 1
        vim.g.vimtex_view_skim_activate = 1

        -- Configuration du compilateur
        vim.g.vimtex_compiler_method = "latexmk"
        vim.g.vimtex_compiler_latexmk = {
            build_dir = "",
            callback = 1,
            continuous = 1,
            executable = "latexmk",
            hooks = {},
            options = {
                "-pdf",
                "--shell-escape",
                "-verbose",
                "-file-line-error",
                "-synctex=1",
                "-interaction=nonstopmode",
            },
        }

        -- Configuration de la quickfix
        vim.g.vimtex_quickfix_mode = 1

        -- Ignorer tous les warnings dans la quickfix
        vim.g.vimtex_quickfix_ignore_filters = {
            "Underfull \\hbox",
            "Overfull \\hbox",
            "LaTeX Warning:",
            "LaTeX hooks Warning",
            "Package .* Warning:",
            "Class .* Warning:",
        }

        -- Alternative : n'ouvrir la quickfix que pour les erreurs
        vim.g.vimtex_quickfix_open_on_warning = 0
    end,
}
