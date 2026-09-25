-- ~/.config/nvim/init.lua

-- Leader has to be set before any mappings are made
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- New message/cmdline UI (experimental in 0.12)
require("vim._core.ui2").enable({})

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.pack")

-- Plugins, one file each
require("plugins.colorscheme")

-- Settings for this machine only (e.g. work plugins); lua/local.lua is not committed
if vim.uv.fs_stat(vim.fn.stdpath("config") .. "/lua/local.lua") then
    require("local")
end
