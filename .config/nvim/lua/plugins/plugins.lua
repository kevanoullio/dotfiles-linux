-- Define the local plugins to be installed via lazy.vim package manager
local plugins = {
    -- Catppuccin colorscheme
    -- https://github.com/catppuccin/catppuccin
    { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
    -- Telescope fuzzy finder tool
    -- https://github.com/nvim-telescope/telescope.nvim
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.8",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("telescope").setup{}
        end,
    },
    -- nvim-tree file explorer
    -- https://github.com/nvim-tree/nvim-tree.lua
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
    },
    -- nvim-treesitter for better syntax highlighting
    -- https://github.com/nvim-treesitter/nvim-treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        run = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                -- Set languages to setup parsers (can also use TSInstall command in nvim)
                ensure_installed = {
                    "c", "cpp", "c_sharp",
                    "lua", "vim", "vimdoc", "query",
                    "html", "css", "javascript", "typescript", "json",
                    "python", "java", "kotlin", "go", "ruby", "php", "rust",
                    "sql", "yaml", "toml"
                },
                sync_install = false,  -- Install parsers asynchronously (false: synchronously)
                highlight = { enable = true }, -- Enable syntax highlighting for installed parsers
                indent = { enable = true },  -- Enable automatic indentation based on the syntax tree for the installed parsers
            })
        end,
    }
}

return plugins
