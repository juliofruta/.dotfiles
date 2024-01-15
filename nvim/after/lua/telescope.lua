local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<C-p>', builtin.git_files, {})
--vim.keymap.set('n', '<D-F>', builtin.live_grep, {})
vim.keymap.set('n', '<leader>gg', function() 
	builtin.grep_string({ search = vim.fn.input("Grep > ") });
end)
