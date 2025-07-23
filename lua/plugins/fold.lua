return {
    "kevinhwang91/nvim-ufo",
    dependencies = {
        "kevinhwang91/promise-async",
        "luukvbaal/statuscol.nvim", -- Optionnel mais améliore l'affichage
    },
    event = "BufReadPost",
    config = function()
        -- Configuration des options de fold
        vim.o.foldcolumn = '1' -- Colonne pour les indicateurs de fold
        vim.o.foldlevel = 99   -- Niveau de fold initial (tout ouvert)
        vim.o.foldlevelstart = 99
        vim.o.foldenable = true

        -- Configuration nvim-ufo
        require('ufo').setup({
            -- Utilise LSP et Treesitter
            provider_selector = function(bufnr, filetype, buftype)
                return 'treesitter'
                -- return { 'lsp', 'treesitter', 'indent' }
            end,

            -- Configuration des icônes de fold
            fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
                local newVirtText = {}
                local suffix = (' 󰁂 %d '):format(endLnum - lnum)
                local sufWidth = vim.fn.strdisplaywidth(suffix)
                local targetWidth = width - sufWidth
                local curWidth = 0

                for _, chunk in ipairs(virtText) do
                    local chunkText = chunk[1]
                    local chunkWidth = vim.fn.strdisplaywidth(chunkText)
                    if targetWidth > curWidth + chunkWidth then
                        table.insert(newVirtText, chunk)
                    else
                        chunkText = truncate(chunkText, targetWidth - curWidth)
                        local hlGroup = chunk[2]
                        table.insert(newVirtText, { chunkText, hlGroup })
                        chunkWidth = vim.fn.strdisplaywidth(chunkText)
                        if curWidth + chunkWidth < targetWidth then
                            suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
                        end
                        break
                    end
                    curWidth = curWidth + chunkWidth
                end

                table.insert(newVirtText, { suffix, 'MoreMsg' })
                return newVirtText
            end,

            -- Preview des folds avec K
            preview = {
                win_config = {
                    border = { '', '─', '', '', '', '─', '', '' },
                    winhighlight = 'Normal:Folded',
                    winblend = 0
                },
                mappings = {
                    scrollU = '<C-u>',
                    scrollD = '<C-d>',
                    jumpTop = '[',
                    jumpBot = ']'
                }
            },

            -- Configuration par type de fichier
            ft_ignore = { 'TelescopePrompt', 'alpha', 'dashboard' }
        })

        -- Keymaps pour les folds
        vim.keymap.set('n', 'zR', require('ufo').openAllFolds, { desc = 'Open all folds' })
        vim.keymap.set('n', 'zM', require('ufo').closeAllFolds, { desc = 'Close all folds' })
        vim.keymap.set('n', 'zr', require('ufo').openFoldsExceptKinds, { desc = 'Open folds except kinds' })
        vim.keymap.set('n', 'zm', require('ufo').closeFoldsWith, { desc = 'Close folds with' })
        vim.keymap.set('n', 'zK', function()
            local winid = require('ufo').peekFoldedLinesUnderCursor()
            if not winid then
                vim.lsp.buf.hover()
            end
        end, { desc = 'Peek fold or LSP hover' })

        -- Fold par type spécifique (Python)
        vim.keymap.set('n', '<leader>zf', function()
            require('ufo').closeFoldsWith('function')
        end, { desc = 'Fold functions' })

        vim.keymap.set('n', '<leader>zc', function()
            require('ufo').closeFoldsWith('class')
        end, { desc = 'Fold classes' })

        vim.keymap.set('n', '<leader>zi', function()
            require('ufo').closeFoldsWith('import')
        end, { desc = 'Fold imports' })

        -- Configuration pour les différents langages
        local ft_map = {
            python = { 'lsp', 'treesitter' },
            lua = { 'treesitter' },
            vim = 'indent',
            git = ''
        }

        require('ufo').setup({
            provider_selector = function(bufnr, filetype, buftype)
                return ft_map[filetype] or { 'treesitter', 'indent' }
            end
        })
    end,
}
