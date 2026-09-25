-- Commands for the built-in plugin manager (vim.pack).
-- Plugins themselves are added in lua/plugins/*.lua; versions are pinned in nvim-pack-lock.json.

vim.api.nvim_create_user_command("PackUpdate", function(opts)
    -- No names: update everything. Opens a review buffer; :w applies, :q cancels.
    vim.pack.update(#opts.fargs > 0 and opts.fargs or nil)
end, {
    nargs = "*",
    complete = function()
        return vim.tbl_map(function(p) return p.spec.name end, vim.pack.get(nil, { info = false }))
    end,
    desc = "Update all plugins, or the ones named",
})

vim.api.nvim_create_user_command("PackDel", function(opts)
    vim.pack.del(opts.fargs)
end, {
    nargs = "+",
    complete = function()
        -- Only plugins no longer added in the config can be deleted
        local inactive = vim.tbl_filter(function(p) return not p.active end, vim.pack.get(nil, { info = false }))
        return vim.tbl_map(function(p) return p.spec.name end, inactive)
    end,
    desc = "Delete plugins from disk (remove them from lua/plugins first)",
})
