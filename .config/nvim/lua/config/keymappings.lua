-- Key mappings
-- Telescope key mappings
vim.keymap.set('n', '<leader>ff', require('telescope.builtin').find_files, {})
vim.keymap.set('n', '<leader>lg', require('telescope.builtin').live_grep, {})

-- nvim-tree key mappings
vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { noremap = true, silent = true })

