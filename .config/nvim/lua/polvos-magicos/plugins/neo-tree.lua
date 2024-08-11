return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},
	config = function()
		vim.keymap.set("n", "<C-n>", ":Neotree filesystem reveal left toggle<CR>", { silent = true })
		vim.keymap.set("n", "<leader>bf", ":Neotree buffers reveal float<CR>", {})

		require("neo-tree").setup({
			window = {
				position = "right",
				width = 40,
			},
			filesystem = {
				filtered_items = {
					visible = true, -- This makes hidden items visible
					hide_dotfiles = false,
					hide_gitignored = false,
				},
			},
		})
	end,
}
