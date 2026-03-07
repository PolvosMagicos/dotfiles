return {
	name = "html",
	config = {
		cmd = { "vscode-html-language-server", "--stdio" },
		filetypes = { "html", "isml" },
		root_markers = { "package.json", ".git" },
	},
}
