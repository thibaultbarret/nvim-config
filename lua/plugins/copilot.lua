return {
    {
        "github/copilot.vim",
        lazy = false,
        -- `init` s'exécute AVANT le chargement : copilot.vim ne crée alors pas son <Tab>
        init = function()
            vim.g.copilot_no_tab_map = true -- <Tab> est géré par nvim-cmp/LuaSnip
            vim.g.copilot_assume_mapped = true -- l'acceptation est mappée ailleurs (<C-y>, core/keymaps.lua)
            -- Serveur embarqué dans le plugin (mis à jour avec copilot.vim via lazy) au lieu
            -- de `npx @github/copilot-language-server`, qui retéléchargeait à chaque démarrage.
            vim.g.copilot_version = false
        end,
    },
    {
        "CopilotC-Nvim/CopilotChat.nvim",
        dependencies = {
            { "nvim-lua/plenary.nvim", branch = "master" },
        },
        build = "make tiktoken",
        opts = {
            -- See Configuration section for options
        },
    },
}
