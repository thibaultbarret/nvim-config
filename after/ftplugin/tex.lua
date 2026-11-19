vim.opt_local.conceallevel = 2
vim.opt_local.concealcursor = "n" -- reste "plié" même quand le curseur est sur la ligne

local ns = vim.api.nvim_create_namespace("label_fold")

-- Commandes dont on replie le contenu entre accolades
local commands = { "\\label{", "\\ref{" }

-- Trouve la prochaine commande (la plus proche) à partir de `init`
-- Renvoie : position du '\' (1-indexée) et position du '{' (1-indexée)
local function find_next_command(line, init)
    local best_s, best_open
    for _, cmd in ipairs(commands) do
        local s = line:find(cmd, init, true) -- recherche littérale (pas un pattern)
        if s and (not best_s or s < best_s) then
            best_s = s
            best_open = s + #cmd - 1 -- position du '{'
        end
    end
    return best_s, best_open
end

-- Replie toutes les commandes ciblées d'une ligne (gère plusieurs occurrences)
local function fold_labels_in_line(bufnr, row, line)
    local count = 0
    local init = 1
    while true do
        local s, open = find_next_command(line, init)
        if not s then
            break
        end
        local close = line:find("}", open, true)
        if not close then
            break
        end

        vim.api.nvim_buf_set_extmark(bufnr, ns, row, open, { -- après '{'
            end_col = close - 1, -- avant '}'
            conceal = "…",
        })
        count = count + 1
        init = close + 1
    end
    return count
end

-- Toggle d'une seule commande : celle sous le curseur
local function toggle_label_fold()
    local bufnr = 0
    local row = vim.api.nvim_win_get_cursor(0)[1] - 1
    local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1]

    local marks = vim.api.nvim_buf_get_extmarks(bufnr, ns, { row, 0 }, { row, -1 }, {})
    if #marks > 0 then
        for _, m in ipairs(marks) do
            vim.api.nvim_buf_del_extmark(bufnr, ns, m[1])
        end
        return
    end

    if fold_labels_in_line(bufnr, row, line) == 0 then
        vim.notify("Pas de \\label ou \\ref sur cette ligne")
    end
end

-- Toggle global : tout replier, ou tout déplier si au moins un pli existe déjà
local function toggle_all_label_folds()
    local bufnr = 0
    local existing = vim.api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, {})

    if #existing > 0 then
        vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
        return
    end

    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local total = 0
    for i, line in ipairs(lines) do
        total = total + fold_labels_in_line(bufnr, i - 1, line)
    end
    vim.notify(("%d référence(s) repliée(s)"):format(total))
end

vim.keymap.set("n", "<leader>zl", toggle_label_fold, { buffer = true, desc = "Toggle fold label/ref" })
vim.keymap.set(
    "n",
    "<leader>zL",
    toggle_all_label_folds,
    { buffer = true, desc = "Toggle fold de tous les labels/refs" }
)
