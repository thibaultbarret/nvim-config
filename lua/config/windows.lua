local M = {}

-- Va dans la fenêtre de droite si c'est un buffer normal (pas aerial, quickfix,
-- flottante…), sinon ouvre un split vertical à droite.
function M.focus_right()
    local origin = vim.api.nvim_get_current_win()
    vim.cmd("wincmd l")
    local win = vim.api.nvim_get_current_win()
    if win ~= origin and vim.bo.buftype == "" and vim.api.nvim_win_get_config(win).relative == "" then
        return
    end
    vim.api.nvim_set_current_win(origin)
    vim.cmd("rightbelow vsplit")
end

return M
