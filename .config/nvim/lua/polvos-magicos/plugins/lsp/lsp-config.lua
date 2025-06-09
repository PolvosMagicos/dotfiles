return {
  { "j-hui/fidget.nvim", opts = {} },
  "saghen/blink.cmp",
  {
    name = "builtin-lsp",
    dir = vim.fn.stdpath("config"),
    config = function()
      local capabilities = require("blink.cmp").get_lsp_capabilities()
      local on_attach = require("polvos-magicos.core.utils").on_attach

      local servers = {}
      local server_dir = vim.fn.stdpath("config") .. "/lua/polvos-magicos/plugins/lsp/servers/"

      -- This function find all config files for lsp's and load their config (commented config at /servers/lua-ls.lua)
      for _, file in ipairs(vim.fn.readdir(server_dir)) do
        if file:match("%.lua$") then
          local name = file:gsub("%.lua$", "")
          local server = require("polvos-magicos.plugins.lsp.servers." .. name)
          vim.lsp.config[server.name] = vim.tbl_extend("force", server.config, {
            on_attach = on_attach,
            capabilities = capabilities,
          })
          table.insert(servers, server.name)
        end
      end

      vim.lsp.enable(servers)
    end,
  },
}
