return {
    cmd = { "yaml-language-server", "--stdio" },
    filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab", "yaml.helm-values" },
    root_markers = { ".git" },
    settings = {
        redhat = { telemetry = { enabled = false } },
        yaml = {
            validate = true,
            keyOrdering = false,
            format = { enable = false }, -- formatage délégué à conform (yamlfmt)
            -- Catalogue intégré par défaut ; remplacé par SchemaStore.nvim s'il est installé
            schemaStore = { enable = true },
        },
    },
    -- Résolu au lancement du serveur (pas au chargement du fichier) : depuis
    -- Neovim 0.12, vim.lsp.enable lit cette config au démarrage, avant lazy.nvim.
    before_init = function(_, config)
        local ok, schemastore = pcall(require, "schemastore")
        if not ok then
            return
        end
        config.settings.yaml.schemaStore = { enable = false, url = "" }
        config.settings.yaml.schemas = schemastore.yaml.schemas()
    end,
}
