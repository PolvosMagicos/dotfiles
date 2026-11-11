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

# Homebrew's android-commandlinetools cask only provides sdkmanager/avdmanager.
# Accept the SDK licenses, install the project-neutral SDK packages and create
# an emulator. Build tools and the NDK are left to Gradle, which downloads the
# versions each project needs. Set SKIP_ANDROID_SDK=1 to skip this step.
android_packages=(
  "platform-tools"
  "emulator"
  "platforms;android-36"
  "system-images;android-36;google_apis;arm64-v8a"
)
android_avd="Pixel_API_36"
android_avd_device="pixel_7"
android_avd_image="system-images;android-36;google_apis;arm64-v8a"

# Same lookup as .config/nushell/config.nu: keep ANDROID_HOME if set, otherwise
# use ~/Library/Android/sdk when present, otherwise Homebrew's SDK directory.
resolve_android_home() {
  if [[ -n "${ANDROID_HOME:-}" ]]; then
    return 0
  fi
  ANDROID_HOME="$HOME/Library/Android/sdk"
  if [[ ! -e "$ANDROID_HOME" ]]; then
    local prefix="${HOMEBREW_PREFIX:-}"
    if [[ -z "$prefix" ]]; then
      prefix="$(brew --prefix)" || return 1
    fi
    if [[ -n "$prefix" ]]; then
      ANDROID_HOME="$prefix/share/android-commandlinetools"
    fi
  fi
}

# Runs with errexit suspended (it is called from an `if`), so every step checks
# its own status and returns non-zero on failure.
setup_android_sdk() {
  resolve_android_home || return 1
  export ANDROID_HOME ANDROID_SDK_ROOT="$ANDROID_HOME"

  local tools="$ANDROID_HOME/cmdline-tools/latest/bin"
  local sdkmanager="$tools/sdkmanager" avdmanager="$tools/avdmanager"
  local emulator="$ANDROID_HOME/emulator/emulator"
  if [[ ! -x "$sdkmanager" || ! -x "$avdmanager" ]]; then
    printf 'sdkmanager/avdmanager not found in %s\n' "$tools" >&2
    return 1
  fi
  printf 'Setting up the Android SDK in %s\n' "$ANDROID_HOME"

  if [[ -s "$ANDROID_HOME/licenses/android-sdk-license" ]]; then
    printf 'Android SDK licenses already accepted\n'
  else
    printf 'Review and accept the Android SDK licenses:\n'
    "$sdkmanager" --sdk_root="$ANDROID_HOME" --licenses || return 1
  fi

  # An installed package has <sdk>/<path with ; as />/package.xml.
  local package missing=()
  for package in "${android_packages[@]}"; do
    if [[ ! -f "$ANDROID_HOME/${package//;//}/package.xml" ]]; then
      missing+=("$package")
    fi
  done
  if [[ ${#missing[@]} -eq 0 ]]; then
    printf 'Android SDK packages already installed\n'
  else
    printf 'Installing Android SDK packages: %s\n' "${missing[*]}"
    "$sdkmanager" --sdk_root="$ANDROID_HOME" --install "${missing[@]}" || return 1
  fi

  local avds name
  avds="$("$emulator" -list-avds)" || return 1
  while IFS= read -r name; do
    if [[ "$name" == "$android_avd" ]]; then
      printf 'Android emulator %s already exists\n' "$android_avd"
      return 0
    fi
  done <<< "$avds"
  printf 'Creating Android emulator %s\n' "$android_avd"
  # "no" answers "Do you wish to create a custom hardware profile?".
  "$avdmanager" create avd --force --name "$android_avd" \
    --device "$android_avd_device" --package "$android_avd_image" <<< no || return 1
}

if [[ "${SKIP_ANDROID_SDK:-}" == 1 ]]; then
  printf 'Skipping Android SDK setup (SKIP_ANDROID_SDK=1)\n'
elif ! setup_android_sdk; then
  printf 'Warning: Android SDK setup failed; continuing. Run this script again to retry.\n' >&2
fi
