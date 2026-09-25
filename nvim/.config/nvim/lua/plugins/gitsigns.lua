-- Git changes in the gutter, plus staging, resetting and blame per change ("hunk").
vim.pack.add({ "https://github.com/lewis6991/gitsigns.nvim" })

local gs = require("gitsigns")

gs.setup({
    signs = {
        add = { text = "┃" },
        change = { text = "┃" },
        delete = { text = "▁" },
        topdelete = { text = "▔" },
        changedelete = { text = "┃" },
        untracked = { text = "┆" },
    },
    current_line_blame = false, -- toggle with <leader>gB
    current_line_blame_opts = { delay = 300 },
})

local map = vim.keymap.set

-- Move between changes
map("n", "]h", function() gs.nav_hunk("next") end, { desc = "Next git change" })
map("n", "[h", function() gs.nav_hunk("prev") end, { desc = "Previous git change" })

-- Stage / reset (in visual mode: just the selected lines)
map("n", "<leader>ga", gs.stage_hunk, { desc = "Git: stage change (again to unstage)" })
map("n", "<leader>gr", gs.reset_hunk, { desc = "Git: reset change" })
map(
    "v",
    "<leader>ga",
    function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end,
    { desc = "Git: stage lines" }
)
map(
    "v",
    "<leader>gr",
    function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end,
    { desc = "Git: reset lines" }
)
map("n", "<leader>gA", gs.stage_buffer, { desc = "Git: stage file" })
map("n", "<leader>gR", gs.reset_buffer, { desc = "Git: reset file" })

-- Look at changes and history
map("n", "<leader>gp", gs.preview_hunk, { desc = "Git: preview change" })
map("n", "<leader>gd", gs.diffthis, { desc = "Git: diff file against index" })
map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, { desc = "Git: blame line" })
map("n", "<leader>gB", gs.toggle_current_line_blame, { desc = "Git: toggle inline blame" })

-- "ih" = the change under the cursor, e.g. dih deletes it, vih selects it
map({ "o", "x" }, "ih", gs.select_hunk, { desc = "Git change (text object)" })
