-- Gruvbox colorscheme plugin
-- https://github.com/morhetz/gruvbox
return {
    {
        "ellisonleao/gruvbox.nvim",
        priority = 1000, -- any high number to ensure it loads early
        config = function()
            vim.cmd("colorscheme gruvbox")
        end
    },
}

