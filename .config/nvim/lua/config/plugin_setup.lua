-- Setup telescope.nvim fuzzy finder tool
-- https://github.com/nvim-telescope/telescope.nvim
local builtin = require("telescope.builtin")

-- Setup nvim-treesitter
-- https://github.com/nvim-treesitter/nvim-treesitter
require("lazy").setup({{"nvim-treesitter/nvim-treesitter", build = ":TSUpdate"}})
local config = require("nvim-treesitter.configs")
-- Set languages to setup parsers (can also use TSInstall command in nvim)
config.setup({
    ensure_installed = {
        "c", "cpp", "c_sharp",
        "lua", "vim", "vimdoc", "query",
        "html", "css", "javascript", "typescript", "json",
        "python", "java", "kotlin", "go", "ruby", "php", "rust",
        "sql", "sqlite", "yaml", "toml"
    },
    sync_install = false,  -- Install parsers asynchronously (false: synchronously)
    highlight = { enable = true }, -- Enable syntax highlighting for installed parsers
    indent = { enable = true },  -- Enable automatic indentation based on the syntax tree for the installed parsers
})
