# env.nu
#
# Installed by:
# version = "0.104.0"
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
# Zoxide setup
# -------------------------
let zoxide_file = ("~/.zoxide.nu" | path expand)

if not ($zoxide_file | path exists) {
  zoxide init --cmd cd nushell | save -f $zoxide_file
}

source ~/.config/nushell/banner.nu

$env.config.show_banner = false

# load banner
welcome
