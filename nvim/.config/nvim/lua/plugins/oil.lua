-- File explorer: a folder opens as a buffer; edit it and :w to rename, move or delete
vim.pack.add({
    "https://github.com/nvim-tree/nvim-web-devicons",
    "https://github.com/stevearc/oil.nvim",
})

-- Show the folder's path at the top of oil windows
function _G.oil_winbar()
    local dir = require("oil").get_current_dir(vim.api.nvim_win_get_buf(vim.g.statusline_winid))
    return dir and vim.fn.fnamemodify(dir, ":~") or vim.api.nvim_buf_get_name(0)
end

require("oil").setup({
    default_file_explorer = true,   -- also used for `nvim .` and :e some/dir
    delete_to_trash = true,
    view_options = {
        show_hidden = true,
        natural_order = true,       -- file2 before file10
        is_always_hidden = function(name)
            return name == ".." or name == ".git"
        end,
    },
    win_options = {
        wrap = true,
        winbar = "%!v:lua.oil_winbar()",
    },
})

vim.keymap.set("n", "-", "<cmd>Oil --preview<CR>", { desc = "Open parent folder" })
