vim.filetype.add({
	extension = {
		isml = "isml",
	},
})

vim.treesitter.language.register("html", "isml")
