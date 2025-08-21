-- Global variables
vim.g.leader = " "

-- Bootstrap lazy.nvim and load plugins
require("config.lazy")

-- Source key mappings (plugins must be sourced first)
require('config.keymappings')

-- Source settings
require('config.settings')

