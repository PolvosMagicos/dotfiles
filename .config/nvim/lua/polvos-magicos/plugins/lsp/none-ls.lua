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
		})

		vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})
	end,
}
