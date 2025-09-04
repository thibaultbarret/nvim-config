return {
    "lervag/vimtex",
    lazy = false, -- we don't want to lazy load VimTeX
    -- tag = "v2.15", -- uncomment to pin to a specific release
    config = function()
        -- VimTeX configuration goes here, e.g.
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
                -- "-verbose",
                "-file-line-error",
                "-synctex=1",
                "-interaction=nonstopmode",
            },
        }

        -- Options générales
        vim.g.vimtex_quickfix_mode = 1
        -- vim.g.vimtex_compiler_silent = 1
        -- vim.g.vimtex_compiler_progname = "nvim"
        -- vim.g.vimtex_quickfix_method = "pplatex"
        vim.g.vimtex_quickfix_ignore_filters = {
            "warning",
            "Underfull \\hbox",
            "Overfull \\hbox",
            "LaTeX Warning: .*float specifier changed to",
            "LaTeX hooks Warning",
            "Package hyperref Warning: Token not allowed in a PDF string",
            "Duplicate entry",
        }
        -- vim.g.vimtex_mappings_enabled = 1
        -- vim.g.vimtex_indent_enabled = 1
        -- vim.g.vimtex_syntax_enabled = 1
    end,
}
