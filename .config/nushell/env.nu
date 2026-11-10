# env.nu
#
# Installed by:
# version = "0.111.0"
#
# Previously, environment variables were typically configured in `env.nu`.
# In general, most configuration can and should be performed in `config.nu`
# or one of the autoload directories.
#
# This file is generated for backwards compatibility for now.
# It is loaded before config.nu and login.nu
#
# See https://www.nushell.sh/book/configuration.html
#
# Also see `help config env` for more options.
#
# You can remove these comments if you want or leave
# them for future reference.


# -------------------------
# Homebrew must be available before zoxide and config.nu run.
# -------------------------
$env.PATH = (
  if ($env.PATH | describe) =~ 'list' { $env.PATH } else { $env.PATH | split row (char esep) }
)
let brew_paths = (["/opt/homebrew/bin" "/opt/homebrew/sbin" "/usr/local/bin" "/usr/local/sbin"]
  | where {|p| $p | path exists })
$env.PATH = ($env.PATH | prepend $brew_paths | uniq)
if (which brew | is-not-empty) {
  $env.HOMEBREW_PREFIX = (^brew --prefix | str trim)
}

# Zoxide setup
let zoxide_file = ("~/.zoxide.nu" | path expand)

if not ($zoxide_file | path exists) {
  zoxide init --cmd cd nushell | save -f $zoxide_file
}

source ~/.config/nushell/banner.nu

$env.config.show_banner = false

# load banner
if $nu.is-interactive { welcome }
