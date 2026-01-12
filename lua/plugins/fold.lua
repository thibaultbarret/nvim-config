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
        vim.o.foldcolumn = "1"
        vim.o.foldlevel = 99
        vim.o.foldlevelstart = 99
        vim.o.foldenable = true

        -- ----------------------------------------------------------------------
        -- ========================= PYTHON PROVIDERS ========================
        ----------------------------------------------------------------------
        -- Literal[] / Union[]
        local function python_literal_provider(bufnr)
            local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
            local folds, i = {}, 1

            while i <= #lines do
                local line = lines[i]
                local kind = line:match("Literal%s*%[") and "literal" or line:match("Union%s*%[") and "union"

                if kind then
                    local start_line = i - 1
                    local count, j = 0, i

                    while j <= #lines do
                        for c in lines[j]:gmatch("[%[%]]") do
                            count = count + (c == "[" and 1 or -1)
                        end
                        if count == 0 and j > i then
                            table.insert(folds, {
                                startLine = start_line,
                                endLine = j - 1,
                                kind = kind,
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

        -- Class attributes
        local function python_class_attributes_provider(bufnr)
            local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
            local folds, i = {}, 1

            while i <= #lines do
                if lines[i]:match("^class%s+") then
                    local base_indent
                    local start, finish
                    local j = i + 1

                    while j <= #lines do
                        local line = lines[j]

                        if not (line:match("^%s*$") or line:match("^%s*#")) then
                            local indent = #(line:match("^(%s*)") or "")
                            base_indent = base_indent or indent

                            if indent < base_indent then
                                break
                            end

                            if indent == base_indent and line:match("^%s+[%w_]+%s*[:=]") then
                                start = start or (j - 1)
                                finish = j - 1
                            elseif start then
                                break
                            end
                        end

                        j = j + 1
                    end

                    if start and finish and finish > start then
                        table.insert(folds, {
                            startLine = start,
                            endLine = finish,
                            kind = "attributes",
                        })
                    end

                    i = j
                else
                    i = i + 1
                end
            end

            return folds
        end

        -- @overload groups
        local function python_overload_provider(bufnr)
            local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
            local folds, i = {}, 1

            while i <= #lines do
                if lines[i]:match("^%s*@overload%s*$") then
                    local start = i - 1
                    local j = i + 1
                    while j <= #lines and not lines[j]:match("^%s*def%s+") do
                        j = j + 1
                    end
                    if j - 2 > start then
                        table.insert(folds, {
                            startLine = start,
                            endLine = j - 2,
                            kind = "overload",
                        })
                    end
                    i = j
                else
                    i = i + 1
                end
            end
            return folds
        end

        -- match / case
        local function python_match_case_provider(bufnr)
            local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
            local folds, i = {}, 1

            while i <= #lines do
                if lines[i]:match("^%s*match%s+") then
                    local base_indent = #(lines[i]:match("^(%s*)") or "")
                    local j = i + 1

                    while j <= #lines do
                        local indent = #(lines[j]:match("^(%s*)") or "")
                        if indent <= base_indent then
                            break
                        end

                        if lines[j]:match("^%s*case%s+") then
                            local start = j - 1
                            local k = j + 1
                            while k <= #lines and #(lines[k]:match("^(%s*)") or "") > indent do
                                k = k + 1
                            end
                            if k - 2 > start then
                                table.insert(folds, {
                                    startLine = start,
                                    endLine = k - 2,
                                    kind = "case",
                                })
                            end
                            j = k
                        else
                            j = j + 1
                        end
                    end
                    i = j
                else
                    i = i + 1
                end
            end
            return folds
        end

        -- Imports
        local function python_imports_provider(bufnr)
            local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
            local folds = {}
            local i = 1
            local start = nil
            local last_import = nil
            local in_multiline_import = false

            while i <= #lines do
                local line = lines[i]

                -- Détecte une ligne d'import
                if line:match("^import%s+") or line:match("^from%s+.+%s+import") then
                    if not start then
                        start = i - 1
                    end
                    last_import = i - 1

                    -- Vérifier si c'est un import multi-ligne
                    local open_parens = select(2, line:gsub("%(", ""))
                    local close_parens = select(2, line:gsub("%)", ""))
                    if open_parens > close_parens then
                        in_multiline_import = true
                    end
                -- Si on est dans un import multi-ligne, continuer
                elseif in_multiline_import then
                    last_import = i - 1
                    local open_parens = select(2, line:gsub("%(", ""))
                    local close_parens = select(2, line:gsub("%)", ""))
                    if close_parens > 0 then
                        in_multiline_import = false
                    end
                -- Autoriser les lignes vides et commentaires entre les imports
                elseif start and (line:match("^%s*$") or line:match("^%s*#")) then
                -- Ne rien faire, on continue
                -- Dès qu'on trouve une ligne avec du code, on ferme le fold
                elseif start and last_import then
                    -- On ferme le fold jusqu'à la dernière ligne d'import
                    if last_import > start then
                        table.insert(folds, {
                            startLine = start,
                            endLine = last_import,
                            kind = "imports",
                        })
                    end
                    start = nil
                    last_import = nil
                end

                i = i + 1
            end

            -- Cas où les imports vont jusqu'à la fin du fichier
            if start and last_import and last_import > start then
                table.insert(folds, {
                    startLine = start,
                    endLine = last_import,
                    kind = "imports",
                })
            end

            return folds
        end

        -- Docstring
        local function python_module_docstring_provider(bufnr)
            local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
            local folds = {}
            local i = 1

            -- Sauter les commentaires et lignes vides au début
            while i <= #lines and (lines[i]:match("^%s*$") or lines[i]:match("^%s*#")) do
                i = i + 1
            end

            -- Chercher une docstring multiline avec """ ou '''
            if i <= #lines then
                local line = lines[i]
                -- Correction : capturer le quote, puis utiliser %1 en dehors de la capture
                local quote = line:match("^%s*([\"'])%1%1") -- """ ou '''

                if quote then
                    local start = i - 1
                    local full_quote = quote:rep(3) -- Reconstituer """ ou '''

                    -- Si le closing est sur la même ligne, on ignore
                    local _, count = line:gsub(vim.pesc(full_quote), "")
                    if count >= 2 then
                        return folds
                    end

                    -- Chercher la fermeture
                    local j = i + 1
                    while j <= #lines do
                        if lines[j]:match(vim.pesc(full_quote)) then
                            -- On crée un fold seulement si on a au moins 3 lignes
                            if j - 1 > start + 1 then
                                table.insert(folds, {
                                    startLine = start,
                                    endLine = j - 1,
                                    kind = "docstring",
                                })
                            end
                            break
                        end
                        j = j + 1
                    end
                end
            end

            return folds
        end

        ----------------------------------------------------------------------
        -- ========================== LATEX PROVIDERS =========================
        ----------------------------------------------------------------------
        local function strip_comment(line)
            return line:gsub("%%.*$", "")
        end

        -- Environnements + sections
        local function tex_env_provider(bufnr)
            local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
            local folds, i = {}, 1

            while i <= #lines do
                local line = strip_comment(lines[i])

                local env = line:match("\\begin%s*{([^}]+)}")
                if env then
                    local start = i - 1
                    local j = i + 1
                    local end_pat = "\\end%s*{" .. vim.pesc(env) .. "}"

                    while j <= #lines do
                        if strip_comment(lines[j]):match(end_pat) then
                            table.insert(folds, {
                                startLine = start,
                                endLine = j - 1,
                                kind = "environment",
                            })
                            i = j
                            goto cont
                        end
                        j = j + 1
                    end
                end

                if line:match("\\(part|chapter|section|subsection|subsubsection)%s*{") then
                    local start = i - 1
                    local j = i + 1
                    while j <= #lines do
                        local l = strip_comment(lines[j])
                        if l:match("\\(part|chapter|section|subsection|subsubsection)%s*{") or l:match("\\end%s*{") then
                            break
                        end
                        j = j + 1
                    end
                    if j - 2 > start then
                        table.insert(folds, {
                            startLine = start,
                            endLine = j - 2,
                            kind = "section",
                        })
                        i = j - 1
                    end
                end
                ::cont::
                i = i + 1
            end
            return folds
        end

        -- TikZ \foreach { ... }
        local function tex_foreach_provider(bufnr)
            local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
            local folds, i = {}, 1

            while i <= #lines do
                local line = strip_comment(lines[i])
                if line:match("^%s*\\foreach%s+.+{%s*$") then
                    local start = i - 1
                    local depth, j = 0, i
                    while j <= #lines do
                        for c in strip_comment(lines[j]):gmatch("[{}]") do
                            depth = depth + (c == "{" and 1 or -1)
                        end
                        if depth == 0 and j > i then
                            table.insert(folds, {
                                startLine = start,
                                endLine = j - 1,
                                kind = "foreach",
                            })
                            i = j
                            goto cont
                        end
                        j = j + 1
                    end
                end
                ::cont::
                i = i + 1
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

        -- Accolades multi-lignes en LaTeX (avec support des folds imbriqués)
        local function tex_braces_provider(bufnr)
            local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
            local folds = {}

            -- Fonction récursive pour trouver tous les folds d'accolades
            local function find_brace_folds(start_idx, end_idx)
                local i = start_idx

                while i <= end_idx do
                    local line = strip_comment(lines[i])

                    -- Cherche des accolades ouvrantes
                    local pos = 1
                    while pos <= #line do
                        local brace_pos = line:find("{", pos, true)
                        if not brace_pos then
                            break
                        end

                        -- Trouve l'accolade fermante correspondante
                        local depth = 0
                        local j = i
                        local char_pos = brace_pos

                        while j <= end_idx do
                            local current_line = strip_comment(lines[j])
                            local start_pos = (j == i) and char_pos or 1

                            for k = start_pos, #current_line do
                                local c = current_line:sub(k, k)
                                if c == "{" then
                                    depth = depth + 1
                                elseif c == "}" then
                                    depth = depth - 1
                                    if depth == 0 then
                                        -- Trouvé l'accolade fermante correspondante
                                        -- Créer un fold seulement si ça fait au moins 3 lignes
                                        if j > i + 1 then
                                            table.insert(folds, {
                                                startLine = i - 1,
                                                endLine = j - 1,
                                                kind = "braces",
                                            })

                                            -- Chercher récursivement des folds imbriqués
                                            find_brace_folds(i + 1, j - 1)
                                        end
                                        goto next_brace
                                    end
                                end
                            end
                            j = j + 1
                        end

                        ::next_brace::
                        pos = brace_pos + 1
                    end

                    i = i + 1
                end
            end

            find_brace_folds(1, #lines)
            return folds
        end

        ----------------------------------------------------------------------
        -- PROVIDER SELECTOR
        ----------------------------------------------------------------------
        local function provider_selector(bufnr, filetype)
            if filetype == "python" then
                return function(bufnr)
                    local ts = require("ufo.provider.treesitter").getFolds(bufnr) or {}
                    return vim.list_extend(
                        ts,
                        vim.list_extend(
                            python_imports_provider(bufnr),
                            vim.list_extend(
                                python_module_docstring_provider(bufnr),
                                vim.list_extend(
                                    python_literal_provider(bufnr),
                                    vim.list_extend(
                                        python_class_attributes_provider(bufnr),
                                        vim.list_extend(
                                            python_overload_provider(bufnr),
                                            python_match_case_provider(bufnr)
                                        )
                                    )
                                )
                            )
                        )
                    )
                end
            elseif filetype == "tex" or filetype == "latex" then
                return function(bufnr)
                    local ts = require("ufo.provider.treesitter").getFolds(bufnr) or {}
                    -- vim.list_extend(ts, tex_env_provider(bufnr))
                    vim.list_extend(ts, tex_foreach_provider(bufnr))
                    vim.list_extend(ts, tex_bracket_args_provider(bufnr))
                    vim.list_extend(ts, tex_braces_provider(bufnr))
                    return ts
                end
            end
            return { "treesitter", "indent" }
        end

        ----------------------------------------------------------------------
        -- UFO SETUP
        ----------------------------------------------------------------------
        require("ufo").setup({
            provider_selector = provider_selector,
            -- provider_selector = enhanced_provider_selector,

            -- Configuration des icônes de fold avec indication du type
            fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
                local newVirtText = {}

                -- Détecte le type de fold pour personnaliser l'affichage
                local line_text = vim.api.nvim_buf_get_lines(0, lnum, lnum + 1, false)[1] or ""
                local icon = " 󰁂 "
                local highlight = "MoreMsg"

                --
                -- Python - Imports
                if line_text:match("^import%s+") or line_text:match("^from%s+") then
                    icon = "  "
                    highlight = "Include"
                --
                -- Python - Docstring de module
                elseif line_text:match('^%s*"""') or line_text:match("^%s*'''") then
                    icon = " 󰷉 "
                    highlight = "String"

                --
                -- Python - @overload
                elseif line_text:match("^%s*@overload") then
                    icon = " 󰡱 "
                    highlight = "Special"
                --
                -- Python - case dans match
                elseif line_text:match("^%s*case%s+") then
                    icon = " 󰃽 "
                    highlight = "Conditional"
                --
                -- Python - Union[]
                elseif line_text:match("Union%s*%[") then
                    icon = " 󰆧 "
                    highlight = "Type"
                --
                -- Python - Literal[]
                elseif line_text:match("Literal%s*%[") then
                    icon = " 󰅩 "
                    highlight = "Type"
                --
                -- Python - Attributs de classe
                elseif line_text:match("^%s+[%w_]+%s*:") or line_text:match("^%s+[%w_]+%s*=") then
                    icon = " 󰜢 "
                    highlight = "Identifier"
                --
                -- LaTeX - Environnements
                elseif line_text:match("\\begin%s*{") then
                    icon = " 󰙅 "
                    highlight = "Function"
                --
                -- LaTeX - Sections
                elseif line_text:match("\\(section|subsection|subsubsection|chapter|part)%s*{") then
                    icon = " 󰉫 "
                    highlight = "Title"
                -- LaTeX - Accolades génériques
                elseif line_text:match("{%s*$") then
                    icon = " 󰅲 "
                    highlight = "Delimiter"
                --
                -- LaTeX - Crochets
                elseif line_text:match("%[") then
                    icon = " 󰘨 "
                    highlight = "Special"
                elseif line_text:match("%[") then
                    icon = " 󰘨 "
                    highlight = "Special"
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

        -- Closing all folds initially but only once per buffer
        vim.api.nvim_create_autocmd("BufWinEnter", {
            pattern = "*.tex",
            callback = function(args)
                if not vim.b[args.buf].initial_fold_done then
                    vim.defer_fn(function()
                        if not vim.api.nvim_buf_is_valid(args.buf) then
                            return
                        end

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
                            end, 500) -- Délai plus long
                        end

                        vim.b[args.buf].initial_fold_done = true
                    end, 500)
                end
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
