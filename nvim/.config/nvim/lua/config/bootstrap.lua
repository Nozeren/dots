-- Install plugins, language servers, formatters and treesitter parsers, then quit.
-- Run by install.sh:  nvim --headless -c "lua require('config.bootstrap')"
-- (Plugins are already installed by vim.pack.add while init.lua loads.)

local tools = require("config.tools")
local registry = require("mason-registry")
local to_package = require("mason-lspconfig").get_mappings().lspconfig_to_package

local function log(msg) io.stdout:write(msg .. "\n") end

-- Language servers and formatters
local wanted = vim.list_extend(vim.tbl_map(function(s) return to_package[s] end, tools.servers), tools.formatters)

local refreshed = false
registry.refresh(function() refreshed = true end)
vim.wait(60000, function() return refreshed end, 200)

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
