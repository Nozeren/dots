vim.pack.add({ "https://github.com/neanias/everforest-nvim" })

require("everforest").setup({
    background = "hard", -- "soft" | "medium" | "hard"
    transparent_background_level = 1, -- the terminal's blurred background shows through
    italics = true, -- italic keywords
    sign_column_background = "none",
    ui_contrast = "high", -- line numbers, indent guides, etc.
    float_style = "bright", -- popups a shade lighter than the editor
})

vim.cmd.colorscheme("everforest")
