return {
	"akinsho/toggleterm.nvim",
	enabled = true,
	cond = vim.g.vscode == nil,
	cmd = { "ToggleTerm", "ToggleTermToggleAll", "TermExec" },
	config = function()
		require("toggleterm").setup({
      -- for windows
			-- shell = "powershell",
			size = function(term)
				if term.direction == "horizontal" then
					return vim.o.lines * 0.4
				elseif term.direction == "vertical" then
					return vim.o.columns * 0.4
				end
			end,
			start_in_insert = true,
			close_on_exit = false,
			shade_terminals = true,
			hide_numbers = true,
			autochdir = false,
			direction = "float",
		})
	end,
}
