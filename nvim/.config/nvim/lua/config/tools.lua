-- Everything installed for code support, in one place. Used by the plugin files and by
-- lua/config/bootstrap.lua (run by install.sh to set up a machine without opening Neovim).
return {
    -- Language servers (nvim-lspconfig names), installed by mason
    servers = {
        "basedpyright",
        "ruff",
        "pytest_language_server",
        "lua_ls",
        "html",
        "djlsp",
        "cssls",
        "vtsls",
        "cucumber_language_server",
    },
    -- Formatters that aren't language servers (mason package names)
    formatters = { "stylua", "prettier", "djlint" },
    -- Treesitter parsers (Neovim already ships lua, vim, vimdoc, query, markdown and c)
    parsers = {
        "python",
        "html",
        "htmldjango",
        "css",
        "javascript",
        "typescript",
        "tsx",
        "json",
        "yaml",
        "toml",
        "sql",
        "bash",
        "luadoc",
        "regex",
        "diff",
        "gitcommit",
    },
}
