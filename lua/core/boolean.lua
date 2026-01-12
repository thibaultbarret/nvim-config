local function toggle_boolean()
    local ft = vim.bo.filetype
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2] + 1

    -- Déterminer les patterns selon le type de fichier
    local patterns
    if ft == "python" then
        patterns = {
            { from = "True", to = "False" },
            { from = "False", to = "True" },
        }
    elseif ft == "tex" or ft == "latex" then
        patterns = {
            { from = "true", to = "false" },
            { from = "false", to = "true" },
        }
    else
        -- Par défaut, essayer les deux formats
        patterns = {
            { from = "True", to = "False" },
            { from = "False", to = "True" },
            { from = "true", to = "false" },
            { from = "false", to = "true" },
        }
    end

    -- Chercher et remplacer le mot sous le curseur ou à proximité
    for _, pattern in ipairs(patterns) do
        local start_idx = line:find(pattern.from, 1, true)
        while start_idx do
            local end_idx = start_idx + #pattern.from - 1
            -- Vérifier si le curseur est sur ce mot
            if col >= start_idx and col <= end_idx then
                local new_line = line:sub(1, start_idx - 1) .. pattern.to .. line:sub(end_idx + 1)
                vim.api.nvim_set_current_line(new_line)
                return
            end
            start_idx = line:find(pattern.from, end_idx + 1, true)
        end
    end

    print("Aucun booléen trouvé sous le curseur")
end

-- Créer la commande utilisateur
vim.api.nvim_create_user_command("ToggleBool", toggle_boolean, {})

-- Optionnel : créer un mapping clavier (par exemple <leader>tb)
vim.keymap.set("n", "<leader>tb", toggle_boolean, { desc = "Toggle boolean True/False" })
