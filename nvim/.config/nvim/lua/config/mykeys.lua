-- List only the keymaps this config adds (not Neovim's built-in ones).
-- snapshot() runs at the very start of init.lua; anything mapped after that is ours.

local M = {}
local builtin = {}
local modes = { "n", "v", "x", "i", "t" }

local function id(k) return k.mode .. "|" .. k.lhs .. "|" .. (k.rhs or tostring(k.callback)) end

function M.snapshot()
    for _, mode in ipairs(modes) do
        for _, k in ipairs(vim.api.nvim_get_keymap(mode)) do
            builtin[id(k)] = true
        end
    end
end

function M.list()
    local seen, keys = {}, {}
    for _, mode in ipairs(modes) do
        for _, k in ipairs(vim.api.nvim_get_keymap(mode)) do
            if
                not builtin[id(k)]
                and not k.lhs:match("^<Plug>")
                and not (k.rhs or ""):match("^<Plug>")
                and not seen[k.mode .. k.lhs]
            then
                seen[k.mode .. k.lhs] = true
                table.insert(keys, k)
            end
        end
    end
    return keys
end

-- Fuzzy-pick one of our keymaps; Enter runs it
function M.pick()
    local leader = vim.g.mapleader
    local entries, by_entry = {}, {}
    for _, k in ipairs(M.list()) do
        local lhs = k.lhs
        if leader and lhs:sub(1, #leader) == leader then
            lhs = "<leader>" .. lhs:sub(#leader + 1)
        end
        local entry = string.format("%-2s %-14s %s", k.mode, lhs, k.desc or k.rhs or "")
        by_entry[entry] = k
        table.insert(entries, entry)
    end
    table.sort(entries)

    require("fzf-lua").fzf_exec(entries, {
        prompt = "My keys> ",
        winopts = { fullscreen = false, height = 0.6, width = 0.6, preview = { hidden = true } },
        actions = {
            ["default"] = function(selected)
                local k = selected and by_entry[selected[1]]
                if k and k.mode == "n" then
                    vim.api.nvim_feedkeys(vim.keycode(k.lhs), "m", false)
                end
            end,
        },
    })
end

return M
