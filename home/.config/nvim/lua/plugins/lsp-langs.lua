local util = require("lspconfig.util")

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        html = {},
      },
    },
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        olingo = {},
      },
    },
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        astro = {
          cmd = {
            "node",
            util.root_pattern("node_modules/.bin/astro-ls")() .. "/bin/astro-ls.js",
          },
          root_dir = util.root_pattern("package.json", ".git"),
        },
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "astro",
        "css",
        "odin",
      },
    },
  },
}
