return {
    "kevinhwang91/nvim-ufo",
    dependencies = {
        "kevinhwang91/promise-async",
        "luukvbaal/statuscol.nvim", -- Optionnel mais améliore l'affichage
    },
    event = "BufReadPost",
    config = function()
        -- Configuration des options de fold
        vim.o.foldcolumn = "1" -- Colonne pour les indicateurs de fold
        vim.o.foldlevel = 99 -- Niveau de fold initial (tout ouvert)
        vim.o.foldlevelstart = 99
        vim.o.foldenable = true

        -- Fonction personnalisée pour détecter les Literal[] et Union[] en Python
        local function python_literal_provider(bufnr)
            local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
            local folds = {}
            local i = 1

            while i <= #lines do
                local line = lines[i]
                -- Détecte les patterns Literal[] ou Union[] avec gestion des multilignes
                local pattern_type = nil
                if line:match("Literal%s*%[") then
                    pattern_type = "literal"
                elseif line:match("Union%s*%[") then
                    pattern_type = "union"
                end

                if pattern_type then
                    local start_line = i - 1 -- 0-indexé pour nvim-ufo
                    local bracket_count = 0
                    local in_string = false
                    local string_char = nil
                    local j = i

                    -- Compte les crochets ouvrants et fermants pour gérer le multiligne
                    while j <= #lines do
                        local current_line = lines[j]
                        local pos = 1

                        while pos <= #current_line do
                            local char = current_line:sub(pos, pos)

                            -- Gestion des chaînes de caractères
                            if not in_string and (char == '"' or char == "'") then
                                in_string = true
                                string_char = char
                            elseif in_string and char == string_char then
                                -- Vérifier si ce n'est pas échappé
                                local escape_count = 0
                                local check_pos = pos - 1
                                while check_pos > 0 and current_line:sub(check_pos, check_pos) == "\\" do
                                    escape_count = escape_count + 1
                                    check_pos = check_pos - 1
                                end
                                if escape_count % 2 == 0 then
                                    in_string = false
                                    string_char = nil
                                end
                            end

                            -- Ne compter les crochets que si on n'est pas dans une chaîne
                            if not in_string then
                                if char == "[" then
                                    bracket_count = bracket_count + 1
                                elseif char == "]" then
                                    bracket_count = bracket_count - 1
                                    if bracket_count == 0 then
                                        -- Fin du Literal/Union trouvée
                                        table.insert(folds, {
                                            startLine = start_line,
                                            endLine = j - 1, -- 0-indexé
                                            kind = pattern_type,
                                        })
                                        i = j
                                        goto continue
                                    end
                                end
                            end

                            pos = pos + 1
                        end

                        -- Reset string state at end of line if not closed
                        if in_string then
                            in_string = false
                            string_char = nil
                        end

                        j = j + 1

                        -- Protection contre les boucles infinies (augmentée pour les gros Union)
                        if j - i > 200 then
                            break
                        end
                    end

                    ::continue::
                end
                i = i + 1
            end

            return folds
        end

        -- Fonction personnalisée pour détecter les attributs de classe Python
        local function python_class_attributes_provider(bufnr)
            local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
            local folds = {}
            local i = 1

            while i <= #lines do
                local line = lines[i]

                -- Détecte le début d'une classe
                if line:match("^class%s+") then
                    local j = i + 1
                    local attributes_start = nil
                    local attributes_end = nil
                    local base_indent = nil
                    local in_docstring = false
                    local docstring_delimiter = nil

                    -- Cherche les attributs dans la classe
                    while j <= #lines do
                        local current_line = lines[j]

                        -- Gestion des docstrings
                        if not in_docstring then
                            local triple_quote = current_line:match('"""') or current_line:match("'''")
                            if triple_quote then
                                docstring_delimiter = triple_quote == '"""' and '"""' or "'''"
                                in_docstring = true
                                -- Check if docstring ends on same line
                                local rest_of_line = current_line:match(docstring_delimiter .. "(.*)")
                                if rest_of_line and rest_of_line:match(docstring_delimiter) then
                                    in_docstring = false
                                end
                            end
                        elseif current_line:match(docstring_delimiter) then
                            in_docstring = false
                        end

                        -- Skip si on est dans un docstring
                        if in_docstring then
                            j = j + 1
                            goto continue_search
                        end

                        -- Skip les lignes vides et les commentaires
                        if current_line:match("^%s*$") or current_line:match("^%s*#") then
                            j = j + 1
                            goto continue_search
                        end

                        -- Détermine l'indentation de base de la classe
                        if not base_indent then
                            local indent = current_line:match("^(%s*)")
                            if #indent > 0 then
                                base_indent = #indent
                            else
                                j = j + 1
                                goto continue_search
                            end
                        end

                        -- Vérifier si on est toujours dans la classe
                        local current_indent = current_line:match("^(%s*)")
                        if #current_indent < base_indent then
                            -- On est sorti de la classe
                            break
                        elseif #current_indent == base_indent then
                            -- Même niveau d'indentation que la classe - on cherche les attributs

                            -- Attributs avec underscores, types complexes
                            local is_attribute = current_line:match("^%s+[%w_]+%s*:")
                                or current_line:match("^%s+[%w_]+%s*=")

                            -- Méthodes et autres constructs à ignorer
                            local is_method_or_other = current_line:match("^%s+def%s")
                                or current_line:match("^%s+class%s")
                                or current_line:match("^%s+@")
                                or current_line:match("^%s+if%s")
                                or current_line:match("^%s+for%s")
                                or current_line:match("^%s+while%s")
                                or current_line:match("^%s+with%s")
                                or current_line:match("^%s+try%s")
                                or current_line:match("^%s+async%s+def%s")
                                or current_line:match("^%s+property%s")

                            if is_attribute and not is_method_or_other then
                                if not attributes_start then
                                    attributes_start = j - 1 -- 0-indexé
                                end
                                -- Continue à étendre la fin tant qu'on trouve des attributs
                                attributes_end = j - 1
                            elseif attributes_start then
                                -- On a des attributs et on rencontre autre chose
                                if is_method_or_other then
                                    -- C'est une méthode, on termine le fold des attributs
                                    if attributes_end and attributes_end > attributes_start then
                                        table.insert(folds, {
                                            startLine = attributes_start,
                                            endLine = attributes_end,
                                            kind = "attributes",
                                        })
                                    end
                                    break
                                end
                                -- Sinon on continue (peut-être une ligne vide ou un commentaire)
                            end
                        end

                        j = j + 1
                        if j - i > 100 then
                            break
                        end -- Protection

                        ::continue_search::
                    end

                    -- Ajouter le fold si on arrive à la fin avec des attributs
                    if attributes_start and attributes_end and attributes_end > attributes_start then
                        table.insert(folds, {
                            startLine = attributes_start,
                            endLine = attributes_end,
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

        -- Fonction personnalisée pour détecter les groupes @overload en Python
        local function python_overload_provider(bufnr)
            local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
            local folds = {}
            local i = 1

            while i <= #lines do
                local line = lines[i]

                -- Détecte le début d'un groupe @overload
                if line:match("^%s*@overload%s*$") then
                    local overload_start = i - 1 -- 0-indexé
                    local base_indent = line:match("^(%s*)")
                    local j = i
                    local last_overload_end = nil

                    -- Cherche tous les overloads consécutifs
                    while j <= #lines do
                        local current_line = lines[j]

                        -- Skip les lignes vides et commentaires
                        if current_line:match("^%s*$") or current_line:match("^%s*#") then
                            j = j + 1
                            goto continue_overload
                        end

                        local current_indent = current_line:match("^(%s*)")

                        -- Si l'indentation est différente du niveau de base, on continue
                        if #current_indent ~= #base_indent then
                            j = j + 1
                            goto continue_overload
                        end

                        -- Vérifie si c'est un autre @overload
                        if current_line:match("^%s*@overload%s*$") then
                            -- Trouve la fin de ce @overload (sa fonction def associée)
                            local k = j + 1
                            while k <= #lines do
                                local overload_line = lines[k]

                                if overload_line:match("^%s*$") or overload_line:match("^%s*#") then
                                    k = k + 1
                                    goto continue_overload_search
                                end

                                -- Si on trouve la définition de fonction pour cet overload
                                if overload_line:match("^%s*def%s+") then
                                    -- Trouve la fin de cette définition (en gros jusqu'à "..." ou fin de params)
                                    while k <= #lines do
                                        local def_line = lines[k]
                                        if def_line:match("%.%.%.") or def_line:match("->.*:") then
                                            last_overload_end = k - 1 -- 0-indexé
                                            break
                                        end
                                        k = k + 1
                                        if k - j > 20 then
                                            break
                                        end -- Protection
                                    end
                                    break
                                end

                                k = k + 1
                                if k - j > 20 then
                                    break
                                end -- Protection

                                ::continue_overload_search::
                            end

                            j = k + 1
                            goto continue_overload
                        end

                        -- Vérifie si c'est une définition de fonction sans @overload
                        if current_line:match("^%s*def%s+") then
                            -- C'est probablement l'implémentation finale, on s'arrête
                            break
                        end

                        -- Si on rencontre autre chose qu'un @overload ou def à ce niveau, on s'arrête
                        if not current_line:match("^%s*@") then
                            break
                        end

                        j = j + 1

                        -- Protection contre les boucles infinies
                        if j - i > 200 then
                            break
                        end

                        ::continue_overload::
                    end

                    -- Si on a trouvé au moins un overload complet, on crée le fold
                    if last_overload_end and last_overload_end > overload_start then
                        table.insert(folds, {
                            startLine = overload_start,
                            endLine = last_overload_end,
                            kind = "overload",
                        })
                        i = j
                    else
                        i = i + 1
                    end
                else
                    i = i + 1
                end
            end

            return folds
        end

        -- Fonction personnalisée pour détecter les blocs case dans match statements Python
        local function python_match_case_provider(bufnr)
            local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
            local folds = {}
            local i = 1

            while i <= #lines do
                local line = lines[i]

                -- Détecte un statement match
                if line:match("^%s*match%s+") then
                    local j = i + 1
                    local match_indent = line:match("^(%s*)")

                    -- Cherche les blocs case dans ce match
                    while j <= #lines do
                        local current_line = lines[j]

                        -- Skip les lignes vides et commentaires
                        if current_line:match("^%s*$") or current_line:match("^%s*#") then
                            j = j + 1
                            goto continue_match
                        end

                        local current_indent = current_line:match("^(%s*)")

                        -- Si on sort du bloc match (indentation égale ou moindre)
                        if #current_indent <= #match_indent then
                            break
                        end

                        -- Détecte un bloc case
                        if current_line:match("^%s*case%s+") then
                            local case_start = j - 1 -- 0-indexé
                            local case_indent = current_indent
                            local k = j + 1
                            local case_end = j - 1

                            -- Trouve la fin du bloc case
                            while k <= #lines do
                                local case_line = lines[k]

                                -- Skip les lignes vides
                                if case_line:match("^%s*$") then
                                    k = k + 1
                                    goto continue_case
                                end

                                local case_line_indent = case_line:match("^(%s*)")

                                -- Si on rencontre un autre case ou on sort du match
                                if
                                    #case_line_indent <= #case_indent
                                    and (case_line:match("^%s*case%s+") or #case_line_indent <= #match_indent)
                                then
                                    break
                                end

                                -- Si la ligne est plus indentée ou au même niveau que le contenu du case
                                if #case_line_indent > #case_indent or case_line:match("^%s*#") then
                                    case_end = k - 1
                                end

                                k = k + 1

                                -- Protection
                                if k - j > 100 then
                                    break
                                end

                                ::continue_case::
                            end

                            -- Créer le fold pour ce case si il a du contenu
                            if case_end > case_start then
                                table.insert(folds, {
                                    startLine = case_start,
                                    endLine = case_end,
                                    kind = "case",
                                })
                            end

                            j = k
                        else
                            j = j + 1
                        end

                        -- Protection
                        if j - i > 200 then
                            break
                        end

                        ::continue_match::
                    end

                    i = j
                else
                    i = i + 1
                end
            end

            return folds
        end

        -- Fonction personnalisée pour détecter les accolades dans les fichiers .tex
        local function tex_braces_provider(bufnr)
            local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
            local folds = {}
            local i = 1

            while i <= #lines do
                local line = lines[i]

                -- Détecte les environnements LaTeX \begin{} ... \end{}
                local env_begin = line:match("\\begin%s*{([^}]+)}")
                if env_begin then
                    local start_line = i - 1
                    local j = i + 1
                    local end_pattern = "\\end%s*{" .. env_begin:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1") .. "}"

                    while j <= #lines do
                        if lines[j]:match(end_pattern) then
                            table.insert(folds, {
                                startLine = start_line,
                                endLine = j - 1,
                                kind = "environment",
                            })
                            i = j
                            goto continue_env
                        end
                        j = j + 1
                        if j - i > 200 then
                            break
                        end -- Protection
                    end
                    ::continue_env::
                end

                -- Détecte les sections avec contenu long entre accolades
                local section_match = line:match("\\(section|subsection|subsubsection|chapter|part)%s*{")
                if section_match then
                    local start_line = i - 1
                    local brace_count = 0
                    local found_opening = false
                    local j = i

                    while j <= #lines do
                        local current_line = lines[j]
                        local pos = 1

                        while pos <= #current_line do
                            local char = current_line:sub(pos, pos)
                            if char == "{" then
                                brace_count = brace_count + 1
                                found_opening = true
                            elseif char == "}" and found_opening then
                                brace_count = brace_count - 1
                                if brace_count == 0 then
                                    -- Seulement folder si c'est multiligne
                                    if j > i then
                                        table.insert(folds, {
                                            startLine = start_line,
                                            endLine = j - 1,
                                            kind = "section",
                                        })
                                    end
                                    i = j
                                    goto continue_section
                                end
                            elseif char == "\\" and pos < #current_line then
                                -- Skip les accolades échappées
                                pos = pos + 1
                            end
                            pos = pos + 1
                        end
                        j = j + 1
                        if j - i > 100 then
                            break
                        end -- Protection
                    end
                    ::continue_section::
                end

                -- Détecte les groupes d'accolades multilignes (minimum 3 lignes)
                if line:match("{%s*$") then -- Ligne qui se termine par une accolade ouvrante
                    local start_line = i - 1
                    local brace_count = 1
                    local j = i + 1

                    while j <= #lines and brace_count > 0 do
                        local current_line = lines[j]
                        local pos = 1

                        while pos <= #current_line do
                            local char = current_line:sub(pos, pos)
                            if char == "{" then
                                brace_count = brace_count + 1
                            elseif char == "}" then
                                brace_count = brace_count - 1
                                if brace_count == 0 then
                                    -- Seulement folder si c'est assez long (minimum 3 lignes)
                                    if j - i >= 2 then
                                        table.insert(folds, {
                                            startLine = start_line,
                                            endLine = j - 1,
                                            kind = "braces",
                                        })
                                    end
                                    i = j
                                    goto continue_braces
                                end
                            elseif char == "\\" and pos < #current_line then
                                -- Skip les accolades échappées
                                pos = pos + 1
                            end
                            pos = pos + 1
                        end
                        j = j + 1
                        if j - i > 50 then
                            break
                        end -- Protection
                    end
                    ::continue_braces::
                end

                i = i + 1
            end

            return folds
        end

        -- Nouvelle fonction pour détecter les crochets dans les fichiers .tex
        local function tex_brackets_provider(bufnr)
            local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
            local folds = {}
            local i = 1

            while i <= #lines do
                local line = lines[i]

                -- Détecte les groupes de crochets multilignes (minimum 2 lignes)
                -- Recherche une ligne contenant un crochet ouvrant
                local bracket_start_pos = line:find("%[")
                if bracket_start_pos then
                    local start_line = i - 1 -- 0-indexé pour nvim-ufo
                    local bracket_count = 0
                    local j = i
                    local found_opening = false

                    -- Analyse le contenu pour compter les crochets
                    while j <= #lines do
                        local current_line = lines[j]
                        local pos = 1

                        while pos <= #current_line do
                            local char = current_line:sub(pos, pos)

                            -- Ignore les crochets échappés
                            if char == "\\" and pos < #current_line then
                                pos = pos + 1 -- Skip le caractère suivant
                            elseif char == "[" then
                                bracket_count = bracket_count + 1
                                found_opening = true
                            elseif char == "]" and found_opening then
                                bracket_count = bracket_count - 1

                                -- Si on ferme complètement le groupe de crochets
                                if bracket_count == 0 then
                                    -- Créer le fold seulement si c'est multiligne
                                    if j > i then
                                        table.insert(folds, {
                                            startLine = start_line,
                                            endLine = j - 1,
                                            kind = "brackets",
                                        })
                                    end
                                    i = j
                                    goto continue_brackets
                                end
                            end

                            pos = pos + 1
                        end

                        j = j + 1

                        -- Protection contre les boucles infinies
                        if j - i > 100 then
                            break
                        end
                    end

                    ::continue_brackets::
                end

                i = i + 1
            end

            return folds
        end

        -- Fonction améliorée de provider_selector
        local function enhanced_provider_selector(bufnr, filetype, buftype)
            if filetype == "python" then
                return function(bufnr)
                    -- Combine treesitter, LSP et nos détections custom
                    local treesitter_folds = require("ufo.provider.treesitter").getFolds(bufnr) or {}
                    local literal_folds = python_literal_provider(bufnr) or {}
                    local attributes_folds = python_class_attributes_provider(bufnr) or {}
                    local overload_folds = python_overload_provider(bufnr) or {}
                    local match_case_folds = python_match_case_provider(bufnr) or {}

                    -- Fusionne tous les types de folds
                    local all_folds = {}
                    for _, fold in ipairs(treesitter_folds) do
                        table.insert(all_folds, fold)
                    end
                    for _, fold in ipairs(literal_folds) do
                        table.insert(all_folds, fold)
                    end
                    for _, fold in ipairs(attributes_folds) do
                        table.insert(all_folds, fold)
                    end
                    for _, fold in ipairs(overload_folds) do
                        table.insert(all_folds, fold)
                    end
                    for _, fold in ipairs(match_case_folds) do
                        table.insert(all_folds, fold)
                    end

                    return all_folds
                end
            elseif filetype == "tex" or filetype == "latex" then
                return function(bufnr)
                    -- Combine treesitter et nos détections custom des accolades et crochets LaTeX
                    local treesitter_folds = require("ufo.provider.treesitter").getFolds(bufnr) or {}
                    local tex_braces_folds = tex_braces_provider(bufnr) or {}
                    local tex_brackets_folds = tex_brackets_provider(bufnr) or {}

                    -- Fusionne les trois types de folds
                    local all_folds = {}
                    for _, fold in ipairs(treesitter_folds) do
                        table.insert(all_folds, fold)
                    end
                    for _, fold in ipairs(tex_braces_folds) do
                        table.insert(all_folds, fold)
                    end
                    for _, fold in ipairs(tex_brackets_folds) do
                        table.insert(all_folds, fold)
                    end

                    return all_folds
                end
            else
                -- Configuration par défaut pour les autres types de fichiers
                local ft_map = {
                    lua = { "treesitter" },
                    vim = "indent",
                    git = "",
                }
                return ft_map[filetype] or { "treesitter", "indent" }
            end
        end

        -- Configuration nvim-ufo
        require("ufo").setup({
            provider_selector = enhanced_provider_selector,

            -- Configuration des icônes de fold avec indication du type
            fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
                local newVirtText = {}

                -- Détecte le type de fold pour personnaliser l'affichage
                local line_text = vim.api.nvim_buf_get_lines(0, lnum, lnum + 1, false)[1] or ""
                local icon = " 󰁂 "
                local highlight = "MoreMsg"

                -- Python - @overload
                if line_text:match("^%s*@overload") then
                    icon = " 󰡱 "
                    highlight = "Special"
                -- Python - case dans match
                elseif line_text:match("^%s*case%s+") then
                    icon = " 󰃽 "
                    highlight = "Conditional"
                -- Python - Union[]
                elseif line_text:match("Union%s*%[") then
                    icon = " 󰆧 "
                    highlight = "Type"
                -- Python - Literal[]
                elseif line_text:match("Literal%s*%[") then
                    icon = " 󰅩 "
                    highlight = "Type"
                -- Python - Attributs de classe
                elseif line_text:match("^%s+[%w_]+%s*:") or line_text:match("^%s+[%w_]+%s*=") then
                    icon = " 󰜢 "
                    highlight = "Identifier"
                -- LaTeX - Environnements
                elseif line_text:match("\\begin%s*{") then
                    icon = " 󰙅 "
                    highlight = "Function"
                -- LaTeX - Sections
                elseif line_text:match("\\(section|subsection|subsubsection|chapter|part)%s*{") then
                    icon = " 󰉫 "
                    highlight = "Title"
                -- LaTeX - Accolades génériques
                elseif line_text:match("{%s*$") then
                    icon = " 󰅲 "
                    highlight = "Delimiter"
                -- LaTeX - Crochets
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

        -- Keymaps pour les folds (conservés de la configuration originale)
        vim.keymap.set("n", "zR", require("ufo").openAllFolds, { desc = "Open all folds" })
        vim.keymap.set("n", "zM", require("ufo").closeAllFolds, { desc = "Close all folds" })
        vim.keymap.set("n", "zr", require("ufo").openFoldsExceptKinds, { desc = "Open folds except kinds" })
        vim.keymap.set("n", "zm", require("ufo").closeFoldsWith, { desc = "Close folds with" })
        vim.keymap.set("n", "zK", function()
            local winid = require("ufo").peekFoldedLinesUnderCursor()
            if not winid then
                vim.lsp.buf.hover()
            end
        end, { desc = "Peek fold or LSP hover" })

        -- Fold par type spécifique (conservés de la configuration originale)
        vim.keymap.set("n", "<leader>zf", function()
            require("ufo").closeFoldsWith("function")
        end, { desc = "Fold functions" })

        vim.keymap.set("n", "<leader>zc", function()
            require("ufo").closeFoldsWith("class")
        end, { desc = "Fold classes" })

        vim.keymap.set("n", "<leader>zi", function()
            require("ufo").closeFoldsWith("import")
        end, { desc = "Fold imports" })
    end,
}
