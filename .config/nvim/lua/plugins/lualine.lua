-- lualine plugin
-- https://github.com/nvim-lualine/lualine.nvim
return {
    "https://github.com/nvim-lualine/lualine.nvim",
    dependencies = {
        'nvim-tree/nvim-web-devicons'
    },
    config = function()
        require("lualine").setup({
            -- Your configuration comes here
            -- or leave it empty to use the default settings
        })
    end,
}

