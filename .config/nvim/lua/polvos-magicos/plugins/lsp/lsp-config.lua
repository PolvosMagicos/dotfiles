return {
	"neovim/nvim-lspconfig",
	lazy = false,
	config = function()
		local capabilities = require("cmp_nvim_lsp").default_capabilities()
		local lspconfig = require("lspconfig")

		local status, nvim_lsp = pcall(require, "lspconfig")
		if not status then
			return
		end

		local protocol = require("vim.lsp.protocol")

		local on_attach = function(client, bufnr)
			-- format on save
			if client.server_capabilities.documentFormattingProvider then
				vim.api.nvim_create_autocmd("BufWritePre", {
					group = vim.api.nvim_create_augroup("Format", { clear = true }),
					buffer = bufnr,
					callback = function()
						vim.lsp.buf.formatting_seq_sync()
					end,
				})
			end
		end

		vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Get hover" })
		vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, { desc = "Get definition" })
		vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, { desc = "Get references" })
		vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Get code actions" })
		vim.keymap.set("n", "<leader>lh", function()
			vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
		end, { desc = "Toggle inlay hints" })

		lspconfig.lua_ls.setup({
			capabilities = capabilities,
		})
		lspconfig.tsserver.setup({
			capabilities = capabilities,
		})
		lspconfig.html.setup({
			capabilities = capabilities,
		})
		lspconfig.tailwindcss.setup({
			capabilities = capabilities,
		})
		lspconfig.clangd.setup({
			capabilities = capabilities,
		})
		lspconfig.pylsp.setup({
			capabilities = capabilities,
		})

		--[[ -- Needs to run this to fix ERROR: "npm -g i eslint-cli"
		lspconfig.eslint.setup({
			on_attach = function(client, bufnr)
				vim.api.nvim_create_autocmd("BufWritePre", {
					buffer = bufnr,
					command = "EslintFixAll",
				})
			end,
		}) ]]
	end,
}
