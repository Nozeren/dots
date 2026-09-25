-- Update plugins, language servers, formatters and treesitter parsers, then quit.
-- Run by install.sh:  nvim --headless -c "lua require('config.update')"
-- Plugin updates change nvim-pack-lock.json; commit it so other machines get the same versions.

local tools = require("config.tools")
local function log(msg) io.stdout:write(msg .. "\n") end

-- Plugins (no review buffer; the lockfile diff is the record of what changed)
log("  plugins...")
vim.pack.update(nil, { force = true })

-- Language servers and formatters: reinstall any that have a newer version
local registry = require("mason-registry")
local refreshed = false
registry.refresh(function() refreshed = true end)
vim.wait(60000, function() return refreshed end, 200)

local to_package = require("mason-lspconfig").get_mappings().lspconfig_to_package
local names = vim.list_extend(vim.tbl_map(function(s) return to_package[s] end, tools.servers), tools.formatters)
local updating = {}
for _, name in ipairs(names) do
    local pkg = registry.get_package(name)
    if pkg:is_installed() then
        local current, latest = pkg:get_installed_version(), pkg:get_latest_version()
        if current ~= latest then
            log(("  update   %s %s -> %s"):format(name, current or "?", latest or "?"))
            table.insert(updating, pkg)
            pkg:install()
        end
    end
end
vim.wait(900000, function()
    for _, pkg in ipairs(updating) do
        if pkg:is_installing() then
            return false
        end
    end
    return true
end, 500)
if #updating == 0 then
    log("  language servers and formatters are up to date")
end

-- Treesitter parsers
log("  treesitter parsers...")
require("nvim-treesitter").update():wait(900000)

vim.cmd("qa!")
