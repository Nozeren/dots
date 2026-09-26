-- Plugins I write myself. Installed from GitHub with vim.pack on every machine (pinned in the
-- lockfile like any other plugin); if I also have a clone in ~/dev, that one is loaded first so
-- my edits apply on restart.

local function my_plugin(name, setup)
    vim.pack.add({ "https://github.com/Nozeren/" .. name })
    local dev = vim.fn.expand("~/dev/" .. name)
    if vim.uv.fs_stat(dev) then
        vim.opt.rtp:prepend(dev)
    end
    setup()
end

-- Gherkin step <-> pytest-bdd step definition (<leader>ss in .feature and Python files)
my_plugin("steplink.nvim", function() require("steplink").setup() end)
