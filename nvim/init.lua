-- VIM Key setup:
vim.g.mapleader = " "
vim.keymap.set("n", "<leader>0", vim.cmd.Ex)

-- Install lazy vim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end

vim.opt.rtp:prepend(lazypath)

-- Setup plugins
require("lazy").setup({
	{
		'fedepujol/move.nvim',
		keys = {
			{ "<leader>[", "<cmd>moveblock(-1)<cr>", desc = "moveblockup", mode = "v" },
			{ "<leader>]", "<cmd>moveblock(1)<cr>", desc = "moveblockdown", mode = "v" },
			{ "<leader>[", "<cmd>moveline(-1)<cr>", desc = "moveup", mode = "n" },
			{ "<leader>]", "<cmd>moveline(1)<cr>", desc = "movedown", mode = "n" },
		},
	},
	{ "bluz71/vim-nightfly-colors", name = "nightfly", priority = 1000 }, 
	{
		'nvim-telescope/telescope.nvim', 
		tag = '0.1.5', 
		dependencies = { 'nvim-lua/plenary.nvim' }, 
		keys = {
			{ "<leader>pv", function () require 'telescope.builtin'.find_files() end, mode = "n" }
		}
	}
})

-- lua initialization file
vim.cmd [[colorscheme nightfly]]




