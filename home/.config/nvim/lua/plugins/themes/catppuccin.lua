-- Catppuccin colorscheme plugin
-- https://github.com/catppuccin/catppuccin
return {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
        vim.g.catppuccin_flavour = "mocha" -- Choose between "latte", "frappe", "macchiato", "mocha"
        vim.cmd.colorscheme "catppuccin"
    end,
}

