return {
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup({
				ui = {
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗",
					},
				},
			})
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		opts = {
			auto_install = true,
		},
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls", -- Lua
					"clangd", -- C/C++
					"jdtls",  -- Java
					"basedpyright", -- Python / needs to run pip install basedpyright
					"tailwindcss", -- Tailwind CSS
					"html", -- HTML
					"marksman", -- Markdown
				},
				automatic_installation = {
					-- typescritp tools handles ts_ls
					-- rustaceanvim needs `rustup component add rust-analyzer`
					exclude = { "ts_ls", "rust_analyzer" },
				},
				auto_install = true,
			})
		end,
	},
}
