return {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local conform = require("conform")

        local DEFAULT_TIMEOUT_MS = 500
        -- bibtex-tidy met ~0,4 s sur la bibliographie de thèse (~10 000 lignes)
        local SLOW_FORMAT_TIMEOUT_MS = { bib = 2000 }

        local function format_opts(bufnr)
            return {
                lsp_fallback = true,
                async = false,
                timeout_ms = SLOW_FORMAT_TIMEOUT_MS[vim.bo[bufnr].filetype] or DEFAULT_TIMEOUT_MS,
            }
        end

        conform.setup({
            formatters_by_ft = {
                json = { "prettier" },
                markdown = { "prettier" },
                lua = { "stylua" },
                python = { "ruff_format", "ruff_organize_imports" },
                cpp = { "clang_format" },
                c = { "clang_format" },
                sh = { "beautysh" },
                snakemake = { "snakefmt" },
                bash = { "beautysh" },
                zsh = { "beautysh" },
                latex = { "tex-fmt" },
                tex = { "tex-fmt" },
                javascript = { "biome" },
                astro = { "prettier" },
                yaml = { "yamlfmt" },
                bib = { "bibtex-tidy" },
                -- yaml = { "prettier" },
                -- cmake = { "cmake_format" },
            },
            formatters = {
                prettier = {
                    prepend_args = {
                        "--tab-width",
                        "4",
                        "--use-tabs",
                        "false", -- << ça force les espaces
                    },
                },
                stylua = {
                    prepend_args = { "--indent-type", "Spaces", "--indent-width", "4" },
                },
                clang_format = {
                    prepend_args = { "--style", "file" },
                },
                ["bibtex-tidy"] = {
                    -- Réglages prudents : n'ajoute/ne supprime aucune entrée et
                    -- ne trie pas les entrées (sections commentées conservées).
                    args = {
                        "--quiet",
                        "--no-escape", -- garde l'UTF-8 (é, ü…) : biber le gère
                        "--space=4",
                        "--curly", -- valeurs entre accolades
                        "--numeric", -- year = 2020 sans accolades
                        "--sort-fields", -- ordre standard des champs
                        "--remove-empty-fields",
                        "--blank-lines", -- ligne vide entre les entrées
                        "--trailing-commas",
                    },
                },
            },
            format_on_save = format_opts,
        })

        vim.keymap.set({ "n", "v" }, "<leader>mp", function()
            conform.format(format_opts(vim.api.nvim_get_current_buf()))
        end, { desc = "Format file or range (in visual mode)" })
    end,
}
