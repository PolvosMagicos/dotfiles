return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  branch = "main",
  lazy = false,
  config = function()
    local treesitter = require("nvim-treesitter")
    local parsers = {
      "bash",
      "cpp",
      "css",
      "csv",
      "dockerfile",
      "gitignore",
      "html",
      "ini",
      "java",
      "javascript",
      "json",
      "kdl",
      "lua",
      "make",
      "markdown",
      "markdown_inline",
      "nix",
      "nu",
      "proto",
      "python",
      "qmldir",
      "qmljs",
      "rust",
      "sql",
      "toml",
      "tsx",
      "typescript",
      "vim",
      "vimdoc",
      "xml",
      "yaml",
    }

    treesitter.setup()

    -- The main branch no longer has `ensure_installed`. Install the configured
    -- parsers asynchronously when the required CLI is available.
    if vim.fn.executable("tree-sitter") == 1 then
      treesitter.install(parsers)
    end

    -- Highlighting and indentation are now enabled through Neovim's built-in
    -- Tree-sitter API instead of nvim-treesitter modules.
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("polvos-magicos-treesitter", { clear = true }),
      callback = function(args)
        if pcall(vim.treesitter.start, args.buf) then
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end,
}
