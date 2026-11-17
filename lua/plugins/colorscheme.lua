return {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
        require("catppuccin").setup({
            flavour = "mocha",

            -- === CONFIGURATION DE BASE POUR FIRACODE ===
            -- Ces paramètres assurent que toutes les capacités typographiques sont activées
            no_italic = false, -- CRUCIAL : Active l'italique
            no_bold = false, -- Active le gras
            no_underline = false, -- Active le soulignement

            transparent_background = false,
            show_end_of_buffer = false,
            term_colors = true,

            dim_inactive = {
                enabled = false,
                shade = "dark",
                percentage = 0.15,
            },

            -- === STYLES DE BASE ===
            -- NOTE : custom_highlights ci-dessous est FUSIONNÉ avec ces styles (il ne les
            -- remplace pas) : un attribut présent ici s'ajoute au groupe surchargé.
            -- Garder les deux cohérents.
            styles = {
                comments = { "italic" },
                conditionals = { "bold", "italic" },
                loops = { "bold", "italic" },
                functions = { "bold" },
                keywords = { "bold" },
                strings = { "italic" },
                variables = {},
                numbers = { "bold" },
                booleans = { "bold", "italic" },
                properties = { "italic" }, -- cohérent avec @property ci-dessous
                types = { "bold", "italic" },
                operators = { "bold" },
            },

            -- === INTÉGRATIONS ===
            -- Détectées automatiquement depuis les plugins lazy.nvim (cmp, gitsigns,
            -- fzf-lua, flash, rainbow-delimiters, which-key…). Seules celles que la
            -- détection ne couvre pas sont listées ici. bufferline : voir bufferline.lua.
            auto_integrations = true,
            integrations = {
                noice = true, -- pas de détection automatique pour noice.nvim
                notify = true, -- nvim-notify (utilisé par noice)
            },

            -- === HIGHLIGHTS PERSONNALISÉS ===
            -- Captures migrées vers la nomenclature Treesitter actuelle (Neovim 0.9+).
            -- Les ligatures FiraCode étant gérées au niveau de la fonte, elles sont
            -- indépendantes de ces groupes : on style les tokens, pas les glyphes.
            custom_highlights = function(colors)
                return {
                    -- === COMMENTAIRES ET DOCUMENTATION ===
                    ["@comment"] = {
                        fg = colors.overlay1,
                        italic = true,
                        cterm = { italic = true },
                    },
                    -- Même couleur pour la syntaxe Vim classique (fichiers sans Treesitter)
                    ["Comment"] = {
                        fg = colors.overlay1,
                        italic = true,
                        cterm = { italic = true },
                    },
                    ["@comment.todo"] = {
                        fg = colors.base,
                        bg = colors.yellow,
                        bold = true,
                        italic = true,
                    },
                    ["@comment.warning"] = {
                        fg = colors.base,
                        bg = colors.peach,
                        bold = true,
                        italic = true,
                    },
                    ["@comment.note"] = {
                        fg = colors.base,
                        bg = colors.blue,
                        bold = true,
                        italic = true,
                    },
                    ["@comment.error"] = {
                        fg = colors.base,
                        bg = colors.red,
                        bold = true,
                        italic = true,
                    },

                    -- === FONCTIONS ET MÉTHODES ===
                    ["@function"] = { fg = colors.blue, bold = true },
                    ["@function.builtin"] = {
                        fg = colors.peach,
                        bold = true,
                        italic = true,
                    },
                    -- @method -> @function.method (capture renommée)
                    ["@function.method"] = { fg = colors.blue, bold = true },
                    ["@function.method.call"] = { fg = colors.blue, bold = true },

                    -- === TYPES ET CLASSES ===
                    ["@type"] = { fg = colors.yellow, bold = true, italic = true },
                    ["@type.builtin"] = { fg = colors.yellow, bold = true },
                    ["@constructor"] = { fg = colors.sapphire, bold = true, italic = true },
                    ["@type.definition"] = { fg = colors.yellow, bold = true, italic = true },

                    -- === VARIABLES ET PARAMÈTRES ===
                    ["@variable"] = { fg = colors.text },
                    ["@variable.builtin"] = {
                        fg = colors.red,
                        italic = true,
                    },
                    -- @parameter -> @variable.parameter
                    ["@variable.parameter"] = {
                        fg = colors.maroon,
                        italic = true,
                    },
                    -- @field -> @variable.member
                    ["@variable.member"] = {
                        fg = colors.teal,
                        italic = true,
                        bold = true,
                    },
                    ["@property"] = {
                        fg = colors.teal,
                        italic = true,
                    },

                    -- === MOTS-CLÉS ET CONTRÔLE DE FLUX ===
                    ["@keyword"] = { fg = colors.mauve, bold = true },
                    ["@keyword.function"] = {
                        fg = colors.mauve,
                        bold = true,
                        italic = true,
                    },
                    ["@keyword.return"] = {
                        fg = colors.pink,
                        bold = true,
                        italic = true,
                    },
                    -- @conditional -> @keyword.conditional
                    ["@keyword.conditional"] = {
                        fg = colors.mauve,
                        bold = true,
                        italic = true,
                    },
                    -- @repeat -> @keyword.repeat
                    ["@keyword.repeat"] = {
                        fg = colors.mauve,
                        bold = true,
                        italic = true,
                    },
                    -- @exception -> @keyword.exception
                    ["@keyword.exception"] = {
                        fg = colors.red,
                        bold = true,
                        italic = true,
                    },

                    -- === LITTÉRAUX ET CONSTANTES ===
                    ["@string"] = {
                        fg = colors.green,
                        italic = true,
                    },
                    ["@string.escape"] = {
                        fg = colors.pink,
                        bold = true,
                    },
                    -- @string.regex -> @string.regexp
                    ["@string.regexp"] = {
                        fg = colors.peach,
                        italic = true,
                    },
                    ["@number"] = { fg = colors.peach, bold = true },
                    -- @float -> @number.float
                    ["@number.float"] = { fg = colors.peach, bold = true },
                    ["@boolean"] = {
                        fg = colors.peach,
                        bold = true,
                        italic = true,
                    },
                    ["@constant"] = { fg = colors.peach, bold = true },
                    ["@constant.builtin"] = {
                        fg = colors.peach,
                        bold = true,
                        italic = true,
                    },

                    -- === OPÉRATEURS ET PONCTUATION ===
                    ["@operator"] = {
                        fg = colors.sky,
                        bold = true,
                    },
                    ["@punctuation.bracket"] = {
                        fg = colors.overlay2,
                        bold = true,
                    },
                    ["@punctuation.delimiter"] = {
                        fg = colors.overlay2,
                    },
                    ["@punctuation.special"] = {
                        fg = colors.sky,
                        bold = true,
                    },

                    -- === IMPORTS ET MODULES ===
                    -- @include fusionné dans @keyword.import (même cible)
                    ["@keyword.import"] = {
                        fg = colors.pink,
                        bold = true,
                        italic = true,
                    },
                    -- @namespace -> @module
                    ["@module"] = {
                        fg = colors.yellow,
                        italic = true,
                    },

                    -- === SPÉCIFIQUE PYTHON ===
                    -- @decorator supprimé : les décorateurs sont capturés en @attribute.
                    -- @keyword.from supprimé : 'from' est un @keyword.import.
                    ["@attribute"] = {
                        fg = colors.yellow,
                        bold = true,
                        italic = true,
                    },

                    -- === ÉLÉMENTS MARKDOWN (@text.* -> @markup.*) ===
                    ["@markup.italic"] = { italic = true },
                    ["@markup.strong"] = { bold = true },
                    ["@markup.strikethrough"] = { strikethrough = true },

                    ["@markup.heading.1"] = { fg = colors.red, bold = true, italic = true },
                    ["@markup.heading.2"] = { fg = colors.peach, bold = true, italic = true },
                    ["@markup.heading.3"] = { fg = colors.yellow, bold = true },
                    ["@markup.heading.4"] = { fg = colors.green, italic = true },
                    ["@markup.heading.5"] = { fg = colors.blue, italic = true },
                    ["@markup.heading.6"] = { fg = colors.mauve, italic = true },

                    -- === LSP ET DIAGNOSTICS ===
                    ["DiagnosticError"] = {
                        fg = colors.red,
                        bold = true,
                    },
                    ["DiagnosticWarn"] = {
                        fg = colors.yellow,
                        bold = true,
                    },
                    ["DiagnosticInfo"] = {
                        fg = colors.blue,
                        italic = true,
                    },
                    ["DiagnosticHint"] = {
                        fg = colors.teal,
                        italic = true,
                    },

                    -- === OPTIMISATIONS NVIM-TREE ===
                    ["NvimTreeFolderName"] = {
                        fg = colors.blue,
                        bold = true,
                    },
                    ["NvimTreeOpenedFolderName"] = {
                        fg = colors.blue,
                        bold = true,
                        italic = true,
                    },
                    ["NvimTreeFileName"] = {
                        fg = colors.text,
                    },
                    ["NvimTreeExecutableFile"] = {
                        fg = colors.green,
                        bold = true,
                    },
                }
            end,
        })

        -- Appliquer le thème
        -- termguicolors est activé dans core/options.lua ; Neovim n'utilise pas les
        -- options terminal t_ZH/t_ZR de Vim (l'italique passe par terminfo).
        vim.cmd.colorscheme("catppuccin-mocha")
    end,
}
