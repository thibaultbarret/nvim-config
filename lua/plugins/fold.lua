return {
    "kevinhwang91/nvim-ufo",
    dependencies = {
        "kevinhwang91/promise-async",
        "luukvbaal/statuscol.nvim",
    },
    event = "BufReadPost",
    config = function()
        ----------------------------------------------------------------------
        -- Options générales
        ----------------------------------------------------------------------
        vim.o.foldcolumn = "1" -- dessinée par le segment de pli de statuscol (plugins/statuscol.lua)
        vim.o.foldlevel = 99
        vim.o.foldlevelstart = 99
        vim.o.foldenable = true
        -- Marge : ▾ pli ouvert, ▸ pli replié, rien sur les lignes intérieures
        vim.opt.fillchars:append({ foldopen = "▾", foldclose = "▸", foldsep = " " })

        ----------------------------------------------------------------------
        -- ========================== LATEX PROVIDERS =========================
        ----------------------------------------------------------------------
        -- Partie de la ligne avant le commentaire. Un % ouvre un commentaire s'il suit un nombre
        -- pair de \ : \% est un pourcentage, \\% un saut de ligne suivi d'un commentaire.
        local function strip_comment(line)
            local init = 1
            while true do
                local pos = line:find("%", init, true)
                if not pos then
                    return line
                end
                if #line:sub(1, pos - 1):match("\\*$") % 2 == 0 then
                    return line:sub(1, pos - 1)
                end
                init = pos + 1
            end
        end

        -- Les motifs Lua n'ont pas d'alternance `|` : on capture le nom de la
        -- commande puis on le compare à cet ensemble (gère aussi \section*{).
        local SECTIONING_COMMANDS = {
            part = true,
            chapter = true,
            section = true,
            subsection = true,
            subsubsection = true,
        }

        local function is_sectioning(line)
            for command in line:gmatch("\\(%a+)%*?%s*{") do
                if SECTIONING_COMMANDS[command] then
                    return true
                end
            end
            return false
        end

        local function tex_addplot_provider(bufnr)
            local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
            local folds, i = {}, 1

            while i <= #lines do
                local line = strip_comment(lines[i])

                if line:match("^%s*\\addplot") then
                    local start = i - 1
                    local j = i + 1

                    while j <= #lines do
                        local l = strip_comment(lines[j])
                        if l:match(";%s*$") then
                            if j - 1 > start then
                                table.insert(folds, {
                                    startLine = start,
                                    endLine = j - 1,
                                    kind = "addplot",
                                })
                            end
                            i = j
                            goto continue
                        end
                        j = j + 1
                    end
                end

                ::continue::
                i = i + 1
            end
            return folds
        end

        -- Préambule : entre \documentclass et \begin{document}
        local function tex_preamble_provider(bufnr)
            local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
            local folds = {}
            local start_line = nil

            for i, line in ipairs(lines) do
                if not start_line and strip_comment(line):match("\\documentclass") then
                    start_line = i - 1
                elseif start_line and strip_comment(line):match("\\begin%s*{document}") then
                    if i - 2 > start_line then
                        table.insert(folds, {
                            startLine = start_line,
                            endLine = i - 2,
                            kind = "preamble",
                        })
                    end
                    break
                end
            end

            return folds
        end

        -- Arguments entre crochets multi-lignes pour commandes LaTeX
        local function tex_bracket_args_provider(bufnr)
            local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
            local folds, i = {}, 1

            while i <= #lines do
                local line = strip_comment(lines[i])

                -- Détecte plusieurs patterns :
                -- 1. \command[ avec crochet sur même ligne mais pas fermé
                -- 2. \begin{env}[ avec crochet sur même ligne mais pas fermé
                -- 3. \command ou \begin{env} seul, suivi de [ sur la ligne suivante
                -- 4. [ seul sur une ligne

                local has_open_bracket = false
                local start_line = i - 1
                local bracket_start_line = i

                -- Cas 1 & 2: Commande avec [ sur la même ligne
                if line:match("\\%w+%s*%[") or line:match("\\begin%s*{[^}]+}%s*%[") then
                    -- Vérifie si le crochet n'est pas fermé sur la même ligne
                    local open_count = select(2, line:gsub("%[", ""))
                    local close_count = select(2, line:gsub("%]", ""))

                    if open_count > close_count then
                        has_open_bracket = true
                        bracket_start_line = i
                    end

                -- Cas 3: Commande seule, regarder la ligne suivante
                elseif line:match("\\%w+%s*$") or line:match("\\begin%s*{[^}]+}%s*$") then
                    if i + 1 <= #lines then
                        local next_line = strip_comment(lines[i + 1])
                        if next_line:match("^%s*%[") then
                            has_open_bracket = true
                            bracket_start_line = i + 1
                        end
                    end

                -- Cas 4: [ seul sur une ligne
                elseif line:match("^%s*%[%s*$") then
                    has_open_bracket = true
                    bracket_start_line = i
                end

                -- Si on a trouvé un crochet ouvrant non fermé
                if has_open_bracket then
                    local depth = 0
                    local j = bracket_start_line

                    -- Compte les crochets à partir de la ligne du crochet ouvrant
                    while j <= #lines do
                        local current_line = strip_comment(lines[j])

                        for c in current_line:gmatch("[%[%]]") do
                            depth = depth + (c == "[" and 1 or -1)
                        end

                        -- Si on ferme tous les crochets et qu'on a au moins 2 lignes
                        if depth == 0 and j > start_line + 1 then
                            table.insert(folds, {
                                startLine = start_line,
                                endLine = j - 1,
                                kind = "bracket_args",
                            })
                            i = j
                            goto continue
                        end

                        j = j + 1
                    end
                end

                ::continue::
                i = i + 1
            end

            return folds
        end

        -- Accolades sur au moins 3 lignes, imbriquées comprises (\foreach {…} inclus) : une passe,
        -- une pile des lignes d'ouverture. \{ et \} sont littérales ; \\ (saut de ligne) retiré d'abord
        -- pour que \\{ garde son accolade.
        local function tex_braces_provider(bufnr)
            local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
            local folds, open_rows = {}, {}

            for row, raw in ipairs(lines) do
                local line = strip_comment(raw):gsub("\\\\", ""):gsub("\\[{}]", "")
                for brace in line:gmatch("[{}]") do
                    if brace == "{" then
                        open_rows[#open_rows + 1] = row
                    elseif #open_rows > 0 then
                        local start = table.remove(open_rows)
                        if row > start + 1 then
                            folds[#folds + 1] = { startLine = start - 1, endLine = row - 1, kind = "braces" }
                        end
                    end
                end
            end

            return folds
        end

        -- Chaque plage une seule fois : ufo ne retire que les doublons consécutifs, et deux plis
        -- identiques deviennent deux plis emboîtés (il faut alors deux zo pour ouvrir).
        local function unique_ranges(folds)
            local seen, unique = {}, {}
            for _, fold in ipairs(folds) do
                local key = fold.startLine .. ":" .. fold.endLine
                if not seen[key] then
                    seen[key] = true
                    unique[#unique + 1] = fold
                end
            end
            return unique
        end

        local TEX_PROVIDERS = {
            tex_preamble_provider,
            tex_addplot_provider,
            tex_bracket_args_provider,
            tex_braces_provider,
        }

        ----------------------------------------------------------------------
        -- PROVIDER SELECTOR
        ----------------------------------------------------------------------
        -- LaTeX : treesitter (environnements, sections) + plis maison ; ailleurs, treesitter puis indentation
        local function provider_selector(_, filetype)
            if filetype == "tex" or filetype == "latex" then
                return function(bufnr)
                    local folds = require("ufo.provider.treesitter").getFolds(bufnr) or {}
                    for _, provider in ipairs(TEX_PROVIDERS) do
                        vim.list_extend(folds, provider(bufnr))
                    end
                    return unique_ranges(folds)
                end
            end
            return { "treesitter", "indent" }
        end

        ----------------------------------------------------------------------
        -- UFO SETUP
        ----------------------------------------------------------------------
        -- Icône et couleur du résumé d'un pli LaTeX, d'après sa ligne d'en-tête (sans commentaire)
        local function tex_fold_icon(line)
            if line:match("\\begin%s*{") then
                return " 󰙅 ", "Function"
            elseif is_sectioning(line) then
                return " 󰉫 ", "Title"
            elseif line:match("\\documentclass") then -- avant les accolades/crochets qui le captureraient
                return " 󰈙 ", "PreProc"
            elseif line:match("{[^}]*$") then -- accolade ouverte non refermée sur la ligne
                return " 󰅲 ", "Delimiter"
            elseif line:match("%[[^%]]*$") then -- crochet ouvert non refermé sur la ligne
                return " 󰘨 ", "Special"
            end
            return " 󰁂 ", "MoreMsg"
        end

        require("ufo").setup({
            provider_selector = provider_selector,

            -- ctx.text : ligne d'en-tête du pli, prise dans le buffer du pli (lnum commence à 1)
            fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate, ctx)
                local newVirtText = {}
                local filetype = vim.bo[ctx.bufnr].filetype
                local icon, highlight = " 󰁂 ", "MoreMsg"
                if filetype == "tex" or filetype == "latex" then
                    icon, highlight = tex_fold_icon(strip_comment(ctx.text))
                end

                local suffix = (icon .. "%d "):format(endLnum - lnum)
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
                            suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
                        end
                        break
                    end
                    curWidth = curWidth + chunkWidth
                end

                table.insert(newVirtText, { suffix, highlight })
                return newVirtText
            end,

            -- Preview des folds avec K
            preview = {
                win_config = {
                    border = { "", "─", "", "", "", "─", "", "" },
                    winhighlight = "Normal:Folded",
                    winblend = 0,
                },
                mappings = {
                    scrollU = "<C-u>",
                    scrollD = "<C-d>",
                    jumpTop = "[",
                    jumpBot = "]",
                },
            },

            -- Configuration par type de fichier
            ft_ignore = { "TelescopePrompt", "alpha", "dashboard" },
        })

        -- Première ouverture d'un .tex : tout replier, puis rouvrir \begin{document} et les tikzpicture.
        -- Les délais laissent ufo calculer les plis ; tout se fait dans la fenêtre d'origine, même si
        -- on a changé de fenêtre entre-temps (abandonné si elle n'affiche plus ce buffer).
        vim.api.nvim_create_autocmd("BufWinEnter", {
            pattern = "*.tex",
            callback = function(args)
                if vim.b[args.buf].initial_fold_done then
                    return
                end
                local win = vim.api.nvim_get_current_win()
                local function in_origin_window(fn)
                    if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == args.buf then
                        vim.api.nvim_win_call(win, fn)
                    end
                end

                vim.defer_fn(function()
                    in_origin_window(function()
                        local lines = vim.api.nvim_buf_get_lines(args.buf, 0, -1, false)
                        local tikz_start, tikz_end, count = nil, nil, 0
                        for i, line in ipairs(lines) do
                            if line:match("\\begin%s*{tikzpicture}") then
                                tikz_start = i
                                count = count + 1
                            elseif line:match("\\end%s*{tikzpicture}") then
                                tikz_end = i
                            end
                        end

                        require("ufo").closeAllFolds()

                        if count == 1 and tikz_start and tikz_end then
                            vim.api.nvim_win_set_cursor(0, { tikz_start, 0 })
                            vim.cmd("normal! zv")
                        else
                            vim.defer_fn(function()
                                in_origin_window(function()
                                    local pos = vim.api.nvim_win_get_cursor(0)

                                    -- Ouvrir \begin{document}
                                    vim.api.nvim_win_set_cursor(0, { 1, 0 })
                                    local doc_line = vim.fn.search([[\\begin{document}]], "w")
                                    if doc_line > 0 then
                                        vim.api.nvim_win_set_cursor(0, { doc_line, 0 })
                                        vim.cmd("normal! zv") -- zv au lieu de zo
                                    end

                                    -- Ouvrir tous les \begin{tikzpicture}
                                    vim.api.nvim_win_set_cursor(0, { 1, 0 })
                                    while vim.fn.search([[\\begin{tikzpicture}]], "W") > 0 do
                                        vim.cmd("normal! zv")
                                    end

                                    vim.api.nvim_win_set_cursor(0, pos)
                                end)
                            end, 500) -- Délai plus long
                        end

                        vim.b[args.buf].initial_fold_done = true
                    end)
                end, 500)
            end,
        })
        ----------------------------------------------------------------------
        -- Keymaps
        ----------------------------------------------------------------------
        vim.keymap.set("n", "zR", require("ufo").openAllFolds)
        vim.keymap.set("n", "zM", require("ufo").closeAllFolds)
        vim.keymap.set("n", "zK", function()
            local winid = require("ufo").peekFoldedLinesUnderCursor()
            if not winid then
                vim.lsp.buf.hover()
            end
        end)
    end,
}
