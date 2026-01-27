# config.nu
#
# Installed by:
# version = "0.104.0"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# This file is loaded after env.nu and before login.nu
#
# You can open this file in your default editor using:
# config nu
#
# See `help config nu` for more options
# You can remove these comments if you want or leave
# them for future reference.

# config.nu (macOS)
# Nushell config loaded after env.nu and before login.nu

# -------------------------
# Helpers
# -------------------------
def --env add_path [p: string] {
  if ($p | path exists) {
    if not ($env.PATH | any {|e| $e == $p }) {
      $env.PATH = ($env.PATH | prepend $p)
    }
  }
}

# -------------------------
# PATH (macOS / Homebrew-first)
# -------------------------
# Start from current PATH and ensure it's a list
$env.PATH = ($env.PATH | split row (char esep))

# Homebrew (Apple Silicon)
add_path "/opt/homebrew/bin"
add_path "/opt/homebrew/sbin"

# Homebrew (Intel fallback)
add_path "/usr/local/bin"
add_path "/usr/local/sbin"

# Common user bins
add_path ($env.HOME | path join ".local" "bin")
add_path ($env.HOME | path join "bin")

# Cargo (Rust)
add_path ($env.HOME | path join ".cargo" "bin")

# Yarn global bins (your original idea)
let yarn_bins = [
  ($env.HOME | path join ".yarn" "bin")
  ($env.HOME | path join ".config" "yarn" "global" "node_modules" ".bin")
]
for p in $yarn_bins { add_path $p }

# De-duplicate PATH
$env.PATH = ($env.PATH | uniq)

# -------------------------
# fnm (Fast Node Manager)
# -------------------------
# Load fnm environment (without letting it overwrite PATH)
# If you want fnm to manage PATH, remove the `where name != "PATH"` filter.
load-env (fnm env --shell bash
  | lines
  | str replace 'export ' ''
  | str replace -a '"' ''
  | split column "="
  | rename name value
  | where name != "FNM_ARCH" and name != "PATH"
  | reduce -f {} {|it, acc| $acc | upsert $it.name $it.value }
)

# -------------------------
# zoxide (cd replacement)
# -------------------------

zoxide init --cmd cd nushell | save -f ~/.zoxide.nu

source ~/.zoxide.nu

# zoxide (generate init script)

# -------------------------
# Yazi wrapper (cd into last dir)
# -------------------------
def --env y [...args] {
  let tmp = (mktemp -t "yazi-cwd.XXXXXX")
  yazi ...$args --cwd-file $tmp
  let cwd = (open $tmp)
  if $cwd != "" and $cwd != $env.PWD {
    cd $cwd
  }
  rm -fp $tmp
}

# -------------------------
# Editor defaults
# -------------------------
$env.EDITOR = "nvim"
$env.VISUAL = "nvim"

# -------------------------
# Useful aliases
# -------------------------
alias pls = sudo

# Jupyter (using login shell so it picks up pyenv/conda/etc if you use them)
alias jb = ^bash -lc "jupyter notebook"
alias jl = ^bash -lc "jupyter lab"
