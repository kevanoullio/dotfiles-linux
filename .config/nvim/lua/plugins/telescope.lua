-- Telescope fuzzy finder tool
-- https://github.com/nvim-telescope/telescope.nvim
return {
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
}