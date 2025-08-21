-- none-ls.nvim language server stuff and for auto formatting
-- https://github.com/nvimtools/none-ls.nvim
return {
    "nvimtools/none-ls.nvim",
    config = function()
        local null_ls = require("null-ls")

        null_ls.setup({
            sources = {
                null_ls.builtins.formatting.stylua, -- need to install stylua lua formatter via :Mason
                null_ls.builtins.formatting.prettier, -- need to install prettier javascript formatter via :Mason
                null_ls.builtins.formatting.black, -- need to install black python formatter via :Mason
                null_ls.builtins.formatting.isort, -- need to install isort python sorting imports via :Mason
                null_ls.builtins.diagnostics.eslint_d, -- need to install eslint_d linter via :Mason
--                 null_ls.builtins.diagnostics.rubocop, -- need to install rubocop linter via :Mason
--                 null_ls.builtins.formatting.rubocop,
            },
        })
    end,
}

