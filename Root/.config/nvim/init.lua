-- require("plugins")

-- colorscheme
vim.cmd('colo sorbet')

-- line number
vim.wo.number = true
vim.wo.relativenumber = true

-- leader key
vim.g.mapleader = " "

-- tabs
local opt = vim.opt
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true
