return {
  name = "basedpyright",
  config = {
    cmd = { "pyright-langserver", "--stdio" },
    filetypes = { "python" },
    root_dir = function()
      return vim.fs.dirname(vim.fs.find({ "pyproject.toml", "setup.py", ".git" }, { upward = true })[1])
    end,
    single_file_support = true,
    settings = {
      python = {
        analysis = {
          autoSearchPaths = true,
          useLibraryCodeForTypes = true,
          typeCheckingMode = "strict", -- or "off"
          diagnosticMode = "workspace",
        },
      },
    },
  },
}
