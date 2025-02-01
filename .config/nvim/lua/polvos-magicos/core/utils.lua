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

M.on_attach = function(client, bufnr)
	local augroup = vim.api.nvim_create_augroup("LspFormatting", { clear = true })
	-- Set up keymaps (shared across all servers)
	local opts = { noremap = true, silent = true, buffer = bufnr }
	vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Show Hover Information" }))
	vim.keymap.set(
		"n",
		"<leader>gd",
		vim.lsp.buf.definition,
		vim.tbl_extend("force", opts, { desc = "Go to Definition" })
	)
	vim.keymap.set(
		"n",
		"<leader>gr",
		vim.lsp.buf.references,
		vim.tbl_extend("force", opts, { desc = "List References" })
	)
	vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code Action" }))
	vim.keymap.set("n", "<leader>lh", function()
		vim.lsp.inlay_hint(bufnr, not vim.lsp.inlay_hint.is_enabled(bufnr))
	end, vim.tbl_extend("force", opts, { desc = "Toggle Inlay Hints" }))

	-- Enable formatting on save (if supported by the server)
	if client.supports_method("textDocument/formatting") then
		-- Clear existing autocommands for this buffer
		vim.api.nvim_clear_autocmds({
			group = augroup,
			buffer = bufnr,
		})
		-- Add a new autocommand for formatting on save
		vim.api.nvim_create_autocmd("BufWritePre", {
			group = augroup,
			buffer = bufnr,
			callback = function()
				vim.lsp.buf.format({ bufnr = bufnr })
			end,
		})
	end
end

return M
