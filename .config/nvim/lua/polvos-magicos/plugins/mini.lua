return {
	"echasnovski/mini.nvim",
	version = false,
	enabled = true,
	lazy = false,
	config = function()
		require("mini.ai").setup()
		require("mini.splitjoin").setup()
		require("mini.operators").setup()
		require("mini.surround").setup()
		require("mini.move").setup()
		require("mini.cursorword").setup()
	end,
}
