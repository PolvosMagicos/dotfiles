return {
	"neovim/nvim-lspconfig",
	lazy = false,
	config = function()
		local capabilities = require("cmp_nvim_lsp").default_capabilities()
		local lspconfig = require("lspconfig")
		local on_attach = require("polvos-magicos.core.utils").on_attach

		local status, nvim_lsp = pcall(require, "lspconfig")
		if not status then
			return
		end

		local protocol = require("vim.lsp.protocol")

		lspconfig.lua_ls.setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})
		lspconfig.ts_ls.setup({
			filetypes = { "javascript", "javascriptreact", "javascript.jsx" },
			capabilities = capabilities,
			on_attach = on_attach,
		})
		lspconfig.html.setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})
		lspconfig.tailwindcss.setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})
		lspconfig.clangd.setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})
		lspconfig.pylsp.setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})
		require("lspconfig").marksman.setup({
			capabilities = capabilities,
			on_attach = on_attach,
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
