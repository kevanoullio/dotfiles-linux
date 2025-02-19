-- nvim-tree file explorer
-- https://github.com/nvim-tree/nvim-tree.lua
return {
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