return {
    "NvChad/nvim-colorizer.lua",
    config = function()
        require("colorizer").setup({
            filetypes = {
                "tex",
                "latex",
                "*", -- Active pour tous les fichiers
            },
            user_default_options = {
                RGB = true,
                RRGGBB = true,
                names = true, -- "red", "blue", etc.
                RRGGBBAA = true,
                rgb_fn = true, -- CSS rgb() et rgba()
                hsl_fn = true,
                css = true,
                css_fn = true,
                mode = "background", -- ou 'foreground', 'virtualtext'
                tailwind = false,
            },
        })
    end,
}
