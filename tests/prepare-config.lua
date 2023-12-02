local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'

if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		'git',
		'clone',
		'--filter=blob:none',
		'https://github.com/folke/lazy.nvim.git',
		'--branch=stable',
		lazypath,
	})
end

vim.opt.rtp:prepend(lazypath)

local temp_path = './.test_plugins'

require('lazy').setup({
	{
		'neovim/nvim-lspconfig',
		lazy = false,
	},
	{
		'nvim-lua/plenary.nvim',
		lazy = false,
	},
	{
		'williamboman/mason.nvim',
		lazy = false,
	},
}, {
	root = temp_path,
	lockfile = temp_path .. '/lazy-lock.json',
	defaults = {
		lazy = false,
	},
})

-- vim.opt.rtp:append(temp_path .. '/plenary.nvim')
-- vim.opt.rtp:append(temp_path .. '/nvim-lspconfig')
-- vim.cmd('runtime plugin/plenary.vim')
-- vim.print(require('plenary.busted'))
