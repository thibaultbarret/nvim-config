---@type vim.lsp.Config
return {
    cmd = { "ruff", "server" },
    filetypes = { "python" },
    root_markers = {
        "ruff.toml",
        { "pyproject.toml", "pyrightconfig.json" },
        "uv.lock",
        ".git",
    },
    init_options = {
        settings = {
            -- editorFirst (défaut) : ces règles écrasent le pyproject.toml de chaque projet.
            -- filesystemFirst : le pyproject.toml du projet gagne, ceci ne sert que de fallback.
            configurationPreference = "filesystemFirst",
            organizeImports = true,
            fixAll = true,
            lint = {
                select = {
                    "E", -- pycodestyle errors
                    "W", -- pycodestyle warnings
                    "F", -- pyflakes
                    "I", -- isort
                    "N", -- pep8-naming
                    "B", -- flake8-bugbear
                    "C4", -- flake8-comprehensions
                    "SIM", -- flake8-simplify
                    "ARG", -- flake8-unused-arguments
                    "PTH", -- flake8-use-pathlib
                    "ERA", -- eradicate
                    "PL", -- pylint
                    "RUF", -- ruff-specific
                },
                ignore = {
                    "D419",
                    "UP",
                    "E501", -- line too long (le formatter s'en charge)
                    "E203", -- whitespace before ':'
                    "B008", -- function calls in argument defaults
                    "N806", -- variable in function should be lowercase
                    "PLR0913", -- too many arguments
                    "PLR0915", -- too many statements
                    "SIM108", -- use ternary operator
                },
            },
        },
    },
}
