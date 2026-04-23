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
vim.keymap.set("v", "<leader>ct", function()
    -- Capturer les positions PENDANT le mode visuel
    local start_pos = vim.fn.getpos("v")
    local end_pos = vim.fn.getpos(".")

    -- Normaliser (au cas où la sélection est faite de droite à gauche)
    local start_col = math.min(start_pos[3], end_pos[3]) - 1
    local end_col = math.max(start_pos[3], end_pos[3])
    local row = start_pos[2] - 1

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

    -- Quitter le mode visuel avant d'écrire
    local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
    vim.api.nvim_feedkeys(esc, "x", false)

    vim.api.nvim_buf_set_text(0, row, start_col, row, end_col, { centered })
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
vim.keymap.set("o", "i&", function()
    local s, e = find_ampersand_range(false)
    if s then
        apply_range(s, e)
    end
end, { desc = "Text object inside &" })

vim.keymap.set("o", "a&", function()
    local s, e = find_ampersand_range(true)
    if s then
        apply_range(s, e)
    end
end, { desc = "Text object around &" })

-- Visual (v) — Esc synchrone avec le flag "x"
vim.keymap.set("x", "i&", function()
    local s, e = find_ampersand_range(false)
    if not s then
        return
    end
    vim.api.nvim_feedkeys(ESC, "x", false) -- "x" = synchrone
    apply_range(s, e)
end, { desc = "Text object inside & (visual)" })

vim.keymap.set("x", "a&", function()
    local s, e = find_ampersand_range(true)
    if not s then
        return
    end
    vim.api.nvim_feedkeys(ESC, "x", false)
    apply_range(s, e)
end, { desc = "Text object around & (visual)" })
