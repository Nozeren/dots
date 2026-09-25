local opt = vim.opt

-- Line numbers
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.colorcolumn = "120"

-- Indentation: 4 spaces
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true
opt.breakindent = true

-- Display
opt.wrap = false
opt.scrolloff = 8
opt.termguicolors = true
opt.showmode = false
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50"

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = false
opt.incsearch = true
opt.inccommand = "split"

-- Splits
opt.splitbelow = true
opt.splitright = true
opt.laststatus = 3

-- Files and undo
opt.swapfile = false
opt.backup = false
opt.undofile = true
opt.undodir = vim.fn.stdpath("data") .. "/undodir"

-- Behaviour
opt.mouse = "a"
opt.clipboard:append("unnamedplus")
opt.completeopt = "menuone,noinsert,noselect,fuzzy"
opt.shortmess:append("c")
opt.isfname:append("@-@")
opt.updatetime = 50
opt.timeoutlen = 300

vim.g.netrw_banner = 0
vim.g.have_nerd_font = true
