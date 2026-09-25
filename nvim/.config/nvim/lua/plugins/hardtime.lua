-- Nags when I repeat j/k/h/l (and friends) instead of using a better motion.
vim.pack.add({
    "https://github.com/MunifTanjim/nui.nvim",
    "https://github.com/m4xshen/hardtime.nvim",
})

require("hardtime").setup({ enabled = true })
