-- Popup flottante listant les choix du choiceNode LuaSnip actif.
local M = {}

local AUTO_CLOSE_MS = 3000
local REFRESH_DELAY_MS = 50
local ns = vim.api.nvim_create_namespace("luasnip_choice_popup")

local popup_win = nil

function M.close()
    if popup_win and vim.api.nvim_win_is_valid(popup_win) then
        vim.api.nvim_win_close(popup_win, true)
    end
    popup_win = nil
end

local function build_lines(choices)
    local lines = { "Choix disponibles" }
    for idx, choice in ipairs(choices) do
        table.insert(lines, string.format("%d. %s", idx, choice))
    end
    table.insert(lines, "")
    table.insert(lines, "Ctrl+n/p pour naviguer")
    return lines
end

local function max_width(lines)
    local width = 0
    for _, line in ipairs(lines) do
        width = math.max(width, vim.fn.strdisplaywidth(line))
    end
    return math.min(width + 2, vim.o.columns - 4)
end

function M.show()
    local luasnip = require("luasnip")
    if not luasnip.choice_active() then
        return
    end

    local choices = luasnip.get_current_choices()
    if not choices or #choices == 0 then
        return
    end

    M.close()

    local lines = build_lines(choices)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].bufhidden = "wipe"
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false

    vim.api.nvim_buf_set_extmark(buf, ns, 0, 0, { line_hl_group = "Title" })
    vim.api.nvim_buf_set_extmark(buf, ns, #lines - 1, 0, { line_hl_group = "Comment" })

    -- Au-dessus du curseur s'il y a la place, sinon en dessous
    local above = vim.fn.winline() > #lines + 2
    popup_win = vim.api.nvim_open_win(buf, false, {
        relative = "cursor",
        row = above and -(#lines + 2) or 1,
        col = 0,
        width = max_width(lines),
        height = #lines,
        style = "minimal",
        border = "rounded",
        focusable = false,
        zindex = 50,
    })
    vim.wo[popup_win].winblend = 10

    local win = popup_win
    vim.defer_fn(function()
        if popup_win == win then
            M.close()
        end
    end, AUTO_CLOSE_MS)
end

-- Change de choix (+1 / -1) puis réaffiche la popup
function M.change(direction)
    M.close()
    require("luasnip").change_choice(direction)
    vim.defer_fn(M.show, REFRESH_DELAY_MS)
end

return M
