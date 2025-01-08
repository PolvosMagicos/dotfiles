return {
  "pmizio/typescript-tools.nvim",
  dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
  opts = {},
  config = function()
		local on_attach = require("polvos-magicos.core.utils").on_attach
    require("typescript-tools").setup({
      on_attach = on_attach,
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
        },
      },
    })
  end,
}
