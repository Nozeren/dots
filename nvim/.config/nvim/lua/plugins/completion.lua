-- Completion popup: LSP, file paths, snippets and words from open buffers.
--
--   Ctrl+n / Ctrl+p   next / previous        Ctrl+y      accept
--   Ctrl+e            close                  Ctrl+space  open menu / toggle docs
--   Ctrl+b / Ctrl+f   scroll docs            Tab/S-Tab   jump inside a snippet
vim.pack.add({
    -- A release tag, so blink can download its prebuilt fuzzy matcher
    { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1.*") },
})

local blink = require("blink.cmp")

blink.setup({
    keymap = { preset = "default" },
    appearance = { nerd_font_variant = "mono" },
    completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 300 },
        menu = { border = "rounded" },
    },
    signature = { enabled = true, window = { border = "rounded" } },
    sources = { default = { "lsp", "path", "snippets", "buffer" } },
    fuzzy = { implementation = "prefer_rust_with_warning" },
})

-- Tell language servers what the completion engine supports (snippets, etc.)
vim.lsp.config("*", { capabilities = blink.get_lsp_capabilities() })
