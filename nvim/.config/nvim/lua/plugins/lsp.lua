-- Language servers: installed by mason, configured by nvim-lspconfig, started by Neovim.
--
-- Neovim 0.12 already maps (in any buffer with a server attached):
--   K    hover docs          grn  rename            gra  code action
--   grr  references          gri  implementation    grt  type definition
--   gO   document symbols    <C-s> (insert) signature help
vim.pack.add({
    "https://github.com/neovim/nvim-lspconfig",
    "https://github.com/mason-org/mason.nvim",
    "https://github.com/mason-org/mason-lspconfig.nvim",
    "https://github.com/rachartier/tiny-inline-diagnostic.nvim",
})

-- ---------------------------------------------------------------- servers

-- Python: basedpyright for types/navigation, ruff for linting (and formatting)
vim.lsp.config("basedpyright", {
    settings = {
        basedpyright = {
            analysis = {
                typeCheckingMode = "standard",      -- the default "recommended" is very strict
                diagnosticMode = "openFilesOnly",
            },
        },
    },
})
vim.api.nvim_create_autocmd("LspAttach", {
    desc = "Let basedpyright handle hover docs, not ruff",
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client.name == "ruff" then client.server_capabilities.hoverProvider = false end
    end,
})

-- Lua: knows about Neovim's API, for editing this config
vim.lsp.config("lua_ls", {
    settings = {
        Lua = {
            runtime = { version = "LuaJIT" },
            workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
        },
    },
})

-- HTML server also in Django templates (djlsp adds the {% %} / {{ }} tags)
vim.lsp.config("html", { filetypes = { "html", "htmldjango" } })

-- Gherkin: match steps in .feature files to Python step definitions
vim.lsp.config("cucumber_language_server", {
    settings = {
        cucumber = {
            features = { "**/*.feature" },
            glue = { "**/*.py" },
        },
    },
})

require("mason").setup()
require("mason-lspconfig").setup({
    -- Installed on first start, then enabled automatically
    ensure_installed = {
        "basedpyright", "ruff",
        "lua_ls",
        "html", "djlsp", "cssls", "vtsls",
        "cucumber_language_server",
    },
})

-- ---------------------------------------------------------------- keymaps

vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show line diagnostics" })

-- ---------------------------------------------------------------- diagnostics

vim.diagnostic.config({
    virtual_text = false,           -- tiny-inline-diagnostic shows the message instead
    severity_sort = true,
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "×",
            [vim.diagnostic.severity.WARN] = "×",
            [vim.diagnostic.severity.INFO] = "×",
            [vim.diagnostic.severity.HINT] = "×",
        },
    },
    float = { border = "rounded", source = true },
})

require("tiny-inline-diagnostic").setup({
    options = {
        show_source = { enabled = true },
        add_messages = { display_count = true },
        multilines = { enabled = true },
    },
})
