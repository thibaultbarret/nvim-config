return {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy",
    priority = 1000,
    config = function()
        -- Filtrer les diagnostics WARN pour les fichiers .tex avant qu'ils n'arrivent au plugin
        local original_get = vim.diagnostic.get
        vim.diagnostic.get = function(bufnr, opts)
            local diagnostics = original_get(bufnr, opts)
            local ft = vim.api.nvim_buf_get_option(bufnr or 0, "filetype")

            if ft == "tex" then
                return vim.tbl_filter(function(d)
                    return d.severity ~= vim.diagnostic.severity.WARN
                end, diagnostics)
            end

            return diagnostics
        end

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
                    display_count = true,
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
                format = nil,
                virt_texts = {
                    priority = 2048,
                },
                overwrite_events = nil,
                override_open_float = false,
            },
        })

        vim.diagnostic.config({ virtual_text = false })
    end,
}
