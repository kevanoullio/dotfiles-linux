-- alpha-nvim dashboard plugin
-- https://github.com/goolord/alpha-nvim
return {
    "goolord/alpha-nvim",
    dependencies = {
        "echasnovski/mini.icons",
        "nvim-lua/plenary.nvim"
    },

    config = function ()
        local alpha = require("alpha")
        local dashboard = require("alpha.themes.dashboard")
    end
};

