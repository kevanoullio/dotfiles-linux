-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Live grep
vim.keymap.set("n", "<leader>lg", function()
  require("fzf-lua").live_grep()
end, { desc = "Live Grep" })

-- Quick file find
vim.keymap.set("n", "<C-p>", function()
  require("fzf-lua").files()
end, { desc = "Find Files" })

-- Format buffer
vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, { desc = "Format buffer" })

-- Show which-key manually
vim.keymap.set("n", "<leader>?", function()
  require("which-key").show({ mode = "n" })
end, { desc = "Show Normal Mode Keymaps (which-key)" })
vim.keymap.set("v", "<leader>?", function()
  require("which-key").show({ mode = "v" })
end, { desc = "Show Visual Mode Keymaps (which-key)" })
vim.keymap.set("i", "<C-?>", function()
  require("which-key").show({ mode = "i" })
end, { desc = "Show Insert Mode Keymaps (which-key)" })
