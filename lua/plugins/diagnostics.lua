return {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy",
    priority = 1000,
    config = function()
        require("tiny-inline-diagnostic").setup({
            preset = "modern",
            transparent_bg = false,
            transparent_cursorline = true,
            hi = {
                error = "DiagnosticError",
                warn = "DiagnosticWarn",
                info = "DiagnosticInfo",
                hint = "DiagnosticHint",
                arrow = "NonText",
                background = "CursorLine",
                mixing_color = "Normal",
            },
            -- Notez: on ne désactive plus complètement .tex ici
            disabled_ft = {},
            options = {
                show_source = {
                    enabled = true,
                    if_many = false,
                },
                use_icons_from_diagnostic = false,
                set_arrow_to_diag_color = false,
                throttle = 20,
                softwrap = 30,
                add_messages = {
                    messages = true,
                    display_count = false,
                    use_max_severity = false,
                    show_multiple_glyphs = true,
                },
                multilines = {
                    enabled = true,
                    always_show = true,
                    trim_whitespaces = false,
                    tabstop = 4,
                },
                show_all_diags_on_cursorline = true,
                show_related = {
                    enabled = false,
                    max_count = 3,
                },
                enable_on_insert = false,
                enable_on_select = false,
                overflow = {
                    mode = "wrap",
                    padding = 0,
                },
                break_line = {
                    enabled = false,
                    after = 30,
                },
                -- Fonction pour filtrer les diagnostics selon le filetype
                format = function(diag)
                    local ft = vim.bo.filetype
                    -- Pour les fichiers .tex, ne rien retourner si c'est un warning
                    if ft == "tex" and diag.severity == vim.diagnostic.severity.WARN then
                        return ""
                    end
                    return diag.message
                end,
                virt_texts = {
                    priority = 2048,
                },
                severity = {
                    vim.diagnostic.severity.ERROR,
                    vim.diagnostic.severity.WARN,
                    vim.diagnostic.severity.INFO,
                    vim.diagnostic.severity.HINT,
                },
                overwrite_events = nil,
                override_open_float = false,
            },
        })

        vim.diagnostic.config({ virtual_text = false })
    end,
}
