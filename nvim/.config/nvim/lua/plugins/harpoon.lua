-- Mark a few files you're working on and jump straight to them
vim.pack.add({
    "https://github.com/nvim-lua/plenary.nvim",
    { src = "https://github.com/ThePrimeagen/harpoon", version = "harpoon2" },
})

local harpoon = require("harpoon")
harpoon:setup()

local map = vim.keymap.set
map("n", "<leader>a", function() harpoon:list():add() end, { desc = "Harpoon: add file" })
map("n", "<leader>h", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon: menu" })
map("n", "<leader>p", function() harpoon:list():prev() end, { desc = "Harpoon: previous file" })
map("n", "<leader>n", function() harpoon:list():next() end, { desc = "Harpoon: next file" })
for i = 1, 4 do
    map("n", "<leader>" .. i, function() harpoon:list():select(i) end, { desc = "Harpoon: file " .. i })
end
