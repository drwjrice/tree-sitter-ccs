pcall(vim.treesitter.start)

vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

vim.opt_local.foldmethod = "expr"
vim.opt_local.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt_local.foldenable = false
