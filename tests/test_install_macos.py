import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ANDROID_PACKAGES = ["platform-tools", "emulator", "platforms;android-36",
                    "system-images;android-36;google_apis;arm64-v8a"]

# Fake Android tools. Each call is logged as one tab-separated line. sdkmanager
# records its sdk root from where it lives, like the real cmdline-tools layout.
FAKE_SDKMANAGER = r"""#!/bin/sh
PATH=/usr/bin:/bin
sdk="$(cd "$(dirname "$0")/../../.." && pwd)"
answer=
case " $* " in *" --licenses "*) read -r answer ;; esac
{ printf 'sdkmanager'; printf '\t%s' "$@" "stdin=$answer"; printf '\n'; } >> "$ANDROID_LOG"
[ -n "$SDKMANAGER_EXIT" ] && exit "$SDKMANAGER_EXIT"
for arg; do
  case $arg in
    --licenses) mkdir -p "$sdk/licenses"; printf 'hash\n' > "$sdk/licenses/android-sdk-license" ;;
    --*) ;;
    *) dir="$sdk/$(printf '%s' "$arg" | tr ';' /)"; mkdir -p "$dir"; : > "$dir/package.xml" ;;
  esac
done
"""

FAKE_AVDMANAGER = r"""#!/bin/sh
PATH=/usr/bin:/bin
read -r answer
{ printf 'avdmanager'; printf '\t%s' "$@" "stdin=$answer"; printf '\n'; } >> "$ANDROID_LOG"
prev= name=
for arg; do [ "$prev" = --name ] && name="$arg"; prev="$arg"; done
mkdir -p "$HOME/.android/avd"
: > "$HOME/.android/avd/$name.ini"
"""

FAKE_EMULATOR = r"""#!/bin/sh
PATH=/usr/bin:/bin
[ "$1" = -list-avds ] || exit 2
printf 'INFO    | Storing crashdata in: /tmp\n'
for f in "$HOME"/.android/avd/*.ini; do [ -e "$f" ] && basename "$f" .ini; done
exit 0
"""


class InstallerTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="macos installer ")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.bin = self.root / "bin"
        self.bin.mkdir()
        repo = Path(__file__).resolve().parents[1]
        scripts = self.root / "scripts"
        scripts.mkdir()
        self.script = scripts / "install-macos.sh"
        shutil.copyfile(repo / "scripts/install-macos.sh", self.script)
        shutil.copyfile(repo / "Brewfile", self.root / "Brewfile")
        (self.bin / "dirname").symlink_to(shutil.which("dirname"))
        self.executable("uname", '#!/bin/sh\nprintf "%s\\n" "$TEST_OS"\n')
        self.executable("brew", '#!/bin/sh\n'
                        'if [ "$1" = --prefix ]; then printf "%s\\n" "$BREW_PREFIX"; exit 0; fi\n'
                        'printf "%s\\n" "$@" > "$BREW_LOG"\nexit "${BREW_EXIT:-0}"\n')
        self.home = self.root / "home dir"
        self.home.mkdir()
        self.prefix = self.root / "homebrew prefix"
        self.sdk = self.prefix / "share/android-commandlinetools"
        self.install_android_tools(self.sdk)
        self.android_log = self.root / "android.log"
        self.env = dict(os.environ, PATH=str(self.bin), TEST_OS="Darwin", HOME=str(self.home),
                        BREW_LOG=str(self.root / "brew.log"), BREW_PREFIX=str(self.prefix),
                        ANDROID_LOG=str(self.android_log))
        for name in ["ANDROID_HOME", "ANDROID_SDK_ROOT", "HOMEBREW_PREFIX", "SKIP_ANDROID_SDK"]:
            self.env.pop(name, None)

    def executable(self, name, source, directory=None):
        path = (directory or self.bin) / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(source)
        path.chmod(0o755)

    def install_android_tools(self, sdk):
        tools = sdk / "cmdline-tools/latest/bin"
        self.executable("sdkmanager", FAKE_SDKMANAGER, tools)
        self.executable("avdmanager", FAKE_AVDMANAGER, tools)
        self.executable("emulator", FAKE_EMULATOR, sdk / "emulator")

    def run_installer(self):
        return subprocess.run([shutil.which("bash"), str(self.script)], env=self.env,
                              cwd="/tmp", capture_output=True, text=True,
                              stdin=subprocess.DEVNULL)

    def android_calls(self):
        if not self.android_log.exists():
            return []
        return [line.split("\t") for line in self.android_log.read_text().splitlines()]

    def test_installs_from_any_directory_with_spaces_in_checkout_path(self):
        result = self.run_installer()
        self.assertEqual(result.returncode, 0, result.stderr)
        args = (self.root / "brew.log").read_text().splitlines()
        self.assertEqual(args[:3], ["bundle", "install", "--no-upgrade"])
        self.assertEqual(Path(args[3].removeprefix("--file=")).resolve(), self.root.resolve() / "Brewfile")

    def test_rejects_linux_before_calling_brew(self):
        self.env["TEST_OS"] = "Linux"
        result = self.run_installer()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("requires macOS", result.stderr)
        self.assertFalse((self.root / "brew.log").exists())

    def test_preserves_brew_failure(self):
        self.env["BREW_EXIT"] = "7"
        self.assertEqual(self.run_installer().returncode, 7)

    @unittest.skipIf(any(Path(p).exists() for p in ["/opt/homebrew/bin/brew", "/usr/local/bin/brew"]),
                     "a default Homebrew installation is available")
    def test_explains_missing_homebrew(self):
        (self.bin / "brew").unlink()
        result = self.run_installer()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("https://brew.sh", result.stderr)

    def test_sets_up_android_sdk_from_homebrew(self):
        result = self.run_installer()
        self.assertEqual(result.returncode, 0, result.stderr)
        root = f"--sdk_root={self.sdk}"
        self.assertEqual(self.android_calls(), [
            # Licenses are read from the terminal, not answered by the script.
            ["sdkmanager", root, "--licenses", "stdin="],
            ["sdkmanager", root, "--install", *ANDROID_PACKAGES, "stdin="],
            ["avdmanager", "create", "avd", "--force", "--name", "Pixel_API_36",
             "--device", "pixel_7", "--package",
             "system-images;android-36;google_apis;arm64-v8a", "stdin=no"],
        ])
        self.assertNotIn("Warning", result.stderr)

    def test_second_run_changes_nothing(self):
        self.assertEqual(self.run_installer().returncode, 0)
        self.android_log.unlink()
        result = self.run_installer()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.android_calls(), [])
        self.assertIn("licenses already accepted", result.stdout)
        self.assertIn("packages already installed", result.stdout)
        self.assertIn("Pixel_API_36 already exists", result.stdout)

    def test_installs_only_missing_packages(self):
        (self.sdk / "licenses").mkdir()
        (self.sdk / "licenses/android-sdk-license").write_text("hash\n")
        for package in ANDROID_PACKAGES[:2]:
            (self.sdk / package).mkdir(exist_ok=True)
            (self.sdk / package / "package.xml").touch()
        avd = self.home / ".android/avd"
        avd.mkdir(parents=True)
        (avd / "Pixel_API_36.ini").touch()
        result = self.run_installer()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.android_calls(), [
            ["sdkmanager", f"--sdk_root={self.sdk}", "--install", *ANDROID_PACKAGES[2:], "stdin="],
        ])

    def test_prefers_library_sdk_and_preserves_android_home(self):
        library_sdk = self.home / "Library/Android/sdk"
        self.install_android_tools(library_sdk)
        self.assertEqual(self.run_installer().returncode, 0)
        self.assertEqual(self.android_calls()[0][1], f"--sdk_root={library_sdk}")

        custom = self.root / "custom sdk"
        self.install_android_tools(custom)
        self.env["ANDROID_HOME"] = str(custom)
        self.android_log.unlink()
        self.assertEqual(self.run_installer().returncode, 0)
        self.assertEqual(self.android_calls()[0][1], f"--sdk_root={custom}")

    def test_android_failure_warns_and_continues(self):
        self.env["SDKMANAGER_EXIT"] = "3"
        result = self.run_installer()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("Warning: Android SDK setup failed", result.stderr)
        self.assertEqual(len(self.android_calls()), 1)
        self.assertFalse((self.home / ".android").exists())

    def test_missing_android_tools_warns_and_continues(self):
        shutil.rmtree(self.sdk)
        result = self.run_installer()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("sdkmanager/avdmanager not found", result.stderr)
        self.assertIn("Warning: Android SDK setup failed", result.stderr)

    def test_skip_android_sdk(self):
        self.env["SKIP_ANDROID_SDK"] = "1"
        result = self.run_installer()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("Skipping Android SDK setup", result.stdout)
        self.assertEqual(self.android_calls(), [])
        self.assertTrue((self.root / "brew.log").exists())


if __name__ == "__main__":
    unittest.main()
