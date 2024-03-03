local M = {}

-- Functional wrapper for mapping custom keybindings
M.map = function(mode, lhs, rhs, opts)
	local options = { noremap = true, silent = true }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	vim.keymap.set(mode, lhs, rhs, options)
end

-- open toggleterm with lazygit
M.toggle_lazygit = function()
	local Terminal = require("toggleterm.terminal").Terminal
	local lazygit = Terminal:new({
		cmd = "lazygit",
		hidden = true,
		on_open = function(term)
			vim.cmd("startinsert!")
		end,
		close_on_exit = true,
		direction = "float",
		float_opts = {
			border = "single",
		},
	})
	lazygit:toggle()
end

return M
