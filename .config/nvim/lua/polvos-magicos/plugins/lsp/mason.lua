return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup({
        ui = {
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
          },
        },
      })
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      auto_install = true,
    },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",        -- Lua
          "clangd",        -- C/C++
          "jdtls",         -- Java
          "rust_analyzer", -- Rust
          "pylsp",         -- Python
          "tailwindcss",   -- Tailwind CSS
          "html",          -- HTML
          "marksman",      -- Markdown
        },
        automatic_installation = {
          exclude = { "ts_ls" },
        },
        auto_install = true,
      })
    end,
  },
}
