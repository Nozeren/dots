-- Hand-written statusline, no plugin.
--
--  NORMAL  oil.lua ● lua/plugins          E1 W2  lua_ls   main  42:7  61%
--  └ mode  └ file, modified, folder       └ diagnostics, LSP, git branch, position
--
-- Colours come from the colourscheme's highlight groups, so it follows theme changes.

local M = {}

-- Mode name and the colour of its block
local modes = {
    n = { "NORMAL", "Normal" },
    no = { "O-PENDING", "Normal" },
    i = { "INSERT", "Insert" },
    ic = { "INSERT", "Insert" },
    v = { "VISUAL", "Visual" },
    V = { "V-LINE", "Visual" },
    ["\22"] = { "V-BLOCK", "Visual" },
    s = { "SELECT", "Visual" },
    S = { "S-LINE", "Visual" },
    R = { "REPLACE", "Replace" },
    Rv = { "V-REPLACE", "Replace" },
    c = { "COMMAND", "Command" },
    t = { "TERMINAL", "Terminal" },
}

-- ---------------------------------------------------------------- colours

-- First foreground colour found among the given highlight groups
local function fg(...)
    for _, name in ipairs({ ... }) do
        local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
        if hl.fg then return hl.fg end
    end
end

local function set_highlights()
    local bar = vim.api.nvim_get_hl(0, { name = "StatusLine", link = false })
    local dark = vim.api.nvim_get_hl(0, { name = "Normal", link = false }).bg
    local set = function(name, opts) vim.api.nvim_set_hl(0, "St" .. name, opts) end

    -- Mode blocks: dark text on a coloured background
    set("ModeNormal", { fg = dark, bg = fg("Green", "String"), bold = true })
    set("ModeInsert", { fg = dark, bg = fg("Fg", "Normal"), bold = true })
    set("ModeVisual", { fg = dark, bg = fg("Red", "DiagnosticError"), bold = true })
    set("ModeReplace", { fg = dark, bg = fg("Orange", "DiagnosticWarn"), bold = true })
    set("ModeCommand", { fg = dark, bg = fg("Aqua", "DiagnosticInfo"), bold = true })
    set("ModeTerminal", { fg = dark, bg = fg("Purple", "DiagnosticHint"), bold = true })

    -- Everything else sits on the bar's own background
    set("File", { fg = fg("Fg", "Normal"), bg = bar.bg, bold = true })
    set("Dim", { fg = fg("Grey", "Comment"), bg = bar.bg })
    set("Modified", { fg = fg("Yellow", "DiagnosticWarn"), bg = bar.bg })
    set("Error", { fg = fg("DiagnosticError"), bg = bar.bg })
    set("Warn", { fg = fg("DiagnosticWarn"), bg = bar.bg })
    set("Info", { fg = fg("DiagnosticInfo"), bg = bar.bg })
    set("Hint", { fg = fg("DiagnosticHint"), bg = bar.bg })
    set("Git", { fg = fg("Purple", "DiagnosticHint"), bg = bar.bg })
    set("Position", { fg = dark, bg = fg("Grey", "Comment") })
end

-- ---------------------------------------------------------------- git branch

-- Looked up in the background per folder, so the bar never waits on git
local branches = {}

local function refresh_branch()
    local dir = vim.fn.expand("%:p:h")
    if dir == "" or vim.bo.buftype ~= "" then return end
    vim.system({ "git", "-C", dir, "branch", "--show-current" }, { text = true }, function(out)
        branches[dir] = out.code == 0 and vim.trim(out.stdout) or ""
        vim.schedule(function() vim.cmd.redrawstatus() end)
    end)
end

-- ---------------------------------------------------------------- sections

local function hl(group, text) return "%#St" .. group .. "#" .. text end

local function mode()
    local m = modes[vim.api.nvim_get_mode().mode] or modes[vim.api.nvim_get_mode().mode:sub(1, 1)] or { "?", "Normal" }
    return hl("Mode" .. m[2], " " .. m[1] .. " ")
end

local function file()
    local name = vim.fn.expand("%:t")
    if name == "" then return hl("Dim", " [No Name]") end

    local out = hl("File", " " .. name)
    if vim.bo.modified then out = out .. hl("Modified", " ●") end
    if vim.bo.readonly or not vim.bo.modifiable then out = out .. hl("Dim", " ") end

    -- Parent folder, relative to where nvim was started
    local folder = vim.fn.fnamemodify(vim.fn.expand("%:h"), ":~:.")
    if folder ~= "." and folder ~= "" then out = out .. hl("Dim", "  " .. folder) end
    return out
end

local function diagnostics()
    local counts = vim.diagnostic.count(0)
    local s = vim.diagnostic.severity
    local parts = {}
    for _, d in ipairs({ { s.ERROR, "Error", "E" }, { s.WARN, "Warn", "W" }, { s.INFO, "Info", "I" }, { s.HINT, "Hint", "H" } }) do
        if (counts[d[1]] or 0) > 0 then table.insert(parts, hl(d[2], d[3] .. counts[d[1]])) end
    end
    return #parts > 0 and table.concat(parts, " ") .. "  " or ""
end

local function lsp()
    local names = vim.tbl_map(function(c) return c.name end, vim.lsp.get_clients({ bufnr = 0 }))
    return #names > 0 and hl("Dim", " " .. table.concat(names, " ") .. "  ") or ""
end

local function git()
    local branch = vim.b.gitsigns_head or branches[vim.fn.expand("%:p:h")]
    return (branch and branch ~= "") and hl("Git", " " .. branch .. "  ") or ""
end

local function position()
    return hl("Position", " %l:%c  %p%% ")
end

function M.render()
    return table.concat({
        mode(),
        file(),
        "%#StDim#%=",   -- everything after this is right-aligned
        diagnostics(),
        lsp(),
        git(),
        position(),
    })
end

-- ---------------------------------------------------------------- setup

set_highlights()
vim.o.statusline = "%!v:lua.require'config.statusline'.render()"

local group = vim.api.nvim_create_augroup("statusline", { clear = true })
vim.api.nvim_create_autocmd("ColorScheme", { group = group, callback = set_highlights })
vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "DirChanged" }, { group = group, callback = refresh_branch })
vim.api.nvim_create_autocmd({ "DiagnosticChanged", "LspAttach", "LspDetach" }, {
    group = group,
    callback = function() vim.cmd.redrawstatus() end,
})

return M
