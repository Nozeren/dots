local map = vim.keymap.set

-- Keep the selection when indenting
map("v", "<", "<gv", { desc = "Unindent and keep selection" })
map("v", ">", ">gv", { desc = "Indent and keep selection" })

-- Keep the cursor centred when jumping
map("n", "<C-d>", "<C-d>zz", { desc = "Half-page down, centred" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half-page up, centred" })
map("n", "n", "nzzzv", { desc = "Next search result, centred" })
map("n", "N", "Nzzzv", { desc = "Previous search result, centred" })

-- Move between splits with Ctrl + h/j/k/l; at the edge of Neovim, carry on into the
-- neighbouring tmux pane (tmux sends these keys to Neovim, see tmux.conf)
local function navigate(dir)
    local win = vim.fn.winnr()
    vim.cmd.wincmd(dir)
    if vim.fn.winnr() == win and vim.env.TMUX then
        vim.system({ "tmux", "select-pane", "-" .. ({ h = "L", j = "D", k = "U", l = "R" })[dir] })
    end
end
map("n", "<C-h>", function() navigate("h") end, { desc = "Move to left split / tmux pane" })
map("n", "<C-j>", function() navigate("j") end, { desc = "Move to lower split / tmux pane" })
map("n", "<C-k>", function() navigate("k") end, { desc = "Move to upper split / tmux pane" })
map("n", "<C-l>", function() navigate("l") end, { desc = "Move to right split / tmux pane" })

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
