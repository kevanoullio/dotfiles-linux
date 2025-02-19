-- Global variables
vim.g.leader = " "

-- Source plugins
require('plugins.lazy')

-- Source key mappings (plugins must be sourced first)
require('config.keymappings')

-- Source settings
require('config.settings')

-- Source theme
require('config.theme')
