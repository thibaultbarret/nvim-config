return {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local lint = require("lint")

        -- Configuration des linters par type de fichier
        lint.linters_by_ft = {
            python = { "ruff" },
            lua = { "luacheck" },
            markdown = { "markdownlint" },
            yaml = { "yamllint" },
            json = { "jsonlint" },
            sh = { "shellcheck" },
            bash = { "shellcheck" },
            zsh = { "shellcheck" },
        }

        -- Configuration personnalisée pour Ruff
        lint.linters.ruff.args = {
            '--select',
            -- Sélectionne les règles que Ruff doit gérer
            table.concat({
                'E', -- pycodestyle errors
                'W', -- pycodestyle warnings
                'F', -- pyflakes (imports non utilisés, variables non utilisées, etc.)
                'I', -- isort (ordre des imports)
                'N', -- pep8-naming
                'UP', -- pyupgrade
                'B', -- flake8-bugbear
                'S', -- flake8-bandit
                'C4', -- flake8-comprehensions
                'SIM', -- flake8-simplify
                'ARG', -- flake8-unused-arguments
                'PTH', -- flake8-use-pathlib
                'ERA', -- eradicate (code commenté)
                'PL', -- pylint
                'RUF', -- ruff-specific rules
            }, ','),

            '--ignore',
            -- Ignore quelques règles problématiques
            table.concat({
                'E501', -- Line too long (si vous préférez un formatter)
                'W503', -- Line break before binary operator
                'E203', -- Whitespace before ':' (conflit avec black)
                'B008', -- Do not perform function calls in argument defaults
                'S101', -- Use of assert (OK en dev/tests)
            }, ','),

            '--format', 'json',
            '--stdin-filename', function()
            return vim.fn.expand('%:p')
        end,
            '-'
        }

        -- Configuration pour luacheck (si vous éditez des configs Neovim)
        lint.linters.luacheck.args = {
            '--globals', 'vim',
            '--formatter', 'plain',
            '--codes',
            '--ranges',
            '-'
        }

        -- Configuration pour markdownlint
        lint.linters.markdownlint.args = {
            '--stdin',
            '--config', vim.fn.expand('~/.markdownlint.yaml'), -- Si vous avez un config
        }

        -- Fonction pour linter avec debounce (évite trop d'appels)
        local lint_timer = nil
        local function debounced_lint()
            if lint_timer then
                vim.fn.timer_stop(lint_timer)
            end
            lint_timer = vim.fn.timer_start(150, function()
                vim.schedule(function()
                    lint.try_lint()
                end)
            end)
        end

        -- Auto-commands pour lancer le linting
        local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

        vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave", "TextChanged" }, {
            group = lint_augroup,
            callback = function()
                -- Ne lint que si le buffer est modifiable et a un nom
                if vim.bo.modifiable and vim.fn.expand('%') ~= '' then
                    debounced_lint()
                end
            end,
        })

        -- Lint au changement de fichier
        vim.api.nvim_create_autocmd("BufReadPost", {
            group = lint_augroup,
            callback = function()
                if vim.bo.modifiable and vim.fn.expand('%') ~= '' then
                    lint.try_lint()
                end
            end,
        })

        -- Keymaps utiles
        vim.keymap.set("n", "<leader>l", function()
            lint.try_lint()
        end, { desc = "Trigger linting for current file" })

        vim.keymap.set("n", "<leader>lf", function()
            local ft = vim.bo.filetype
            local linters = lint.linters_by_ft[ft]
            if linters then
                print("Linters for " .. ft .. ": " .. table.concat(linters, ", "))
            else
                print("No linters configured for filetype: " .. ft)
            end
        end, { desc = "Show configured linters for current filetype" })

        -- Fonction pour activer/désactiver le linting
        vim.keymap.set("n", "<leader>lt", function()
            local lint_enabled = vim.g.lint_enabled
            if lint_enabled == nil then
                lint_enabled = true
            end

            if lint_enabled then
                vim.api.nvim_del_augroup_by_name("lint")
                vim.g.lint_enabled = false
                print("Linting disabled")
            else
                -- Recréer l'autogroup
                local new_lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
                vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave", "TextChanged" }, {
                    group = new_lint_augroup,
                    callback = function()
                        if vim.bo.modifiable and vim.fn.expand('%') ~= '' then
                            debounced_lint()
                        end
                    end,
                })
                vim.g.lint_enabled = true
                print("Linting enabled")
            end
        end, { desc = "Toggle linting on/off" })


        -- Fonction utilitaire pour afficher les erreurs dans une popup
        vim.keymap.set("n", "<leader>le", function()
            local diagnostics = vim.diagnostic.get(0)
            if #diagnostics == 0 then
                print("No diagnostics found")
                return
            end

            local lines = {}
            for _, diagnostic in ipairs(diagnostics) do
                local severity = vim.diagnostic.severity[diagnostic.severity]
                table.insert(lines, string.format("[%s] Line %d: %s", severity, diagnostic.lnum + 1, diagnostic.message))
            end

            -- Ouvre une popup avec les erreurs
            local buf = vim.api.nvim_create_buf(false, true)
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
            vim.api.nvim_open_win(buf, true, {
                relative = "cursor",
                width = math.max(50, math.min(80, vim.o.columns - 10)),
                height = math.min(#lines, 15),
                row = 1,
                col = 0,
                border = "rounded",
                title = " Diagnostics ",
            })
        end, { desc = "Show all diagnostics in popup" })
    end,
}
