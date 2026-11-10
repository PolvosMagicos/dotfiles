for _, file in ipairs(vim.fn.glob(".config/nvim/**/*.lua", false, true)) do
  assert(loadfile(file), file)
end

vim.opt.rtp:prepend(vim.fn.getcwd() .. "/.config/nvim")
require("polvos-magicos.core.filetypes")
assert(vim.filetype.match({ filename = "template.isml" }) == "isml")

local on_attach = require("polvos-magicos.core.utils").on_attach
local buffers = { vim.api.nvim_create_buf(true, false), vim.api.nvim_create_buf(true, false) }
for id, bufnr in ipairs(buffers) do
  on_attach({ id = id, supports_method = function() return true end }, bufnr)
end
for _, bufnr in ipairs(buffers) do
  assert(#vim.api.nvim_get_autocmds({ group = "LspFormatting", buffer = bufnr }) == 1,
    "Attaching another buffer must preserve formatting on save")
end
print("Lua syntax, ISML and formatting checks passed")
