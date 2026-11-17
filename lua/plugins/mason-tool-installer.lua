-- Installe et met à jour automatiquement les outils Mason utilisés par la config.
-- Ajouter ici tout nouvel outil (LSP, formatter, linter) avant de l'utiliser.
-- debugpy est géré séparément par mason-nvim-dap (lua/plugins/dap.lua).
local START_DELAY_MS = 3000 -- laisse Neovim finir de démarrer avant de vérifier
local CHECK_EVERY_HOURS = 24 -- au plus une vérification des mises à jour par jour

return {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    event = "VeryLazy",
    opts = {
        ensure_installed = {
            -- Serveurs LSP (lsp/*.lua)
            "lua-language-server",
            "pyright",
            "ruff",
            "bash-language-server",
            "clangd",
            "texlab",
            "ltex-ls",
            "neocmakelsp",
            "yaml-language-server",
            -- Formatters (lua/plugins/conform.lua) ; clang-format vient de LLVM (PATH)
            "stylua",
            "prettier",
            "beautysh",
            "snakefmt",
            "tex-fmt",
            "biome",
            "yamlfmt",
            "bibtex-tidy",
            -- Linters (lua/plugins/nvim-lint.lua)
            "shellcheck",
            "yamllint",
            "jsonlint",
        },
        auto_update = true,
        run_on_start = true,
        start_delay = START_DELAY_MS,
        debounce_hours = CHECK_EVERY_HOURS,
    },
}
