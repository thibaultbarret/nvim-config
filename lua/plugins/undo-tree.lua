return {
    "mbbill/undotree",
    config = function()
        -- Configuration optionnelle (par exemple, raccourci clavier)
        vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, { desc = "Toggle Undotree" })
    end,
}
