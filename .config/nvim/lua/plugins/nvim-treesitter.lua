-- nvim-treesitter for better syntax highlighting
-- https://github.com/nvim-treesitter/nvim-treesitter
return {
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