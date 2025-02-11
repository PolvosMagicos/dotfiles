vim.g.mapleader = " "
local utils = require("polvos-magicos.core.utils")
local map = utils.map
map("n", "<leader>ev", vim.cmd.Ex)

-- ╔═════════════════════════════════════════════════╗
-- ║ Window creation                                 ║
-- ╚═════════════════════════════════════════════════╝
map("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })     -- split window vertically
map("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })   -- split window horizontally
map("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })      -- make split windows equal width & height
map("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

-- UndotreeToggle
-- vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)

-- ╔═════════════════════════════════════════════════╗
-- ║ Tab management                                  ║
-- ╚═════════════════════════════════════════════════╝

map("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" })                     -- open new tab
map("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" })              -- close current tab
map("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" })                     --  go to next tab
map("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" })                 --  go to previous tab
map("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" }) --  move current buffer to new tab

-- ╔═════════════════════════════════════════════════╗
-- ║ Dismiss Noice Message                           ║
-- ╚═════════════════════════════════════════════════╝

map("n", "<leader>nd", "<cmd>NoiceDismiss<CR>", { desc = "Dismiss Noice Message" })

-- ╔═════════════════════════════════════════════════╗
-- ║ Telescope                                       ║
-- ╚═════════════════════════════════════════════════╝

map("n", "<leader>ff", "<cmd>lua require('telescope.builtin').find_files()<cr>", { desc = "Find Files" })
map(
  "n",
  "<leader>fg",
  "<cmd>lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>",
  { desc = "Live Grep" }
)
map(
  "n",
  "<leader>fc",
  '<cmd>lua require("telescope.builtin").live_grep({ glob_pattern = "!{spec,test}"})<CR>',
  { desc = "Live Grep Code" }
)
map("n", "<leader>fb", "<cmd>lua require('telescope.builtin').buffers()<cr>", { desc = "Find Buffers" })
-- map("n", "<leader>fh", "<cmd>lua require('telescope.builtin').help_tags()<cr>", { desc = "Find Help Tags" })
map("n", "<leader>fs", "<cmd>lua require('telescope.builtin').lsp_document_symbols()<cr>", { desc = "Find Symbols" })
map("n", "<leader>fo", "<cmd>lua require('telescope.builtin').oldfiles()<cr>", { desc = "Find Old Files" })
map("n", "<leader>fw", "<cmd>lua require('telescope.builtin').grep_string()<cr>", { desc = "Find Word under Cursor" })
map("n", "<leader>gc", "<cmd>lua require('telescope.builtin').git_commits()<cr>", { desc = "Search Git Commits" })
map(
  "n",
  "<leader>gb",
  "<cmd>lua require('telescope.builtin').git_bcommits()<cr>",
  { desc = "Search Git Commits for Buffer" }
)
map("n", "<leader>fh", function()
  require("telescope.builtin").find_files({ hidden = true, no_ignore = true })
end, { desc = "Find Hidden Files" })

-- ╔═════════════════════════════════════════════════╗
-- ║ Snippets                                        ║
-- ╚═════════════════════════════════════════════════╝

map({ "n", "s" }, "<c-j>", function()
  if require("luasnip").expand_or_jumpable() then
    require("luasnip").expand_or_jump()
  end
end, { desc = "Next snippet placeholder" })

map({ "n", "s" }, "<c-k>", function()
  if require("luasnip").jumpable(-1) then
    require("luasnip").jump(-1)
  end
end, { desc = "Previous snippet placeholder" })

map("i", "<c-u>", "<cmd>lua require('luasnip.extras.select_choice')()<cr>", { desc = "Select choice" })

-- ╔═════════════════════════════════════════════════╗
-- ║ Yanky                                           ║
-- ╚═════════════════════════════════════════════════╝
map({ "n", "x" }, "<leader>y", "<cmd>YankyRingHistory<cr>", { desc = "Yanks" })
map({ "n", "x" }, "y", "<Plug>(YankyYank)")
map({ "n", "x" }, "P", "<Plug>(YankyPutBefore)")
map({ "n", "x" }, "p", "<Plug>(YankyPutAfter)")
map("n", "[y", "<Plug>(YankyCycleBackward)", { desc = "Previous yank" })
map("n", "]y", "<Plug>(YankyCycleForward)", { desc = "Next yank" })

-- ╔═════════════════════════════════════════════════╗
-- ║ Lazygit                                         ║
-- ╚═════════════════════════════════════════════════╝
map("n", "<leader>G", "<cmd>lua require('polvos-magicos.core.utils').toggle_lazygit()<cr>", { desc = "Lazygit" })
