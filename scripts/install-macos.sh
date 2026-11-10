#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname -s)" != Darwin ]]; then
  printf 'This installer requires macOS.\n' >&2
  exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
  export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
fi
if ! command -v brew >/dev/null 2>&1; then
  printf 'Install Homebrew from https://brew.sh, then run this script again.\n' >&2
  exit 1
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
brew bundle install --no-upgrade --file="$script_dir/../Brewfile"
