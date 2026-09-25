-- Plugins I write myself, loaded straight from their repos in ~/dev so edits apply on restart.
-- Skipped on machines where the repo isn't cloned.

local function dev_plugin(name, setup)
    local path = vim.fn.expand("~/dev/" .. name)
    if vim.uv.fs_stat(path) then
        vim.opt.rtp:prepend(path)
        setup()
    end
end

-- Gherkin step <-> pytest-bdd step definition (<leader>ss in .feature and Python files)
-- git@github.com:Nozeren/bdd-goto-step.nvim.git (private)
dev_plugin("bdd-goto-step.nvim", function() require("bdd_goto_step").setup() end)
