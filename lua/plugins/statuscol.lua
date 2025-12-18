return {
    "luukvbaal/statuscol.nvim",
    config = function()
        vim.api.nvim_set_hl(0, "MyCurrentLine", { fg = "#FAB387", bold = true })
        -- Définir le bleu de Catppuccin Mocha pour les numéros relatifs
        vim.api.nvim_set_hl(0, "MyRelativeNumber", { fg = "#89B4FA" })

        -- Custom function to show both absolute and relative line numbers
        local function lnum_both()
            local lnum = vim.v.lnum
            local current = vim.fn.line(".")

            -- Calculer la distance relative en sautant les folds
            local relnum = 0
            if vim.v.lnum ~= current then
                local step = vim.v.lnum > current and 1 or -1
                local line = current

                while line ~= vim.v.lnum do
                    line = line + step
                    if step > 0 then
                        local fold_end = vim.fn.foldclosedend(line)
                        if fold_end ~= -1 and fold_end < vim.v.lnum then
                            line = fold_end
                        end
                    else
                        local fold_start = vim.fn.foldclosed(line)
                        if fold_start ~= -1 and fold_start > vim.v.lnum then
                            line = fold_start
                        end
                    end
                    relnum = relnum + 1
                end
            end

            -- Numéro absolu en orange pour la ligne courante, sinon couleur par défaut
            local hl_abs = vim.v.lnum == current and "%#MyCurrentLine#" or "%#LineNr#"
            -- Numéro relatif en bleu
            local hl_rel = "%#MyRelativeNumber#"

            return hl_abs .. string.format("%3d ", lnum) .. hl_rel .. string.format("%2d", relnum)
        end

        require("statuscol").setup({
            setopt = true,
            segments = {
                {
                    sign = {
                        namespace = { "gitsigns.*" },
                        name = { "gitsigns.*" },
                    },
                },
                {
                    sign = {
                        namespace = { ".*" },
                        name = { ".*" },
                        auto = true,
                    },
                },
                {
                    text = { lnum_both, " " },
                    condition = { true },
                    click = "v:lua.ScLa",
                },
            },
            ft_ignore = { "neominimap", "NvimTree", "neo-tree", "toggleterm", "Trouble" },
            bt_ignore = { "nofile", "terminal" },
        })
    end,
}
