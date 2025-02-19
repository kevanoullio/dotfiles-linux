-- Global variables
vim.g.leader = " "

-- Key mappings
-- Telescope key mappings
vim.keymap.set('n', '<C-p>', require('telescope.builtin').find_files, {})
vim.keymap.set('n', '<leader>fg', require('telescope.builtin').live_grep, {})
-- nvim-tree key mappings
vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { noremap = true, silent = true })


-- Define the local plugins to be installed
local plugins = {
    -- Catppuccin colorscheme
    { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
    -- Telescope fuzzy finder tool
    { "nvim-telescope/telescope.nvim", tag = "0.1.8", dependencies = { "nvim-lua/plenary.nvim" } },
    -- nvim-tree file explorer
    {
        "nvim-tree/nvim-tree.lua",
        version = "*",
        lazy = false,
        dependencies = {
            "nvim-tree/nvim-web-devicons", -- optional
        },
        config = function()
            require("nvim-tree").setup {}
        end,
    }
}

-- Define the options for the lazy.nvim package manager
local opts = {}

-- Setup lazy.vim package manager
-- https://github.com/folke/lazy.nvim
require("config.lazy").setup(plugins, opts)

-- Setup Catpuccin color scheme/theme
-- https://github.com/catppuccin/nvim
require("catpuccin").setup()
vim.cmd.colorscheme "catppuccin"

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

-- Common Neovim Settings
vim.opt.expandtab = true      -- Use spaces instead of tabs
vim.opt.tabstop = 4           -- Number of spaces that a tab counts for
vim.opt.softtabstop = 4       -- Number of spaces for a tab in insert mode
vim.opt.shiftwidth = 4        -- Number of spaces for indentation
vim.opt.number = true         -- Show line numbers
vim.opt.relativenumber = true -- Show relative line numbers
vim.opt.wrap = false          -- Disable line wrapping
vim.opt.scrolloff = 8         -- Keep 8 lines above/below the cursor
vim.opt.sidescrolloff = 8     -- Keep 8 columns to the left/right of the cursor
vim.opt.hlsearch = true       -- Highlight search results
vim.opt.incsearch = true      -- Incremental search
vim.opt.ignorecase = true     -- Ignore case when searching
vim.opt.smartcase = true      -- Override ignorecase if search contains uppercase
