-- Bootstrap lazy.nvim package manager
-- https://github.com/folke/lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local function load_plugins_from(dir)
  local plugin_list = {}
  local path = vim.fn.stdpath("config") .. "/lua/" .. dir
  local files = vim.fn.globpath(path, "**/*.lua", false, true) -- Scan recursively

  for _, file in ipairs(files) do
    local module_name = file:match("lua/(.+)%.lua$"):gsub("/", ".") -- Convert path to module name
    if not module_name:match("%.init$") then -- Avoid init.lua if present
      table.insert(plugin_list, require(module_name))
    end
  end

  return plugin_list
end

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- Load plugins from the plugins directory and its subdirectories
    unpack(load_plugins_from("plugins")),
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax", "catppuccin", "gruvbox" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})

return {}
