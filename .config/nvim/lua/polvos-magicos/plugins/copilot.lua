return {
	"zbirenbaum/copilot.lua",
	enabled = false,
	cond = vim.g.vscode == nil,
	cmd = "Copilot",
	event = "InsertEnter",
	config = function()
		require("copilot").setup({
			suggestion = {
				enabled = true,
				auto_trigger = true,
				debounce = 75,
				keymap = {
					accept = "<c-l>",
					accept_word = false,
					accept_line = false,
					dismiss = "<c-e>",
					next = "<c-j>",
					prev = "<c-k>",
				},
			},
		})
	end,
}
