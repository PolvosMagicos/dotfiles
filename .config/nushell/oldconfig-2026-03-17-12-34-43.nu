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

# -------------------------
# Helpers
# -------------------------
def --env add_path [p: string] {
  let p = ($p | into string)

  # Ensure PATH is a list
  if ($env.PATH | describe) !~ 'list' {
    $env.PATH = ($env.PATH | split row (char esep))
  }

  # Only add if it exists and isn't already present
  if ($p | path exists) and (not ($env.PATH | any {|e| $e == $p })) {
    $env.PATH = ($env.PATH | prepend $p)
  }
}

# Ensure PATH is a list early
$env.PATH = (
  if ($env.PATH | describe) =~ 'list' {
    $env.PATH
  } else {
    $env.PATH | split row (char esep)
  }
)


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
# Zoxide (cd with steroids)
# -------------------------
source ~/.zoxide.nu

# -------------------------
# Yarn global bins
# -------------------------
let yarn_bins = [
  ($env.HOME | path join ".yarn" "bin")
  ($env.HOME | path join ".config" "yarn" "global" "node_modules" ".bin")
]
for p in $yarn_bins { add_path $p }

# -------------------------
# fnm (Fast Node Manager)
# -------------------------
# Load fnm environment (without letting it overwrite PATH)
load-env (fnm env --shell bash
  | lines
  | str replace 'export ' ''
  | str replace -a '"' ''
  | split column "="
  | rename name value
  | where name != "FNM_ARCH" and name != "PATH"
  | reduce -f {} {|it, acc| $acc | upsert $it.name $it.value }
)

# Ensure fnm's active Node is on PATH (when available)
if ($env.FNM_MULTISHELL_PATH? | is-not-empty) {
  add_path ($env.FNM_MULTISHELL_PATH | path join "bin")
}

# Optional: some setups also use this location (added only if it exists)
add_path ($env.HOME | path join ".local" "share" "fnm")

# -------------------------
# Java (SDKMAN)
# -------------------------
$env.JAVA_HOME = ($env.HOME | path join ".sdkman" "candidates" "java" "current")
add_path ($env.JAVA_HOME | path join "bin")

# -------------------------
# Android SDK
# -------------------------
$env.ANDROID_HOME = ($env.HOME | path join "Android" "Sdk")
add_path ($env.ANDROID_HOME | path join "emulator")
add_path ($env.ANDROID_HOME | path join "platform-tools")

# -------------------------
# Flutter
# -------------------------
add_path ($env.HOME | path join "flutter" "bin")

# -------------------------
# Common user/tool bins
# -------------------------
add_path ($env.HOME | path join ".local" "bin")
add_path ($env.HOME | path join "bin")
add_path ($env.HOME | path join ".cargo" "bin")

# Common system locations (only added if they exist)
add_path "/usr/local/bin"
add_path "/usr/local/sbin"
add_path "/usr/lib64/openmpi/bin"
add_path "/home/linuxbrew/.linuxbrew/bin"
add_path "/opt/homebrew/bin"
add_path "/opt/homebrew/sbin"
add_path "/usr/local/bin/fvm"

# Bun
$env.BUN_INSTALL = ($env.HOME | path join ".bun")
add_path ($env.BUN_INSTALL | path join "bin")

# -------------------------
# Chromium (optional)
# -------------------------
$env.CHROME_EXECUTABLE = "/usr/bin/chromium-browser"

# -------------------------
# De-duplicate PATH
# -------------------------
$env.PATH = ($env.PATH | uniq)

# -------------------------
# Editor defaults
# -------------------------
$env.EDITOR = "nvim"
$env.VISUAL = "nvim"

# -------------------------
# Useful aliases
# -------------------------
alias pls = sudo

alias jb = ^bash -lc "jupyter notebook"
alias jl = ^bash -lc "jupyter lab"
