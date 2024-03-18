return {
  "pmizio/typescript-tools.nvim",
  dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
  opts = {},
  config = function()
    require("typescript-tools").setup {
      on_attach = function(client, bufnr)
        if vim.fn.has("nvim-0.10") then
          -- Enable inlay hints
          vim.lsp.inlay_hint.enable(bufnr, true)
        end
      end,
      settings = {
        separate_diagnostic_server = true,
        code_lens = "off",
        tsserver_file_preferences = {
          includeInlayParameterNameHints = "all",
          includeCompletionsForModuleExports = true,
          quotePreference = "auto",
        },
        jsx_close_tag = {
          enable = true,
          filetypes = { "javascriptreact", "typescriptreact" },
        }
      },
    }
  end,
}
