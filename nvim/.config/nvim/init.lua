-- ~/.config/nvim/init.lua

-- Leader has to be set before any mappings are made
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Remember Neovim's built-in keymaps so <leader>sk can list only ours
require("config.mykeys").snapshot()

-- New message/cmdline UI (experimental in 0.12)
require("vim._core.ui2").enable({})

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.pack")

-- Plugins, one file each
require("plugins.colorscheme")
require("plugins.oil")
require("plugins.fzf")
require("plugins.harpoon")
require("plugins.treesitter")
require("plugins.lsp")
require("plugins.completion")
require("plugins.formatting")
require("plugins.gitsigns")
require("plugins.hardtime")
require("plugins.dev")

-- Status bar (after the colourscheme, it takes its colours from it)
require("config.statusline")

-- Settings for this machine only (e.g. work plugins); lua/local.lua is not committed
if vim.uv.fs_stat(vim.fn.stdpath("config") .. "/lua/local.lua") then
    require("local")
end
