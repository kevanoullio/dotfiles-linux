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
local opts = {}

-- Setup lazy.vim package manager
-- https://github.com/folke/lazy.nvim
require("config.lazy").setup(plugins, opts)

-- Source additional plugin setup
require('config.plugin_setup')
