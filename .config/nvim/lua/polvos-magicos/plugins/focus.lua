return {
	"nvim-focus/focus.nvim",
	version = "*",
	config = function()
		require("focus").setup({
			ui = {
				cursorline = false,
			},
		})
	end,
}
