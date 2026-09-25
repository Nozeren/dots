-- Formatting with <leader>f (nothing is formatted on save).
vim.pack.add({ "https://github.com/stevearc/conform.nvim" })

-- Formatters that aren't language servers; mason installs them in the background
local registry = require("mason-registry")
registry.refresh(function()
    for _, name in ipairs({ "stylua", "prettier", "djlint" }) do
        local pkg = registry.get_package(name)
        if not pkg:is_installed() then
            pkg:install()
        end
    end
end)

local conform = require("conform")

conform.setup({
    formatters_by_ft = {
        python = { "ruff_organize_imports", "ruff_format" },
        lua = { "stylua" },
        htmldjango = { "djlint" },
        html = { "prettier" },
        css = { "prettier" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
    },
})

vim.keymap.set({ "n", "v" }, "<leader>f", function()
    -- Anything without a formatter above falls back to the language server
    conform.format({ async = true, lsp_format = "fallback" })
end, { desc = "Format file (or selection)" })
