-- Install plugins, language servers, formatters and treesitter parsers, then quit.
-- Run by install.sh:  nvim --headless -c "lua require('config.bootstrap')"
-- (Plugins are already installed by vim.pack.add while init.lua loads.)

local tools = require("config.tools")
local registry = require("mason-registry")
local function log(msg) io.stdout:write(msg .. "\n") end

-- The package registry has to be loaded before server names can be mapped to packages
local refreshed = false
registry.refresh(function() refreshed = true end)
vim.wait(60000, function() return refreshed end, 200)

-- Language servers (lspconfig names -> mason packages) and formatters
local to_package = require("mason-lspconfig").get_mappings().lspconfig_to_package
local wanted = {}
for _, server in ipairs(tools.servers) do
    if to_package[server] then
        table.insert(wanted, to_package[server])
    else
        log("  FAILED   " .. server .. " (no mason package found)")
    end
end
vim.list_extend(wanted, tools.formatters)

for _, name in ipairs(wanted) do
    local pkg = registry.get_package(name)
    if not pkg:is_installed() and not pkg:is_installing() then
        log("  install  " .. name)
        pkg:install()
    end
end
-- Wait for every install to finish, including ones other plugin files started while loading
vim.wait(900000, function()
    for _, name in ipairs(wanted) do
        if registry.get_package(name):is_installing() then
            return false
        end
    end
    return true
end, 500)
for _, name in ipairs(wanted) do
    log((registry.is_installed(name) and "  ok       " or "  FAILED   ") .. name)
end

-- Treesitter parsers (compiled locally)
if vim.fn.executable("tree-sitter") == 1 then
    log("  building treesitter parsers...")
    require("nvim-treesitter").install(tools.parsers):wait(900000)
else
    log("  SKIPPED  treesitter parsers: tree-sitter-cli is missing")
end

vim.cmd("qa!")
