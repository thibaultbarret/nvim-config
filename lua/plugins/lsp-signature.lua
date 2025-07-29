-- Remplacez votre lua/plugins/lsp-signature.lua par :
return {
    "ray-x/lsp_signature.nvim",
    event = "VeryLazy",
    config = function()
        require('lsp_signature').setup({
            bind = true,
            handler_opts = {
                border = "rounded"
            },

            -- === CONFIGURATION MULTI-LIGNE ===
            floating_window = true,
            floating_window_above_cur_line = true,
            floating_window_off_x = 1,
            floating_window_off_y = 0,

            -- IMPORTANT : Dimensions pour affichage multi-ligne
            max_height = 30, -- Augmenté pour permettre plus de lignes
            max_width = 100, -- Largeur plus généreuse

            -- Force le retour à la ligne
            wrap = true, -- CRUCIAL : Active le retour à la ligne

            -- Documentation étendue
            doc_lines = 10, -- Affiche plus de lignes de documentation

            -- Conseils visuels améliorés
            hint_enable = true,
            hint_prefix = "📋 ",
            hint_scheme = "Comment",

            -- Paramètres actifs mis en évidence
            hi_parameter = "LspSignatureActiveParameter",

            -- Déclencheurs pour affichage automatique
            extra_trigger_chars = { "(", ",", " " },

            -- Configuration avancée pour multi-ligne
            always_trigger = false,
            auto_close_after = nil, -- Ne ferme pas automatiquement
            fix_pos = false,        -- Permet le repositionnement

            -- Performance et timing
            timer_interval = 200,
            close_timeout = 8000, -- Plus de temps pour lire

            -- Transparence pour voir le code en arrière-plan
            transparency = 10,

            -- Style de la fenêtre
            shadow_blend = 36,
            shadow_guibg = 'Black',

            -- Configuration du contenu
            padding = ' ',

            -- NOUVEAU : Formatage personnalisé pour multi-ligne
            floating_window_configure = function(config)
                -- Force une largeur minimale pour déclencher le retour à la ligne
                config.max_width = math.min(100, vim.o.columns - 10)
                config.max_height = math.min(20, vim.o.lines - 10)
                return config
            end,
        })
    end
}
