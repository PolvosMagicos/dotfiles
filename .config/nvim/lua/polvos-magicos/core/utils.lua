local M = {}

-- Functional wrapper for mapping custom keybindings
M.map = function(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

-- open toggleterm with lazygit
M.toggle_lazygit = function()
  local Terminal = require("toggleterm.terminal").Terminal
  local lazygit = Terminal:new({
    cmd = "lazygit",
    hidden = true,
    on_open = function()
      vim.cmd("startinsert!")
    end,
    close_on_exit = true,
    direction = "float",
    float_opts = {
      border = "single",
    },
  })
  lazygit:toggle()
end

M.on_attach = function(client, bufnr)
  local augroup = vim.api.nvim_create_augroup("LspFormatting", { clear = true })
  -- Set up keymaps (shared across all servers)
  local opts = { noremap = true, silent = true, buffer = bufnr }

  -- Navigation
  vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Show Hover Information" }))
  vim.keymap.set("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "Go to Declaration" }))
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to Definition" }))
  vim.keymap.set(
    "n",
    "gi",
    vim.lsp.buf.implementation,
    vim.tbl_extend("force", opts, { desc = "Go to Implementation" })
  )
  vim.keymap.set("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "List References" }))
  vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, vim.tbl_extend("force", opts, { desc = "Signature Help" }))

  -- Navigation (using new jump API)
  vim.keymap.set("n", "]d", function()
    vim.diagnostic.jump({
      count = 1,
      float = { border = "rounded" },
    })
  end, vim.tbl_extend("force", opts, { desc = "Next diagnostic" }))

  vim.keymap.set("n", "[d", function()
    vim.diagnostic.jump({
      count = -1, -- Negative count goes backwards
      float = { border = "rounded" },
    })
  end, vim.tbl_extend("force", opts, { desc = "Previous diagnostic" }))
  vim.keymap.set(
    "n",
    "<leader>q",
    vim.diagnostic.setloclist,
    vim.tbl_extend("force", opts, { desc = "Diagnostics to Loclist" })
  )

  -- Workspace
  vim.keymap.set(
    "n",
    "<leader>wa",
    vim.lsp.buf.add_workspace_folder,
    vim.tbl_extend("force", opts, { desc = "Add Workspace Folder" })
  )
  vim.keymap.set(
    "n",
    "<leader>wr",
    vim.lsp.buf.remove_workspace_folder,
    vim.tbl_extend("force", opts, { desc = "Remove Workspace Folder" })
  )
  vim.keymap.set("n", "<leader>wl", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, vim.tbl_extend("force", opts, { desc = "List Workspace Folders" }))

  -- Code Actions
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code Action" }))
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename Symbol" }))
  vim.keymap.set("n", "<leader>f", function()
    vim.lsp.buf.format({ async = true })
  end, vim.tbl_extend("force", opts, { desc = "Format Buffer" }))

  -- Inlay Hints
  vim.keymap.set("n", "<leader>lh", function()
    vim.lsp.inlay_hint(bufnr, not vim.lsp.inlay_hint.is_enabled(bufnr))
  end, vim.tbl_extend("force", opts, { desc = "Toggle Inlay Hints" }))

  -- Enable formatting on save (if supported by the server)
  if client.supports_method("textDocument/formatting") then
    -- Clear existing autocommands for this buffer
    vim.api.nvim_clear_autocmds({
      group = augroup,
      buffer = bufnr,
    })
    -- Add a new autocommand for formatting on save
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = augroup,
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({
          bufnr = bufnr,
        })
      end,
    })
  end
end

return M
