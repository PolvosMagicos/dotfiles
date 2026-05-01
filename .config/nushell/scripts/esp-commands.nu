export def --env esp-env [] {
  bash -c "source ~/export-esp.sh && env"
  | lines
  | parse --regex "^(?<key>[^=]+)=(?<value>.*)$"
  | where key not-in [PWD SHLVL _]
  | reduce -f {} {|it, acc| $acc | upsert $it.key $it.value }
  | load-env
}
