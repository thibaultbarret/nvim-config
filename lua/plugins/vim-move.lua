return {
    "matze/vim-move",
    config = function()
        -- Deplacement ligne mode visuel
        vim.keymap.set('n', "<C-j>", "<Plug>MoveLineDown", {silent = true})
        vim.keymap.set('n', "<C-k>", "<Plug>MoveLineUp", {silent = true})
        vim.keymap.set('n', "<C-h>", "<Plug>MoveCharLeft", {silent = true})
        vim.keymap.set('n', "<C-l>", "<Plug>MoveCharRight", {silent = true})
        --
        -- Deplacement block
        vim.keymap.set('x', "<C-j>", "<Plug>MoveBlockDown", {silent = true})
        vim.keymap.set('x', "<C-k>", "<Plug>MoveBlockUp", {silent = true})
        vim.keymap.set('x', "<C-h>", "<Plug>MoveBlockLeft", {silent = true})
        vim.keymap.set('x', "<C-l>", "<Plug>MoveBlockRight", {silent = true})
    end
}
