-- alpha-nvim dashboard plugin
-- https://github.com/goolord/alpha-nvim
return {
    "goolord/alpha-nvim",
    dependencies = {
        "echasnovski/mini.icons",
        "nvim-lua/plenary.nvim"
    },
    config = function()
        local alpha = require("alpha")
        local dashboard = require("alpha.themes.dashboard")

        -- Define day and night themes for each theme
        local themes = {
            default = {
                day = "habamax",
                night = "habamax"
            },
            catppuccin = {
                day = "catppuccin",
                night = "catppuccin"
            },
            gruvbox = {
                day = "gruvbox",
                night = "gruvbox"
            }
        }

        -- Function to switch themes based on time
        local function set_theme(theme_name)
            local hour = tonumber(os.date("%H"))
            local theme = themes[theme_name]
            if hour >= 6 and hour < 18 then
                vim.cmd("colorscheme " .. theme.day)
            else
                vim.cmd("colorscheme " .. theme.night)
            end
        end

        -- Set the default theme
        set_theme("default")

        -- Set header
        dashboard.section.header.val = {
            [[                               __                ]],
            [[  ___     ___    ___   __  __ /\_\    ___ ___    ]],
            [[ / _ `\  / __`\ / __`\/\ \/\ \\/\ \ /' __` __`\  ]],
            [[/\ \/\ \/\  __//\ \_\ \ \ \_/ |\ \ \/\ \/\ \/\ \ ]],
            [[\ \_\ \_\ \____\ \____/\ \___/  \ \_\ \_\ \_\ \_\]],
            [[ \/_/\/_/\/____/\/___/  \/__/    \/_/\/_/\/_/\/_/]],
            "",
            "Welcome to Neovim",
            "Enjoy your coding!"
        }

        -- Set menu
        dashboard.section.buttons.val = {
            dashboard.button("e", "  New file", ":ene <BAR> startinsert <CR>"),
            dashboard.button("f", "  Find file", ":Telescope find_files<CR>"),
            dashboard.button("r", "  Recent files", ":Telescope oldfiles<CR>"),
            dashboard.button("s", "  Settings", ":e $MYVIMRC<CR>"),
            dashboard.button("t", "  Switch Theme", ":lua select_theme()<CR>"),
            dashboard.button("q", "  Quit", ":qa<CR>")
        }

        -- Set footer
        dashboard.section.footer.val = "Have a great day!"

        -- Apply the dashboard configuration
        alpha.setup(dashboard.opts)

        -- Function to prompt user to select a theme
        local function select_theme()
            local theme_names = vim.tbl_keys(themes)
            local choice = vim.fn.inputlist(vim.tbl_map(function(name, index)
                return string.format("%d. %s", index, name)
            end, theme_names))
            if choice > 0 and choice <= #theme_names then
                set_theme(theme_names[choice])
            end
        end
    end
}

