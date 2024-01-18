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
	{ 'echasnovski/mini.nvim', version = '*' },
	{ "bluz71/vim-nightfly-colors", name = "nightfly", priority = 1000 }, 
	{
		'nvim-telescope/telescope.nvim', 
		tag = '0.1.5', 
		build = "brew install ripgrep; brew install fd",
		dependencies = { 
			{ 'nvim-lua/plenary.nvim' },
			{ 'nvim-treesitter/nvim-treesitter' }
		}, 
		keys = {
			{ "<leader>pv", function () require 'telescope.builtin'.find_files() end, mode = "n" },
			{ "<leader>pf", function () require 'telescope.builtin'.live_grep() end, mode = "n" },
			{ "<leader>ps", function () require 'telescope.builtin'.lsp_workspace_symbols() end, mode = "n" }
		}
	},
	{ "neovim/nvim-lspconfig" }
})

-- lua initialization file
vim.cmd [[colorscheme nightfly]]

require("lua.julio.swift") -- works but it's defined by where nvim was run for the first time. 

vim.wo.number = true -- show line numbers 

-- Demo to search symbols (doesn't work)
vim.keymap.set("n", "<leader>fS", function()
        vim.ui.input({ prompt = "Workspace symbols: " }, function(query)
                ts.lsp_workspace_symbols({ query = query })
        end)
end, { desc = "LSP workspace symbols" })

