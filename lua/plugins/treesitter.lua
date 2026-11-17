-- Dépôt local des grammaires MFront / MTest (monorepo : grammars/mfront, grammars/mtest)
local MFRONT_GRAMMARS_REPO = vim.fn.expand("~/Documents/THESE/Mfront/Treesitter/tree-sitter-mfront_mtest")
local LOCAL_GRAMMARS = { "mfront", "mtest" }

-- Déclare mfront/mtest comme parsers nvim-treesitter compilés depuis le dépôt local.
-- :TSInstall / :TSUpdate les (re)compilent alors comme les autres et lient
-- leurs queries depuis grammars/<lang>/queries.
local function register_local_grammars()
    local parsers = require("nvim-treesitter.parsers")
    for _, lang in ipairs(LOCAL_GRAMMARS) do
        parsers[lang] = {
            install_info = {
                path = MFRONT_GRAMMARS_REPO,
                location = "grammars/" .. lang,
                queries = "grammars/" .. lang .. "/queries",
            },
            tier = 3,
        }
    end
end

local function local_grammars_available()
    return vim.uv.fs_stat(MFRONT_GRAMMARS_REPO) ~= nil
end

return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
        -- Doit être en place AVANT toute installation / mise à jour :
        -- nvim-treesitter émet `User TSUpdate` à chaque rechargement de la liste des parsers.
        if local_grammars_available() then
            vim.api.nvim_create_autocmd("User", {
                pattern = "TSUpdate",
                callback = register_local_grammars,
            })
        end

        -- Branche main : setup() n'accepte que install_dir. Les anciennes options
        -- highlight/indent n'avaient aucun effet ; le highlight est démarré par
        -- l'autocmd FileType de core/tree-sitter.lua.
        require("nvim-treesitter").setup({})

        local to_install = {
            "bash",
            "python",
            "latex",
            "lua",
            "gitignore",
            "cpp",
            "c",
            "doxygen", -- injecté dans les commentaires ///, //!, /** */ de C/C++ (@param…)
            "javascript",
            "json",
            "cmake",
            "yaml",
            -- "astro",
        }
        if local_grammars_available() then
            vim.list_extend(to_install, LOCAL_GRAMMARS)
        end
        local already = require("nvim-treesitter.config").get_installed()
        local missing = vim.iter(to_install)
            :filter(function(p)
                return not vim.tbl_contains(already, p)
            end)
            :totable()
        require("nvim-treesitter").install(missing)
        -- Les filetypes mfront/mtest sont déclarés dans core/filetypes.lua.
    end,
}
