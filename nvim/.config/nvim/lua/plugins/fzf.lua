-- Fuzzy finder for files, text, git, help and more (uses fzf, ripgrep and fd)
vim.pack.add({
    "https://github.com/nvim-tree/nvim-web-devicons",
    "https://github.com/ibhagwan/fzf-lua",
})

local fzf = require("fzf-lua")

fzf.setup({
    winopts = {
        fullscreen = true,
        preview = {
            layout = "vertical",
            vertical = "up:60%",    -- preview on top, results below
        },
    },
    defaults = {
        formatter = "path.filename_first",  -- "init.lua  nvim/.config/nvim"
    },
})

local map = vim.keymap.set
map("n", "<leader>sf", fzf.files, { desc = "Search files" })
map("n", "<leader>sg", fzf.live_grep, { desc = "Search text in project" })
map("n", "<leader>sw", fzf.grep_cword, { desc = "Search word under cursor" })
map("n", "<leader>sb", fzf.buffers, { desc = "Search open buffers" })
map("n", "<leader>sh", fzf.helptags, { desc = "Search help" })
map("n", "<leader>sk", fzf.keymaps, { desc = "Search keymaps" })
map("n", "<leader>sd", fzf.diagnostics_workspace, { desc = "Search diagnostics" })
map("n", "<leader>sr", fzf.resume, { desc = "Resume last search" })
map("n", "<leader>gs", fzf.git_status, { desc = "Git status" })
