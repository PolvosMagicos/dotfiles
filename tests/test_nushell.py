import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


@unittest.skipUnless(shutil.which("nu") and shutil.which("zoxide"), "requires nu and zoxide")
class NushellTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="macos nushell ")
        self.addCleanup(self.temp.cleanup)
        self.home = Path(self.temp.name)
        self.repo = Path(__file__).resolve().parents[1]
        (self.home / ".config").mkdir()
        (self.home / ".config/nushell").symlink_to(self.repo / ".config/nushell")
        self.bin = self.home / "bin"
        self.bin.mkdir()
        for name, source in {
            "brew": '#!/bin/sh\nprintf "%s\\n" "$TEST_BREW_PREFIX"\n',
            "fnm": '#!/bin/sh\nprintf \'export FNM_MULTISHELL_PATH="%s"\\nexport PATH="ignored"\\n\' "$TEST_FNM_PATH"\n',
        }.items():
            path = self.bin / name
            path.write_text(source)
            path.chmod(0o755)
        self.node = self.home / "fnm node/bin"
        self.node.mkdir(parents=True)
        self.env = dict(os.environ, HOME=str(self.home),
                        XDG_CONFIG_HOME=str(self.home / ".config"),
                        XDG_DATA_HOME=str(self.home / ".local/share"),
                        XDG_STATE_HOME=str(self.home / ".local/state"),
                        PATH=str(self.bin) + os.pathsep + os.environ["PATH"],
                        TEST_BREW_PREFIX=str(self.home / "brew"),
                        TEST_FNM_PATH=str(self.node.parent))
        for name in ["JAVA_HOME", "ANDROID_HOME", "ANDROID_SDK_ROOT", "FNM_DIR"]:
            self.env.pop(name, None)

    def startup(self):
        result = subprocess.run([
            shutil.which("nu"), "--env-config", str(self.repo / ".config/nushell/env.nu"),
            "--config", str(self.repo / ".config/nushell/config.nu"),
            "-c", "$env | select EDITOR HOMEBREW_PREFIX ANDROID_HOME ANDROID_SDK_ROOT PATH | to json",
        ], env=self.env, capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        return json.loads(result.stdout)

    def test_first_start_creates_zoxide_and_uses_homebrew_sdk(self):
        values = self.startup()
        self.assertTrue((self.home / ".zoxide.nu").is_file())
        self.assertEqual(values["EDITOR"], "nvim")
        self.assertEqual(values["ANDROID_HOME"], str(self.home / "brew/share/android-commandlinetools"))
        self.assertIn(str(self.node), values["PATH"])
        self.assertEqual(len(values["PATH"]), len(set(values["PATH"])))
        self.startup()

    def test_prefers_existing_android_studio_sdk(self):
        sdk = self.home / "Library/Android/sdk"
        sdk.mkdir(parents=True)
        self.assertEqual(self.startup()["ANDROID_HOME"], str(sdk))

    def test_preserves_custom_sdk_and_managed_node_precedence(self):
        self.env["ANDROID_HOME"] = str(self.home / "custom sdk")
        java_bin = self.home / "custom jdk/bin"
        java_bin.mkdir(parents=True)
        self.env["JAVA_HOME"] = str(java_bin.parent)
        values = self.startup()
        self.assertEqual(values["ANDROID_HOME"], self.env["ANDROID_HOME"])
        self.assertEqual(values["ANDROID_SDK_ROOT"], self.env["ANDROID_HOME"])
        self.assertIn(str(java_bin), values["PATH"])
        self.assertLess(values["PATH"].index(str(self.node)), values["PATH"].index(str(self.bin)))
