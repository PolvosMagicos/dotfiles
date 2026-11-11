#!/usr/bin/env bash
# Link this repo's configs into $HOME with GNU Stow, then point Nushell's native
# macOS config directory at ~/.config/nushell.
#
# Stow is installed with Homebrew when missing. Files in $HOME that would block
# Stow are moved to ~/.dotfiles-backup/<timestamp>/ (keeping their paths) before
# linking. Safe to run again: a second run changes nothing.
set -euo pipefail

if [[ "$(uname -s)" != Darwin ]]; then
  printf 'This script requires macOS.\n' >&2
  exit 1
fi

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
if ! command -v stow >/dev/null 2>&1; then
  if ! command -v brew >/dev/null 2>&1; then
    printf 'Install Homebrew from https://brew.sh, then run this script again.\n' >&2
    exit 1
  fi
  printf 'Installing GNU Stow...\n'
  brew install stow
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_dir="$(cd -- "$script_dir/.." && pwd)"
stow_args=(--no-folding --dir "$(dirname -- "$repo_dir")" --target "$HOME" "$(basename -- "$repo_dir")")

backup_root="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

# Move $HOME/<relative path> into the backup directory, keeping its path.
backup() {
  local rel="$1" dest="$backup_root/$1"
  mkdir -p -- "$(dirname -- "$dest")"
  mv -- "$HOME/$rel" "$dest"
  printf 'Backed up ~/%s\n' "$rel"
}

# Conflict messages from GNU Stow 2.3 and 2.4; the path is relative to $HOME.
re_over=' over existing target (.+) since '
re_over_dir=' over existing directory target (.+)$'
re_not_owned='existing target is not owned by stow: (.+)$'
re_not_link='existing target is neither a link nor a directory: (.+)$'
re_other_pkg='existing target is stowed to a different package: (.+) => '

# Each pass backs up the conflicts Stow reports; moving a file can reveal more.
for pass in 1 2 3 4 5; do
  if output="$(stow --simulate "${stow_args[@]}" 2>&1)"; then
    break
  fi
  conflicts=()
  while IFS= read -r line; do
    [[ "$line" == *'* '* ]] || continue
    if [[ "$line" =~ $re_over ]] || [[ "$line" =~ $re_over_dir ]] ||
       [[ "$line" =~ $re_not_owned ]] || [[ "$line" =~ $re_not_link ]] ||
       [[ "$line" =~ $re_other_pkg ]]; then
      rel="${BASH_REMATCH[1]}"
      if [[ -z "$rel" || "$rel" == /* || "$rel" == ../* || "$rel" == */../* ]]; then
        printf 'Refusing to move unexpected path: %s\n' "$rel" >&2
        exit 1
      fi
      conflicts+=("$rel")
    else
      printf '%s\nStow reported a problem this script cannot fix.\n' "$output" >&2
      exit 1
    fi
  done <<< "$output"
  if [[ ${#conflicts[@]} -eq 0 ]]; then
    printf '%s\nStow failed.\n' "$output" >&2
    exit 1
  fi
  for rel in "${conflicts[@]}"; do
    if [[ -e "$HOME/$rel" || -L "$HOME/$rel" ]]; then
      backup "$rel"
    fi
  done
  if [[ $pass -eq 5 ]]; then
    printf 'Stow still reports conflicts:\n%s\n' "$output" >&2
    exit 1
  fi
done

stow "${stow_args[@]}"
printf 'Linked configs into %s\n' "$HOME"

config_dir="$HOME/.config/nushell"
native_rel="Library/Application Support/nushell"
native_dir="$HOME/$native_rel"

if [[ ! -d "$config_dir" ]]; then
  printf '%s is missing after Stow.\n' "$config_dir" >&2
  exit 1
fi

if [[ -L "$native_dir" && -d "$native_dir" ]] &&
   [[ "$(cd -- "$native_dir" && pwd -P)" == "$(cd -- "$config_dir" && pwd -P)" ]]; then
  printf 'Nushell already uses %s\n' "$config_dir"
else
  if [[ -e "$native_dir" || -L "$native_dir" ]]; then
    backup "$native_rel"
    # Keep command history; it is not part of the repo.
    old="$backup_root/$native_rel"
    if [[ -d "$old" && ! -L "$old" ]]; then
      for file in history.txt history.sqlite3; do
        if [[ -f "$old/$file" && ! -e "$config_dir/$file" ]]; then
          cp -p -- "$old/$file" "$config_dir/$file"
          printf 'Copied Nushell %s\n' "$file"
        fi
      done
    fi
  fi
  mkdir -p -- "$(dirname -- "$native_dir")"
  ln -s -- "$config_dir" "$native_dir"
  printf 'Linked ~/%s -> ~/.config/nushell\n' "$native_rel"
fi

if [[ -d "$backup_root" ]]; then
  printf 'Previous files are in %s\n' "$backup_root"
fi
