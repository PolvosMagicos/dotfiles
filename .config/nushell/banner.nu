def welcome [] {
  let image_path = "PATH TO IMAGE"

  # Gather info
  let ver = (version)
  let now = (date now | format date "%Y-%m-%d %H:%M")
  let user = (whoami)
  let hostname = (sys host | get hostname)
  let os_name = (sys host | get name)
  let os_ver = (sys host | get os_version)
  let kernel = (sys host | get kernel_version)
  let uptime = (sys host | get uptime)
  let mem_used = (sys mem | get used)
  let mem_total = (sys mem | get total)
  let term = ($env.TERM)
  let after_init = (date now)
  # TODO: when works fine fix the startup time
  let startup = $nu.startup-time

  # Image + Text Layout
  if ($image_path | path exists) {
    run-external kitty '+kitten' 'icat' '--align=left' '--scale-up' '--place=40x14@0x0' $image_path

    echo $"
                                 (ansi green_bold)Welcome, Minion 👾(ansi reset)
                                 ───────────────────────────────
                                 (ansi green)User:      (ansi purple)($user)
                                 (ansi green)Host:      (ansi purple)($hostname)
                                 (ansi green)OS:        (ansi purple)($os_name)
                                 (ansi green)Version:   (ansi purple)($os_ver)
                                 (ansi green)Kernel:    (ansi purple)($kernel)
                                 (ansi green)Uptime:    (ansi purple)($uptime)
                                 (ansi green)Memory:    (ansi purple)($mem_used) / ($mem_total)
                                 (ansi green)Terminal:  (ansi purple)($term)
                                 (ansi green)Shell:     (ansi purple)Nushell ($ver.version)
                                 (ansi green)Time:      (ansi purple)($now)
                                 (ansi green)Startup:   (ansi purple)($startup)(ansi reset)
    "
  } else {
    echo $"
  (ansi green_bold)Welcome, Minion 👾(ansi reset)
  ───────────────────────────────
  (ansi green)User:      (ansi purple)($user)
  (ansi green)Host:      (ansi purple)($hostname)
  (ansi green)OS:        (ansi purple)($os_name)
  (ansi green)Version:   (ansi purple)($os_ver)
  (ansi green)Kernel:    (ansi purple)($kernel)
  (ansi green)Uptime:    (ansi purple)($uptime)
  (ansi green)Memory:    (ansi purple)($mem_used) / ($mem_total)
  (ansi green)Terminal:  (ansi purple)($term)
  (ansi green)Shell:     (ansi purple)Nushell ($ver.version)
  (ansi green)Time:      (ansi purple)($now)
  (ansi green)Startup:   (ansi purple)($startup)(ansi reset)
    "
  }
}
