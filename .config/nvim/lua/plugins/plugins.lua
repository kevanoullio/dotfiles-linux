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
            require("telescope").setup{
                defaults = {
                    file_ignore_patterns = { "node_modules" }, -- Add any patterns to ignore
                    vimgrep_arguments = {
                        'rg',                -- The ripgrep command (what follows are the arguments)
                        '--color=never',     -- Disable color in the output (can interfere with parsing the output)
                        '--no-heading',      -- Prevent file headings before each match (makes output more consice)
                        '--with-filename',   -- Include the filename in the output
                        '--line-number',     -- Include the line number in the output
                        '--column',          -- Include the column number in the output
                        '--smart-case',      -- Enable smart case matching (only use case sensitivity if the pattern contains uppercase characters)
                        '--hidden',          -- Include hidden files and directories
                    },
                },
                pickers = {
                    find_files = {
                        hidden = true, -- Include hidden files in find_files picker
                    },
                },
            }
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
    },
    -- which-key plugin
    -- https://github.com/folke/which-key.nvim
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
        },
        keys = {
            {
                "<leader>?",
                function()
                    require("which-key").show({ global = false })
                end,
                desc = "Buffer Local Keymaps (which-key)",
            },
        },
    },
}

return plugins

