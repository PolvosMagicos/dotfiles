return {
  "echasnovski/mini.nvim",
  version = false,
  enabled = true,
  lazy = false,
  config = function()
    require("mini.splitjoin").setup()
    require("mini.surround").setup({ silent = true })
    require("mini.move").setup()
    require("mini.cursorword").setup()
  end,
}
