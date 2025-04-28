return {
	"neovim/nvim-lspconfig",
	dependencies = {
		{ "j-hui/fidget.nvim", opts = {} },
		"saghen/blink.cmp",
	},
	lazy = false,
	config = function()
		local capabilities = require("blink.cmp").get_lsp_capabilities()
		local on_attach = require("polvos-magicos.core.utils").on_attach

		local servers = {
			lua_ls = {
				on_attach = on_attach,
				capabilities = capabilities,
				settings = {
					Lua = {
						runtime = { version = "LuaJIT" },
						diagnostics = {
							enable = true,
							globals = { "vim" },
						},
						workspace = {
							library = vim.api.nvim_get_runtime_file("", true),
							checkThirdParty = false,
						},
						telemetry = { enable = false },
						completion = { callSnippet = "Replace" },
					},
				},
			},
			html = {
				on_attach = on_attach,
				capabilities = capabilities,
			},
			tailwindcss = {
				on_attach = on_attach,
				capabilities = capabilities,
			},
			clangd = {
				on_attach = on_attach,
				capabilities = capabilities,
			},
			pylsp = {
				on_attach = on_attach,
				capabilities = capabilities,
			},
			marksman = {
				on_attach = on_attach,
				capabilities = capabilities,
			},
		}

		-- Setup each server
		for server_name, config in pairs(servers) do
			require("lspconfig")[server_name].setup(config)
		end
	end,
}
