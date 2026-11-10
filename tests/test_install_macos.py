import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


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
        self.executable("brew", '#!/bin/sh\nprintf "%s\\n" "$@" > "$BREW_LOG"\nexit "${BREW_EXIT:-0}"\n')
        self.env = dict(os.environ, PATH=str(self.bin), TEST_OS="Darwin",
                        BREW_LOG=str(self.root / "brew.log"))

    def executable(self, name, source):
        path = self.bin / name
        path.write_text(source)
        path.chmod(0o755)

    def run_installer(self):
        return subprocess.run([shutil.which("bash"), str(self.script)], env=self.env,
                              cwd="/tmp", capture_output=True, text=True)

    def test_installs_from_any_directory_with_spaces_in_checkout_path(self):
        result = self.run_installer()
        self.assertEqual(result.returncode, 0, result.stderr)
        args = (self.root / "brew.log").read_text().splitlines()
        self.assertEqual(args[:3], ["bundle", "install", "--no-upgrade"])
        self.assertEqual(Path(args[3].removeprefix("--file=")).resolve(), self.root / "Brewfile")

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


if __name__ == "__main__":
    unittest.main()
