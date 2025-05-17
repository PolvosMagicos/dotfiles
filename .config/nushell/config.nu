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
#
# You can remove these comments if you want or leave
# them for future reference.

# zoxide
source ~/.zoxide.nu

# Yazi wrapper
def --env y [...args] {
	let tmp = (mktemp -t "yazi-cwd.XXXXXX")
	yazi ...$args --cwd-file $tmp
	let cwd = (open $tmp)
	if $cwd != "" and $cwd != $env.PWD {
		cd $cwd
	}
	rm -fp $tmp
}

# Add the following directories to the PATH
$env.PATH = (
  $env.PATH
    | split row (char esep)
    | prepend /usr/local/bin
    # cargo
    | prepend ("/home/" + $env.USER + "/.cargo/bin")
    # linuxbrew
    | prepend /home/linuxbrew/.linuxbrew/bin
    # android studio
    | prepend ("/home/" + $env.USER + "/Android/Sdk/emulator")
    | prepend ("/home/" + $env.USER + "/Android/Sdk/platform-tools")
    # flutter
    | prepend ("/home/" + $env.USER + "/flutter/bin")
    # fnm (fast node manager)
    | prepend ("/home/" + $env.USER + "/.fnm")
    # fvm (flutter version manager)
    | prepend ("/usr/local/bin/fvm")
    | uniq # filter so the paths are unique
)

# Set ANDROID HOME
$env.ANDROID_HOME = ("/home/" + $env.USER + "/Android/Sdk")

# Use nvim as default editor
$env.EDITOR = "nvim"
$env.VISUAL = "nvim"

# link zoxide to cd command
zoxide init --cmd cd nushell | save -f ~/.zoxide.nu

# sudo alias
alias pls = sudo
