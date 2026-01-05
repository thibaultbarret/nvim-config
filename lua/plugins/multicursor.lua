return {
    "jake-stewart/multicursor.nvim",
    branch = "1.0",
    config = function()
        local mc = require("multicursor-nvim")

        mc.setup()

        local set = vim.keymap.set

        -- Ajouter ou sauter un curseur au-dessus/en-dessous du curseur principal
        set({ "n", "i" }, "<C-Up>", function()
            mc.lineAddCursor(-1)
        end)
        set({ "n", "i" }, "<C-Down>", function()
            mc.lineAddCursor(1)
        end)

        -- Ajouter un curseur et sauter au prochain mot identique
        set({ "n", "x" }, "<leader>ml", function()
            mc.matchAddCursor(1)
        end)

        -- Sauter au prochain mot identique sans ajouter de curseur
        set({ "n", "x" }, "<C-S-s>", function()
            mc.matchSkipCursor(1)
        end)

        -- Supprimer le curseur principal
        set({ "n", "x" }, "<leader>S-x", mc.deleteCursor)

        -- Actions avancées

        -- Ajouter un curseur sur chaque ligne d'un paragraphe (gaip)
        -- ou pour chaque ligne d'une sélection visuelle
        set({ "n", "x" }, "ga", mc.addCursorOperator)

        -- Aligner les colonnes des curseurs
        set("n", "<leader>a", mc.alignCursors)

        -- Diviser les sélections visuelles par regex
        set("x", "S", mc.splitCursors)

        -- Matcher de nouveaux curseurs dans les sélections visuelles par regex
        set("x", "M", mc.matchCursors)

        -- Restaurer les curseurs si vous les effacez accidentellement
        set("n", "<leader>gv", mc.restoreCursors)

        -- Ajouter un curseur pour toutes les occurrences du mot/sélection dans le document
        set({ "n", "x" }, "<leader>A", mc.matchAllAddCursors)

        -- Cloner chaque curseur et désactiver les originaux
        set({ "n", "x" }, "<leader><c-q>", mc.duplicateCursors)

        -- Transposer le contenu des sélections visuelles entre les curseurs
        set("x", "<leader>t", mc.transposeCursors)

        -- Couche de keymap pour les actions pendant le mode multi-curseur
        -- Cela permet d'avoir des mappings qui se chevauchent
        mc.addKeymapLayer(function(layerSet)
            -- Sélectionner un curseur différent comme curseur principal
            layerSet({ "n", "x" }, "<left>", mc.prevCursor)
            layerSet({ "n", "x" }, "<right>", mc.nextCursor)

            -- Supprimer le curseur principal
            layerSet({ "n", "x" }, "<leader>x", mc.deleteCursor)

            -- Activer et effacer les curseurs avec escape
            layerSet("n", "<esc>", function()
                if not mc.cursorsEnabled() then
                    mc.enableCursors()
                else
                    mc.clearCursors()
                end
            end)
        end)

        -- Personnaliser l'apparence des curseurs
        local hl = vim.api.nvim_set_hl
        hl(0, "MultiCursorCursor", { link = "Cursor" })
        hl(0, "MultiCursorVisual", { link = "Visual" })
        hl(0, "MultiCursorSign", { link = "SignColumn" })
        hl(0, "MultiCursorDisabledCursor", { link = "Visual" })
        hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
        hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })
    end,
}
