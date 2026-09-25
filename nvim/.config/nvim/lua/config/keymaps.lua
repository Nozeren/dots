local map = vim.keymap.set

-- Keep the selection when indenting
map("v", "<", "<gv", { desc = "Unindent and keep selection" })
map("v", ">", ">gv", { desc = "Indent and keep selection" })

-- Keep the cursor centred when jumping
map("n", "<C-d>", "<C-d>zz", { desc = "Half-page down, centred" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half-page up, centred" })
map("n", "n", "nzzzv", { desc = "Next search result, centred" })
map("n", "N", "Nzzzv", { desc = "Previous search result, centred" })

-- Move between splits with Ctrl + h/j/k/l
map("n", "<C-h>", "<C-w>h", { desc = "Move to left split" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to lower split" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to upper split" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right split" })

-- Clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Built-in undotree (Neovim 0.12+)
map("n", "<leader>u", function()
    vim.cmd.packadd("nvim.undotree")
    require("undotree").open()
end, { desc = "Toggle undotree" })

-- Use hjkl instead of the arrow keys
map("n", "<left>", '<cmd>echo "Use h to move!!"<CR>')
map("n", "<right>", '<cmd>echo "Use l to move!!"<CR>')
map("n", "<up>", '<cmd>echo "Use k to move!!"<CR>')
map("n", "<down>", '<cmd>echo "Use j to move!!"<CR>')
