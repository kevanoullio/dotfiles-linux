-- Key mappings

-- Telescope
vim.keymap.set('n', '<C-p>', require('telescope.builtin').find_files, { desc = "Find Files" })  -- Commonly used for file finder
vim.keymap.set('n', '<leader>ff', require('telescope.builtin').find_files, { desc = "Find Files" })  -- Standard leader key mapping
vim.keymap.set('n', '<leader>lg', require('telescope.builtin').live_grep, { desc = "Live Grep" })

-- neo-tree
vim.keymap.set('n', '<leader>e', ':Neotree toggle<CR>', { noremap = true, silent = true, desc = "Toggle Neo-tree" })

-- which-key
vim.keymap.set('n', '<leader>?', function() require("which-key").show({ mode = "n" }) end, { desc = "Show Normal Mode Keymaps (which-key)" })
vim.keymap.set('v', '<leader>?', function() require("which-key").show({ mode = "v" }) end, { desc = "Show Visual Mode Keymaps (which-key)" })
vim.keymap.set('i', '<C-?>', function() require("which-key").show({ mode = "i" }) end, { desc = "Show Insert Mode Keymaps (which-key)" })

-- nvim-lspconfig
vim.keymap.set('n', 'K', function() vim.lsp.buf.hover() end, { desc = "Show hover information" })
vim.keymap.set('n', 'gd', function() vim.lsp.buf.definition() end, { desc = "Go to definition" })
vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, {}, { desc = "Code action" })

-- none-ls aka null-ls
vim.keymap.set('n', '<leader>gf', vim.lsp.buf.format, {})

-- Register key mappings with which-key
local wk = require("which-key")
wk.add({
    { "<leader>f", group = "File" }, -- group
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find File", mode = "n" },
    { "<leader>lg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep", mode = "n" },
    { "<leader>e", ":Neotree toggle<CR>", desc = "Toggle Neo-tree", mode = "n" },
    { "<leader>?", function() require("which-key").show({ mode = "n" }) end, desc = "Show Normal Mode Keymaps (which-key)", mode = "n" },
    { "<leader>?", function() require("which-key").show({ mode = "v" }) end, desc = "Show Visual Mode Keymaps (which-key)", mode = "v" },
    { "<C-?>", function() require("which-key").show({ mode = "i" }) end, desc = "Show Insert Mode Keymaps (which-key)", mode = "i" },
    { "K", function() vim.lsp.buf.hover() end, desc = "Show hover information", mode = "n" },
})

