return {
    "neovim/nvim-lspconfig",
    dependencies = { "williamboman/mason-lspconfig.nvim" },
    config = function()
        local lspconfig = require('lspconfig')

        -- Keymaps LSP
        local on_attach = function(client, bufnr)
            client.server_capabilities.executeCommandProvider = false
            local opts = { buffer = bufnr }
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
            vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
            vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
            vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
            vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
            vim.keymap.set('n', '<leader>f', function()
                vim.lsp.buf.format { async = true }
            end, opts)
        end

        -- Configuration Pyright
        lspconfig.pyright.setup({
            on_attach = on_attach,
            capabilities = require('cmp_nvim_lsp').default_capabilities(),
            handlers = {
                ["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
                    -- Filtre les diagnostics avant de les publier
                    if result.diagnostics then
                        result.diagnostics = vim.tbl_filter(function(diagnostic)
                            local message = diagnostic.message:lower()
                            local code = diagnostic.code

                            -- Filtre par code d'erreur Pyright
                            local pyright_codes_to_ignore = {
                                "reportUnusedImport",
                                "reportUnusedVariable",
                                "reportMissingImports",
                                "reportWildcardImportFromLibrary",
                            }

                            if code then
                                for _, ignored_code in ipairs(pyright_codes_to_ignore) do
                                    if code == ignored_code then
                                        return false -- Ignore ce diagnostic
                                    end
                                end
                            end

                            -- Filtre par message (plus robuste)
                            local messages_to_ignore = {
                                "imported but unused",
                                "is not accessed",
                                "is not used",
                                "import.*unused",
                                "module.*not found",
                            }

                            for _, pattern in ipairs(messages_to_ignore) do
                                if message:match(pattern) then
                                    return false -- Ignore ce diagnostic
                                end
                            end

                            return true -- Garde ce diagnostic
                        end, result.diagnostics)
                    end

                    -- Publie les diagnostics filtrés
                    vim.lsp.diagnostic.on_publish_diagnostics(err, result, ctx, config)
                end,
            },
            settings = {
                pyright = {
                    disableOrganizeImports = true,
                },
                analysis = {
                    autoSearchPaths = true,
                    diagnosticMode = "workspace", -- ou "openFilesOnly"
                    useLibraryCodeForTypes = true,
                    typeCheckingMode = "basic",   -- ou "strict"
                    diagnosticSeverityOverrides = {
                        diagnosticSeverityOverrides = {
                            reportUnusedImport = "none",
                            reportUnusedVariable = "none",
                            reportUnusedFunction = "none",
                            reportUnusedClass = "none",
                            reportMissingImports = "none",
                            reportWildcardImportFromLibrary = "none",

                            -- Garde les vrais diagnostics de types
                            reportGeneralTypeIssues = "error",
                            reportOptionalMemberAccess = "error",
                            reportOptionalSubscript = "error",
                            reportOptionalOperand = "error",
                            reportAttributeAccessIssue = "error",
                            reportArgumentType = "error",
                            reportAssignmentType = "error",
                            reportReturnType = "error",
                        },
                    },
                }
            }
        })

        vim.diagnostic.config({
            virtual_text = {
                enabled = true,
                source = "if_many", -- Affiche la source si plusieurs
                prefix = function(diagnostic)
                    -- Différents préfixes selon la source
                    if diagnostic.source == "Pyright" then
                        return "🐍"
                    elseif diagnostic.source == "Ruff" then
                        return "⚡"
                    else
                        return "●"
                    end
                end,
                spacing = 2,
            },
            signs = {
                text = {
                    [vim.diagnostic.severity.ERROR] = "",
                    [vim.diagnostic.severity.WARN] = "",
                    [vim.diagnostic.severity.INFO] = "",
                    [vim.diagnostic.severity.HINT] = "󰌵",
                },
            },
            underline = true,
            update_in_insert = false,
            severity_sort = true,
            float = {
                focusable = false,
                style = "minimal",
                border = "rounded",
                source = "always", -- Toujours afficher la source dans les popups
                header = "",
                prefix = "",
            },
        })
    end,
}
