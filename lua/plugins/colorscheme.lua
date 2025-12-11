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

            -- Paramètres de compilation pour optimiser les performances avec FiraCode
            compile_path = vim.fn.stdpath("cache") .. "/catppuccin",
            transparent_background = false,
            show_end_of_buffer = false,
            term_colors = true,

            -- Configuration des dimensions qui s'harmonise avec les ligatures
            dim_inactive = {
                enabled = false,
                shade = "dark",
                percentage = 0.15,
            },

            -- === STYLES DE BASE ADAPTÉS À FIRACODE ===
            -- Cette configuration tire parti des ligatures tout en créant une hiérarchie visuelle claire
            styles = {
                -- Commentaires : L'italique de FiraCode est particulièrement élégant
                comments = { "italic" },

                -- Conditions : Excellent avec les ligatures (>=, <=, ==, etc.)
                conditionals = { "bold", "italic" },

                -- Boucles : Bénéficient des ligatures et de l'emphasise typographique
                loops = { "bold", "italic" },

                -- Fonctions : Gras pour qu'elles restent le focus principal
                functions = { "bold" },

                -- Mots-clés : Gras car ils structurent le code
                keywords = { "bold" },

                -- Chaînes : L'italique FiraCode rend les strings très distinctes
                strings = { "italic" },

                -- Variables : Style normal pour ne pas surcharger
                variables = {},

                -- Nombres : Gras pour les faire ressortir, surtout avec les ligatures
                numbers = { "bold" },

                -- Booléens : Italique car ils sont conceptuels
                booleans = { "bold", "italic" },

                -- Propriétés : Italique pour les distinguer des variables
                properties = { "italic" },

                -- Types : Combinaison pour un impact maximal
                types = { "bold", "italic" },

                -- Opérateurs : Gras car FiraCode les transforme en symboles importants
                operators = { "bold" },
            },

            -- === INTÉGRATIONS ===
            integrations = {
                cmp = true,
                treesitter = true,
                treesitter_context = true,
                gitsigns = true,
                nvimtree = true,
                telescope = true,
                notify = false,
                mini = false,
                -- Intégrations spécifiques qui bénéficient de FiraCode
                lsp_trouble = true,
                which_key = true,
            },

            -- === HIGHLIGHTS PERSONNALISÉS POUR FIRACODE ===
            -- Cette section exploite spécifiquement les capacités de FiraCode
            custom_highlights = function(colors)
                return {
                    -- === COMMENTAIRES ET DOCUMENTATION ===
                    -- FiraCode rend les commentaires italiques particulièrement lisibles
                    ["@comment"] = {
                        fg = colors.overlay1,
                        italic = true,
                        -- Assurance supplémentaire pour l'italique
                        cterm = { italic = true },
                    },

                    -- Commentaires spéciaux avec un impact visuel fort
                    ["@comment.todo"] = {
                        fg = colors.base,
                        bg = colors.yellow,
                        bold = true,
                        italic = true, -- TODO en gras-italique se démarque parfaitement
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
                    -- Garder les fonctions bien visibles pour l'architecture du code
                    ["@function"] = { fg = colors.blue, bold = true },
                    ["@function.builtin"] = {
                        fg = colors.peach,
                        bold = true,
                        italic = true, -- Fonctions built-in distinctes
                    },
                    ["@method"] = { fg = colors.blue, bold = true },
                    ["@method.call"] = { fg = colors.blue, bold = true },

                    -- === TYPES ET CLASSES ===
                    -- Excellent rendu avec FiraCode en gras-italique
                    ["@type"] = { fg = colors.yellow, bold = true, italic = true },
                    ["@type.builtin"] = { fg = colors.yellow, bold = true },
                    ["@constructor"] = { fg = colors.sapphire, bold = true, italic = true },
                    ["@type.definition"] = { fg = colors.yellow, bold = true, italic = true },

                    -- === VARIABLES ET PARAMÈTRES ===
                    -- Hiérarchie subtile qui tire parti de l'italique FiraCode
                    ["@variable"] = { fg = colors.text },
                    ["@variable.builtin"] = {
                        fg = colors.red,
                        italic = true, -- Variables spéciales en italique
                    },
                    ["@parameter"] = {
                        fg = colors.maroon,
                        italic = true, -- Paramètres de fonction en italique
                    },
                    ["@field"] = {
                        fg = colors.teal,
                        italic = true, -- Champs d'objet en italique
                    },
                    ["@property"] = {
                        fg = colors.teal,
                        italic = true, -- Propriétés en italique
                    },

                    -- === MOTS-CLÉS ET CONTRÔLE DE FLUX ===
                    -- Ces éléments bénéficient particulièrement des ligatures
                    ["@keyword"] = { fg = colors.mauve, bold = true },
                    ["@keyword.function"] = {
                        fg = colors.mauve,
                        bold = true,
                        italic = true,
                    },
                    ["@keyword.return"] = {
                        fg = colors.pink,
                        bold = true,
                        italic = true, -- return se démarque bien
                    },

                    -- Contrôle de flux : parfait avec les ligatures (=>, >=, etc.)
                    ["@conditional"] = {
                        fg = colors.mauve,
                        bold = true,
                        italic = true, -- if/else très distinctifs
                    },
                    ["@repeat"] = {
                        fg = colors.mauve,
                        bold = true,
                        italic = true, -- for/while se démarquent
                    },
                    ["@exception"] = {
                        fg = colors.red,
                        bold = true,
                        italic = true, -- try/catch/throw très visibles
                    },

                    -- === LITTÉRAUX ET CONSTANTES ===
                    -- Les chaînes bénéficient énormément de l'italique FiraCode
                    ["@string"] = {
                        fg = colors.green,
                        italic = true, -- Strings très lisibles en italique
                    },
                    ["@string.escape"] = {
                        fg = colors.pink,
                        bold = true, -- Échappements techniques en gras
                    },
                    ["@string.regex"] = {
                        fg = colors.peach,
                        italic = true, -- Regex en italique pour les distinguer
                    },

                    -- Nombres : excellent rendu avec les ligatures numériques
                    ["@number"] = { fg = colors.peach, bold = true },
                    ["@float"] = { fg = colors.peach, bold = true },
                    ["@boolean"] = {
                        fg = colors.peach,
                        bold = true,
                        italic = true, -- true/false très distinctifs
                    },
                    ["@constant"] = { fg = colors.peach, bold = true },
                    ["@constant.builtin"] = {
                        fg = colors.peach,
                        bold = true,
                        italic = true,
                    },

                    -- === OPÉRATEURS ET PONCTUATION ===
                    -- Ces éléments sont transformés par les ligatures FiraCode
                    ["@operator"] = {
                        fg = colors.sky,
                        bold = true, -- Opérateurs en gras pour les ligatures
                    },
                    ["@punctuation.bracket"] = {
                        fg = colors.overlay2,
                        bold = true, -- Brackets bien visibles
                    },
                    ["@punctuation.delimiter"] = {
                        fg = colors.overlay2,
                    },
                    ["@punctuation.special"] = {
                        fg = colors.sky,
                        bold = true, -- Ponctuation spéciale (=>, <-, etc.)
                    },

                    -- === IMPORTS ET MODULES ===
                    -- Bénéficient de l'italique pour leur nature organisationnelle
                    ["@include"] = {
                        fg = colors.pink,
                        bold = true,
                        italic = true, -- import/include très visibles
                    },
                    ["@namespace"] = {
                        fg = colors.yellow,
                        italic = true, -- Namespaces en italique
                    },

                    -- === SPÉCIFIQUE PYTHON ===
                    -- Optimisations pour Python avec FiraCode
                    ["@keyword.import"] = {
                        fg = colors.pink,
                        bold = true,
                        italic = true,
                    },
                    ["@keyword.from"] = {
                        fg = colors.pink,
                        bold = true,
                        italic = true,
                    },

                    -- Décorateurs Python : parfaits en gras-italique
                    ["@decorator"] = {
                        fg = colors.yellow,
                        bold = true,
                        italic = true, -- @decorator très distinctif
                    },
                    ["@attribute"] = {
                        fg = colors.yellow,
                        italic = true,
                    },

                    -- === ÉLÉMENTS MARKDOWN ===
                    -- FiraCode est excellente pour Markdown
                    ["@text.emphasis"] = { italic = true },
                    ["@text.strong"] = { bold = true },
                    ["@text.strike"] = { strikethrough = true },

                    -- Titres avec hiérarchie claire
                    ["@text.title.1"] = { fg = colors.red, bold = true, italic = true },
                    ["@text.title.2"] = { fg = colors.peach, bold = true, italic = true },
                    ["@text.title.3"] = { fg = colors.yellow, bold = true },
                    ["@text.title.4"] = { fg = colors.green, italic = true },
                    ["@text.title.5"] = { fg = colors.blue, italic = true },
                    ["@text.title.6"] = { fg = colors.mauve, italic = true },

                    -- === ÉLÉMENTS LSP ET DIAGNOSTICS ===
                    -- Optimisés pour une lecture rapide avec FiraCode
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

                    -- === ÉLÉMENTS SPÉCIAUX FIRACODE ===
                    -- Groupes personnalisés pour exploiter les ligatures

                    -- Flèches et opérateurs de transformation (=>, ->, etc.)
                    ["FiraCodeArrow"] = {
                        fg = colors.sky,
                        bold = true,
                    },

                    -- Opérateurs de comparaison (>=, <=, ==, !=)
                    ["FiraCodeComparison"] = {
                        fg = colors.mauve,
                        bold = true,
                    },

                    -- Opérateurs logiques (&&, ||, etc.)
                    ["FiraCodeLogical"] = {
                        fg = colors.red,
                        bold = true,
                    },

                    -- === OPTIMISATIONS TELESCOPE ===
                    -- FiraCode améliore l'expérience Telescope
                    ["TelescopeSelection"] = {
                        fg = colors.text,
                        bg = colors.surface0,
                        bold = true,
                    },
                    ["TelescopeMatching"] = {
                        fg = colors.blue,
                        bold = true,
                    },

                    -- === OPTIMISATIONS NVIM-TREE ===
                    -- Les icônes Nerd Font s'harmonisent parfaitement
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
        vim.cmd.colorscheme("catppuccin-mocha")

        -- === POST-CONFIGURATION FIRACODE ===
        -- Ajustements spécifiques après l'application du thème
        vim.api.nvim_create_autocmd("ColorScheme", {
            pattern = "catppuccin*",
            callback = function()
                local colors = require("catppuccin.palettes").get_palette("mocha")

                -- Force l'italique si nécessaire (parfois requis avec FiraCode)
                vim.cmd([[
                    if has('termguicolors')
                        set termguicolors
                    endif

                    " Force les capacités d'italique pour FiraCode
                    let &t_ZH="\e[3m"
                    let &t_ZR="\e[23m"
                ]])

                -- Groupe de test spécial pour valider FiraCode
                vim.api.nvim_set_hl(0, "FiraCodeTest", {
                    fg = colors.sapphire,
                    bold = true,
                    italic = true,
                })

                -- Message de confirmation
                vim.defer_fn(function()
                    print("🎨 FiraCode + Catppuccin configurés !")
                    print("💡 Testez avec :FontTest et :FiraTest")
                end, 1000)
            end,
        })
    end,
}
