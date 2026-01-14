return {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
        position = "bottom", -- Position de la fenêtre (top, bottom, left, right)
        height = 10, -- Hauteur si positionné en haut/bas
        width = 50, -- Largeur si positionné à gauche/droite
        -- icons = true, -- Afficher les icônes
        mode = "document_diagnostics", -- Mode par défaut (erreurs du document actuel)
        fold_open = "", -- Icône pour les dossiers ouverts
        fold_closed = "", -- Icône pour les dossiers fermés
        action_keys = {
            -- Raccourcis pour les actions dans la fenêtre
            close = "q", -- Fermer la fenêtre
            cancel = "<esc>", -- Annuler
            jump = "<cr>", -- Aller à l'erreur
        },
    },
    cmd = "Trouble",
    keys = {
        {
            "<leader>tx",
            "<cmd>Trouble diagnostics toggle<cr>",
            desc = "Diagnostics (Trouble)",
        },
    },
}
