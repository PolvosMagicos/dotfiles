return {
  "gbprod/yanky.nvim",
  enabled = true,
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    local utils = require("yanky.utils")

    require("yanky").setup({
      highlight = {
        on_put = true,
        on_yank = true,
        timer = 400,
      },
      preserve_cursor_position = {
        enabled = true,
      },
    })
  end,
}
