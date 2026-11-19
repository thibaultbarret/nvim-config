---@type vim.lsp.Config

-- Résout l'interpréteur à utiliser pour un root donné.
-- Priorité : venv local au projet > environnement activé dans le shell > échec bruyant.
local function resolve_python(root)
    -- 1. venv local au projet (le plus correct : chaque projet son environnement)
    for _, name in ipairs({ ".venv", "venv", ".env", "env" }) do
        local py = root .. "/" .. name .. "/bin/python"
        if vim.uv.fs_stat(py) then
            return py
        end
    end
    -- 2. environnement activé avant le lancement de nvim (venv ou conda)
    local venv = vim.env.VIRTUAL_ENV or vim.env.CONDA_PREFIX
    if venv then
        local py = venv .. "/bin/python"
        if vim.uv.fs_stat(py) then
            return py
        end
    end
    -- 3. rien trouvé : pyright tomberait sur le python système (tiers manquants)
    return nil
end

return {
    cmd = { "pyright-langserver", "--stdio" },
    filetypes = { "python" },

    -- Tiers priorisés : les marqueurs de racine projet sont cherchés sur tout
    -- l'arbre avant de se rabattre sur des marqueurs faibles présents dans les
    -- sous-dossiers (requirements.txt), pour ne pas enraciner sur le module.
    root_markers = {
        { "pyrightconfig.json", "pyproject.toml" },
        "setup.py",
        ".git",
        "requirements.txt",
    },

    before_init = function(_, config)
        local root = config.root_dir or vim.fn.getcwd()
        local py = resolve_python(root)
        config.settings.python = config.settings.python or {}
        if py then
            config.settings.python.pythonPath = py
        else
            vim.notify("pyright : aucun venv résolu sous " .. root .. " → python système", vim.log.levels.WARN)
        end
    end,

    settings = {
        python = {
            -- pythonPath est injecté par before_init.
            analysis = {
                autoSearchPaths = true,
                diagnosticMode = "openFilesOnly",
                useLibraryCodeForTypes = true,
                typeCheckingMode = "basic",
                autoImportCompletions = true,
                completeFunctionParens = true,
                includePackageImportsInAutoImports = true,
                indexing = true,
                -- Layout src : décommente si ton package vit sous src/
                -- extraPaths = { "src" },
            },
        },
    },
}
