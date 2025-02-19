-- Indentation and Tabs
vim.opt.expandtab = true      -- Use spaces instead of tabs
vim.opt.tabstop = 4           -- Number of spaces that a tab counts for
vim.opt.softtabstop = 4       -- Number of spaces for a tab in insert mode
vim.opt.shiftwidth = 4        -- Number of spaces for indentation

-- Line Numbers and Scrolling
vim.opt.number = true         -- Show line numbers
vim.opt.relativenumber = true -- Show relative line numbers
vim.opt.scrolloff = 8         -- Keep 8 lines above/below the cursor
vim.opt.sidescrolloff = 8     -- Keep 8 columns to the left/right of the cursor
vim.opt.wrap = false          -- Disable line wrapping

-- Search
vim.opt.hlsearch = true       -- Highlight search results
vim.opt.incsearch = true      -- Incremental search
vim.opt.ignorecase = true     -- Ignore case when searching
vim.opt.smartcase = true      -- Override ignorecase if search contains uppercase

-- File Formatting
vim.opt.fileformat = "unix"   -- Ensure files are saved with LF line endings

-- Autocommands to handle trailing whitespaces and newlines
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    callback = function()
        -- Remove trailing whitespaces
        vim.cmd([[%s/\s\+$//e]])
        -- Ensure only one newline at the end of the file
        vim.cmd([[%s/\n\+\%$//e]])
        -- Add a newline at the end of the file if missing
        local last_line = vim.fn.getline('$')
        if last_line ~= '' then
            vim.cmd([[normal! Go]])
        end
    end,
})

