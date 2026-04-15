return {
  name = "qmlls",
  config = {
    cmd = { "qmlls", "-E", "--build-dir", "build" },
    filetypes = { "qml", "qmljs" },
    root_markers = { ".qmlls.ini", ".git", "CMakeLists.txt" },
    single_file_support = true,
  },
}
