return {
  "folke/snacks.nvim",
  opts = {
    dashboard = {
      preset = {
        header = vim.fn.readfile(
          vim.fn.stdpath("config") .. "/lua/ascii-art-night-sky.txt"
        ),
      },
    },
  },
}
