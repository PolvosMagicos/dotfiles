return {
	name = "tailwindcss",
	config = {
		cmd = { "tailwindcss-language-server", "--stdio" },
		filetypes = {
			"html",
			"css",
			"scss",
			"javascript",
			"javascriptreact",
			"typescript",
			"typescriptreact",
			"vue",
			"svelte",
		},
		root_markers = {
			"tailwind.config.js",
			"tailwind.config.ts",
			"postcss.config.js",
			"postcss.config.ts",
			"package.json",
			".git",
		},
	},
}
