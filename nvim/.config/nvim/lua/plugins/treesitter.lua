-- Syntax highlighting, indentation and folding from real parsers (nvim-treesitter "main" branch).
-- Parsers are compiled locally, which needs tree-sitter-cli and a C compiler (see packages/).

-- Rebuild parsers when the plugin updates (registered before vim.pack.add so it sees the install too)
vim.api.nvim_create_autocmd("PackChanged", {
    callback = function(ev)
        if ev.data.spec.name == "nvim-treesitter" and ev.data.kind == "update" then
            if not ev.data.active then
                vim.cmd.packadd("nvim-treesitter")
            end
            vim.cmd("TSUpdate")
        end
    end,
})

vim.pack.add({ { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" } })

local M = {}
local parsers = require("config.tools").parsers

if vim.fn.executable("tree-sitter") == 1 then
    -- Runs in the background; skips ones already built. Kept so config.bootstrap can wait for it
    M.install = require("nvim-treesitter").install(parsers)
else
    vim.notify("treesitter: install tree-sitter-cli to build parsers (./install.sh packages)", vim.log.levels.WARN)
end

-- Turn treesitter on for every buffer that has a parser
vim.api.nvim_create_autocmd("FileType", {
    callback = function(args)
        if pcall(vim.treesitter.start, args.buf) then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            vim.wo.foldmethod = "expr"
            vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        end
    end,
})

return M
