local opt = vim.opt -- for conciseness

-- line numbers
opt.nu = true
opt.relativenumber = true -- show relative line numbers
opt.number = true         -- shows absolute line number on cursor line (when relative number is on)

-- tabs & indentation
opt.tabstop = 2       -- 2 spaces for tabs (prettier default)
opt.shiftwidth = 2    -- 2 spaces for indent width
opt.expandtab = true  -- expand tab to spaces
opt.autoindent = true -- copy indent from current line when startiuone
opt.smartindent = true

-- line wrap
opt.wrap = false

-- files
opt.swapfile = false
opt.backup = false
opt.undofile = true
opt.undodir = os.getenv("HOME") .. "/.vim/undodir"

-- termguicolors
opt.termguicolors = true

-- scroll
opt.scrolloff = 8
opt.isfname:append("@-@")

opt.updatetime = 50

-- search settings
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true  -- if you include mixed case in your search, assumes you want case-sensitive
opt.hlsearch = false
opt.incsearch = true

-- cursor line
opt.cursorline = false -- highlight the current cursor line

-- clipboard
opt.clipboard:append("unnamedplus") -- use system clipboard as default register

-- split windows
opt.splitright = true -- split vertical window to the right
opt.splitbelow = true -- split horizontal window to the bottom

-- Rustfmt autosave
vim.g.rustfmt_autosave = 1

-- Function to show errors in floating window

-- vim.diagnostic.config({
--   virtual_text = false,
--   signs = true,
--   float = { border = "single" },
-- })

-- Configure diagnostics
vim.diagnostic.config({
  virtual_text = false, -- Disable inline diagnostics
  signs = true,        -- Show signs in gutter
  underline = true,    -- Underline problematic code
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    focusable = true, -- Allow focusing the float window
    source = true,  -- Show diagnostic source
  },
})

-- Show diagnostics on CursorHold
vim.api.nvim_create_autocmd("CursorHold", {
  pattern = "*",
  callback = function()
    vim.diagnostic.open_float({ scope = "cursor" })
  end,
})
