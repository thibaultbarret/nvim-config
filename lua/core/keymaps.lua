local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Nouveau buffer
map("n", "<leader>b", "<cmd>enew<CR>", { desc = "buffer new" })

-- Buffer suivant / précédent
map("n", "<Tab>", "<cmd>BufferLineCycleNext<CR>", { desc = "buffer goto next" })
map("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<CR>", { desc = "buffer goto prev" })

-- Fermer le buffer courant
map("n", "<leader>x", "<cmd>bdelete<CR>", { desc = "buffer close" })

-- Supprimer le surlignage
map("n", "<Esc>", "<cmd>noh<CR>", { desc = "general clear highlights" })

-- Copie complete du fichier
map("n", "<C-c>", "<cmd>%y+<CR>", { desc = "general copy whole file" })

map("n", "<C-s>", "<cmd>:w<CR>", { desc = "Save file" })
--
-- Copie du texte selectionne dans le clipboard

map("v", "<C-c>", function()
    vim.cmd('normal! "+y')
end, { desc = "copy selection to clipboard" })

-- Coller du texte depuis le clipboard
local function smart_paste_below()
    local mode = vim.fn.mode()
    if mode == "v" or mode == "V" or mode == "\22" then -- modes visual
        vim.cmd('normal! "+p')
    else -- mode normal
        vim.cmd('normal! "+p')
    end
end

local function smart_paste_above()
    local mode = vim.fn.mode()
    if mode == "v" or mode == "V" or mode == "\22" then -- modes visual
        vim.cmd('normal! "+p') -- en visual, P et p font la même chose
    else -- mode normal
        vim.cmd('normal! "+P')
    end
end

map({ "n", "v" }, "<C-p>", smart_paste_below, { desc = "paste from clipboard below" })
map({ "n", "v" }, "<C-P>", smart_paste_above, { desc = "paste from clipboard above" })

-- Commentaires
map("n", "<C-q>", "gcc", { desc = "toggle comment", remap = true })
map("v", "<C-q>", "gc", { desc = "toggle comment", remap = true })

-- Recherche centree
map("n", "n", "nzzzv", { desc = "Next search result (centered)" })
map("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })

-- Supprimer sans copier
-- map({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete without yanking" })

-- Tout selectionner
map({ "n" }, "<leader>aa", "ggVG", { desc = "Select all" })

-- Ouvrir fichier à partir du path dans un nouveau buffer
map("n", "<leader>ofb", function()
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2] + 1

    -- Cherche d'abord entre double quotes
    local s, e = line:find('"([^"]+)"', 1)
    local filename = nil

    while s do
        if col >= s and col <= e then
            filename = line:sub(s + 1, e - 1)
            break
        end
        s, e = line:find('"([^"]+)"', e + 1)
    end

    -- Si pas trouvé, cherche entre accolades
    if not filename then
        s, e = line:find("{([^}]+)}", 1)
        while s do
            if col >= s and col <= e then
                filename = line:sub(s + 1, e - 1)
                break
            end
            s, e = line:find("{([^}]+)}", e + 1)
        end
    end

    if filename then
        vim.cmd("edit " .. filename)
    else
        vim.notify("Aucun fichier trouvé sous le curseur", vim.log.levels.WARN)
    end
end, { desc = "Open file in new buffer" })

-- Ouvrir fichier à partir du path dans un split vertical
map("n", "<leader>ofvs", "yi{:vsplit <C-r>0<CR>", { desc = "Open file in vertical split" })

-- Remplacer le mot sous le curseur
map("n", "<leader>rew", function()
    -- Copie le mot sous le curseur
    vim.cmd("normal! yiw")
    -- Lance la substitution globale avec le mot copié
    local word = vim.fn.getreg("0")
    vim.api.nvim_feedkeys(
        ":%s/"
            .. vim.fn.escape(word, "/\\")
            .. "//g"
            .. string.rep(vim.api.nvim_replace_termcodes("<Left>", true, false, true), 2),
        "n",
        false
    )
end, { desc = "Remplacer le mot sous le curseur globalement" })

map("i", "<C-m>", function()
    vim.fn.feedkeys(vim.fn["copilot#Accept"](), "")
end, { desc = "Copilot Accept", noremap = true, silent = true })

map("t", "<C-;>", "<C-\\><C-n>", { desc = "Sortir du terminal" })

map("n", "gS", function()
    local line = vim.fn.getline(".")
    local parts = vim.split(line:gsub("^%s*", ""), ", ")
    local indent = line:match("^%s*")
    vim.fn.setline(".", indent .. parts[1] .. ",")
    for i = 2, #parts do
        vim.fn.append(vim.fn.line(".") + i - 2, indent .. parts[i] .. (i < #parts and "," or ""))
    end
end, { desc = "Split line on commas" })

-- Remplacer le mot sous le curseur sur la ligne
-- map("n", "rel", function()
-- 	-- Copie le mot sous le curseur
-- 	vim.cmd("normal! yiw")
-- 	-- Lance la substitution sur la ligne courante avec le mot copié
-- 	local word = vim.fn.getreg("0")
-- 	-- Utilise vim.fn.feedkeys pour s'assurer que l'autocomplétion fonctionne
-- 	vim.fn.feedkeys(":.s/" .. vim.fn.escape(word, "/\\") .. "//g" .. string.rep("\27[D", 2), "n")
-- end, { desc = "Remplacer le mot sous le curseur sur la ligne courante" })
--
--
map("v", "<leader>ct", function()
    local mode = vim.fn.mode()
    local start_pos = vim.fn.getpos("v")
    local end_pos = vim.fn.getpos(".")

    local start_col = math.min(start_pos[3], end_pos[3]) - 1
    local end_col = math.max(start_pos[3], end_pos[3])
    local start_row = math.min(start_pos[2], end_pos[2]) - 1
    local end_row = math.max(start_pos[2], end_pos[2]) - 1

    local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
    vim.api.nvim_feedkeys(esc, "x", false)

    -- Visual block mode (Ctrl+V = caractère \22)
    if mode == "\22" then
        local total_len = end_col - start_col

        for row = start_row, end_row do
            local line = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1]
            if not line then
                goto continue
            end

            -- Si la ligne est plus courte que le début du bloc, on l'ignore
            if #line <= start_col then
                goto continue
            end

            local actual_end = math.min(end_col, #line)
            local selected = line:sub(start_col + 1, actual_end)

            -- Compléter avec des espaces si la ligne ne couvre pas tout le bloc
            local block_content = selected .. string.rep(" ", total_len - #selected)

            local trimmed = block_content:match("^%s*(.-)%s*$")
            if trimmed == "" then
                goto continue
            end

            local padding = math.floor((total_len - #trimmed) / 2)
            local centered = string.rep(" ", padding) .. trimmed .. string.rep(" ", total_len - padding - #trimmed)

            vim.api.nvim_buf_set_text(0, row, start_col, row, actual_end, { centered })

            ::continue::
        end

    -- Visual mode classique (une seule ligne)
    else
        local row = start_row
        local line = vim.api.nvim_get_current_line()
        end_col = math.min(end_col, #line)

        local selected = line:sub(start_col + 1, end_col)
        local total_len = #selected
        local trimmed = selected:match("^%s*(.-)%s*$")
        if trimmed == "" then
            return
        end

        local padding = math.floor((total_len - #trimmed) / 2)
        local centered = string.rep(" ", padding) .. trimmed .. string.rep(" ", total_len - padding - #trimmed)

        vim.api.nvim_buf_set_text(0, row, start_col, row, end_col, { centered })
    end
end, { desc = "Center selected text with whitespace" })

local function find_ampersand_range(include_delimiters)
    local line = vim.api.nvim_get_current_line()
    local col = vim.fn.col(".")

    local start_col = nil
    for i = col, 1, -1 do
        if line:sub(i, i) == "&" then
            start_col = i + 1
            break
        end
    end

    local end_col = nil
    for i = col, #line do
        if line:sub(i, i) == "&" then
            end_col = i - 1
            break
        end
    end

    if not start_col or not end_col then
        return nil, nil
    end

    if include_delimiters then
        start_col = start_col - 1
        end_col = end_col + 1
    end

    return start_col, end_col
end

local function apply_range(start_col, end_col)
    local lnum = vim.fn.line(".")
    vim.fn.cursor(lnum, start_col)
    vim.cmd("normal! v")
    vim.fn.cursor(lnum, end_col)
end

local ESC = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)

-- Operator-pending (d, c, y...)
map("o", "i&", function()
    local s, e = find_ampersand_range(false)
    if s then
        apply_range(s, e)
    end
end, { desc = "Text object inside &" })

map("o", "a&", function()
    local s, e = find_ampersand_range(true)
    if s then
        apply_range(s, e)
    end
end, { desc = "Text object around &" })

-- Visual (v) — Esc synchrone avec le flag "x"
map("x", "i&", function()
    local s, e = find_ampersand_range(false)
    if not s then
        return
    end
    vim.api.nvim_feedkeys(ESC, "x", false) -- "x" = synchrone
    apply_range(s, e)
end, { desc = "Text object inside & (visual)" })

map("x", "a&", function()
    local s, e = find_ampersand_range(true)
    if not s then
        return
    end
    vim.api.nvim_feedkeys(ESC, "x", false)
    apply_range(s, e)
end, { desc = "Text object around & (visual)" })

local preview_win = nil
local preview_buf = nil

local function close_preview()
    if preview_win and vim.api.nvim_win_is_valid(preview_win) then
        vim.api.nvim_win_close(preview_win, true)
    end
end

local function extract_path()
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2] + 1

    for s, p, e in line:gmatch('()"(.-)"()') do
        if col >= s and col <= e then
            return vim.fn.fnamemodify(p, ":p")
        end
    end

    for s, p, e in line:gmatch("()'(.-)'()") do
        if col >= s and col <= e then
            return vim.fn.fnamemodify(p, ":p")
        end
    end

    return nil
end

local function open_floating(lines, title)
    close_preview()

    preview_buf = vim.api.nvim_create_buf(false, true)

    vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, lines)

    local width = 150
    local height = math.min(#lines, 20)

    preview_win = vim.api.nvim_open_win(preview_buf, true, {
        relative = "editor",
        row = 2,
        col = math.floor((vim.o.columns - width) / 2),
        width = width,
        height = height,
        style = "minimal",
        border = "rounded",
        title = title,
        title_pos = "center",
    })

    map("n", "q", close_preview, {
        buffer = preview_buf,
        silent = true,
    })
end

local function preview_file()
    local path = extract_path()

    if not path then
        vim.notify("No file path under cursor")
        return
    end

    if vim.fn.filereadable(path) == 0 then
        vim.notify("File not found: " .. path)
        return
    end

    local lines = vim.fn.readfile(path, "", 30)

    open_floating(lines, path)

    vim.bo[preview_buf].filetype = vim.filetype.match({ filename = path }) or ""
end

local function preview_header_columns()
    local path = extract_path()

    if not path then
        vim.notify("No file path under cursor")
        return
    end

    if vim.fn.filereadable(path) == 0 then
        vim.notify("File not found: " .. path)
        return
    end

    local first_line = vim.fn.readfile(path, "", 1)[1]

    if not first_line then
        vim.notify("Empty file")
        return
    end

    local columns = {}

    if first_line:find(";") then
        columns = vim.split(first_line, ";", { trimempty = true })
    elseif first_line:find(",") then
        columns = vim.split(first_line, ",", { trimempty = true })
    else
        for item in first_line:gmatch("%S+") do
            table.insert(columns, item)
        end
    end

    open_floating(columns, "Columns")
end

map("n", "<leader>sf", preview_file, {
    desc = "Preview file",
})

map("n", "<leader>sh", preview_header_columns, {
    desc = "Preview header columns",
})

map("n", "<leader>md", function()
    -- Récupère le contenu entre accolades autour du curseur
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2] + 1

    -- Cherche la paire d'accolades qui contient la position du curseur
    local content = nil
    local search_start = 1
    while true do
        local s, e = line:find("{[^{}]+}", search_start)
        if not s then
            break
        end
        if col >= s and col <= e then
            content = line:sub(s + 1, e - 1)
            break
        end
        search_start = e + 1
    end

    if not content then
        vim.notify("Aucun chemin trouvé entre accolades", vim.log.levels.WARN)
        return
    end

    -- Extrait le dossier parent
    local dir = vim.fn.fnamemodify(content, ":h")

    if dir == "." or dir == "" then
        vim.notify("Pas de dossier parent à créer pour : " .. content, vim.log.levels.WARN)
        return
    end

    -- Crée le dossier récursivement
    local ok = vim.fn.mkdir(dir, "p")
    if ok == 1 then
        vim.notify("Dossier créé : " .. dir, vim.log.levels.INFO)
    else
        -- Peut aussi retourner 0 si le dossier existe déjà (pas une erreur)
        if vim.fn.isdirectory(dir) == 1 then
            vim.notify("Dossier déjà existant : " .. dir, vim.log.levels.INFO)
        else
            vim.notify("Échec de la création : " .. dir, vim.log.levels.ERROR)
        end
    end
end, { desc = "mkdir: crée le dossier parent du chemin sous le curseur" })

map("n", "<leader>rd", function()
    -- Récupère le chemin entre accolades sous le curseur
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2] + 1

    local content = nil
    local search_start = 1
    while true do
        local s, e = line:find("{[^{}]+}", search_start)
        if not s then
            break
        end
        if col >= s and col <= e then
            content = line:sub(s + 1, e - 1)
            break
        end
        search_start = e + 1
    end

    if not content then
        vim.notify("Aucun chemin trouvé entre accolades", vim.log.levels.WARN)
        return
    end

    local old_path = vim.fn.fnamemodify(content, ":h")

    if old_path == "." or old_path == "" then
        vim.notify("Pas de dossier parent trouvé pour : " .. content, vim.log.levels.WARN)
        return
    end

    if vim.fn.isdirectory(old_path) == 0 then
        vim.notify("Dossier introuvable : " .. old_path, vim.log.levels.WARN)
    end

    -- Ouvre le floating window avec le chemin pré-rempli
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { old_path })
    vim.bo[buf].buftype = "nofile"

    local width = math.max(60, #old_path + 4)
    local win = vim.api.nvim_open_win(buf, true, {
        relative = "cursor",
        width = width,
        height = 1,
        row = 1,
        col = 0,
        style = "minimal",
        border = "rounded",
        title = " Renommer le dossier ",
        title_pos = "center",
    })
    vim.wo[win].winhl = "Normal:Normal,FloatBorder:DiagnosticInfo"

    -- Curseur en fin de ligne, mode normal
    vim.api.nvim_win_set_cursor(win, { 1, #old_path })

    local function do_rename()
        local new_path = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1]:gsub("/+$", "")
        vim.api.nvim_win_close(win, true)

        if new_path == "" or new_path == old_path then
            vim.notify("Renommage annulé", vim.log.levels.INFO)
            return
        end

        local parent = vim.fn.fnamemodify(new_path, ":h")
        if parent ~= "." and vim.fn.isdirectory(parent) == 0 then
            vim.fn.mkdir(parent, "p")
        end

        local ok, err = vim.loop.fs_rename(old_path, new_path)
        if ok then
            vim.notify(old_path .. "  →  " .. new_path, vim.log.levels.INFO)
        else
            vim.notify("Échec : " .. (err or "erreur inconnue"), vim.log.levels.ERROR)
        end
    end

    local function do_cancel()
        vim.api.nvim_win_close(win, true)
        vim.notify("Renommage annulé", vim.log.levels.INFO)
    end

    local opts = { buffer = buf, nowait = true }
    vim.keymap.set("n", "<CR>", do_rename, opts)
    vim.keymap.set("n", "q", do_cancel, opts)
    vim.keymap.set("n", "<Esc>", do_cancel, opts)
end, { desc = "Renommer le dossier du chemin sous le curseur" })
