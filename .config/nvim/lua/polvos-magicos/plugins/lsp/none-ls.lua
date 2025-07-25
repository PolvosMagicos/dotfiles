return {
	"nvimtools/none-ls.nvim",
	config = function()
		local null_ls = require("null-ls")
		local on_attach = require("polvos-magicos.core.utils").on_attach

		null_ls.setup({
			sources = {
				-- formatters
				null_ls.builtins.formatting.stylua,
				null_ls.builtins.formatting.prettierd,
				null_ls.builtins.formatting.clang_format,
				null_ls.builtins.formatting.ruff,

				-- linters
				-- null_ls.builtins.diagnostics.eslint,
				null_ls.builtins.diagnostics.markdownlint,
				null_ls.builtins.diagnostics.ruff,

				-- completion

				-- code actions
				null_ls.builtins.code_actions.ruff,
			},

			on_attach = on_attach,

			--[[ -- you can reuse a shared lspconfig on_attach callback here
			on_attach = function(client, bufnr)
				if client.supports_method("textDocument/formatting") then
					vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
					vim.api.nvim_create_autocmd("BufWritePre", {
						group = augroup,
						buffer = bufnr,
						callback = function()
							-- on 0.8, you should use vim.lsp.buf.format({ bufnr = bufnr }) instead
							-- on later neovim version, you should use vim.lsp.buf.format({ async = false }) instead
							vim.lsp.buf.formatting_sync()
						end,
					})
				end
			end, ]]
		})

		vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})
	end,
}
