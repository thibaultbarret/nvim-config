-- Fonction pour ajouter la date du jour dans journaling.md
local function add_date_to_journaling()
    -- Vérifier si le fichier actuel est journaling.md
    local filename = vim.fn.expand("%:t")
    if filename ~= "journaling.md" then
        return
    end

    -- Obtenir la date du jour au format YYYY/MM/DD
    local today = os.date("%Y/%m/%d")

    -- Lire tout le contenu du fichier
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

    -- Vérifier si le fichier est vide ou contient seulement des lignes vides
    local is_empty = true
    for _, line in ipairs(lines) do
        if line ~= "" then
            is_empty = false
            break
        end
    end

    -- Si le fichier est vide, ajouter l'en-tête YAML
    if is_empty then
        -- Obtenir la date de création du fichier
        local filepath = vim.fn.expand("%:p")
        local creation_date

        -- Essayer d'obtenir la date de création (birth time)
        local stat = vim.loop.fs_stat(filepath)
        if stat and stat.birthtime and stat.birthtime.sec > 0 then
            creation_date = os.date("%Y-%m-%d", stat.birthtime.sec)
        else
            -- Si birthtime n'est pas disponible, utiliser la date du jour
            creation_date = os.date("%Y-%m-%d")
        end

        local yaml_header = {
            "---",
            "title: Journal",
            "date: " .. creation_date,
            "tags: [journal]",
            "---",
            "",
        }
        vim.api.nvim_buf_set_lines(0, 0, 0, false, yaml_header)
        lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    end

    -- Vérifier si la date du jour existe déjà
    local date_exists = false
    for _, line in ipairs(lines) do
        if line:match(today) then
            date_exists = true
            break
        end
    end

    -- Si la date n'existe pas, l'ajouter
    if not date_exists then
        -- Ajouter la date à la fin du fichier avec une ligne vide avant
        local last_line = #lines
        if last_line > 0 and lines[last_line] ~= "" then
            vim.api.nvim_buf_set_lines(0, last_line, last_line, false, { "" })
            last_line = last_line + 1
        end

        -- Ajouter la date en titre niveau 1 et une ligne avec tiret
        vim.api.nvim_buf_set_lines(0, last_line, last_line, false, { "# " .. today, "- " })

        -- Positionner le curseur à la fin de la ligne avec le tiret
        vim.api.nvim_win_set_cursor(0, { last_line + 2, 2 })

        -- Passer en mode insertion
        vim.cmd("startinsert!")
    end
end

-- Créer un autocommand qui s'exécute à l'ouverture du fichier
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
    pattern = "journaling.md",
    callback = add_date_to_journaling,
    desc = "Ajouter la date du jour dans journaling.md",
})
