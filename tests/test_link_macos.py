import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

REPO = Path(__file__).resolve().parents[1]
HOMEBREW_STOW = any(Path(p, "stow").exists() for p in ["/opt/homebrew/bin", "/usr/local/bin"])


class LinkScriptBase(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="macos link ")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.bin = self.root / "bin"
        self.bin.mkdir()
        # A small checkout with spaces in its path and the real Stow ignore rules.
        self.repo = self.root / "my dotfiles"
        for rel, text in {".config/nushell/config.nu": "# repo config\n",
                          ".config/nushell/env.nu": "# repo env\n",
                          ".config/kitty/kitty.conf": "# repo kitty\n",
                          "README.md": "not deployed\n"}.items():
            path = self.repo / rel
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(text)
        shutil.copyfile(REPO / ".stow-local-ignore", self.repo / ".stow-local-ignore")
        (self.repo / "scripts").mkdir()
        self.script = self.repo / "scripts/link-macos.sh"
        shutil.copyfile(REPO / "scripts/link-macos.sh", self.script)
        self.home = self.root / "home dir"
        self.home.mkdir()
        self.executable("uname", '#!/bin/sh\nprintf "%s\\n" "$TEST_OS"\n')
        self.env = dict(os.environ, HOME=str(self.home), TEST_OS="Darwin")
        self.config = self.home / ".config/nushell"
        self.native = self.home / "Library/Application Support/nushell"

    def executable(self, name, source):
        path = self.bin / name
        path.write_text(source)
        path.chmod(0o755)

    def run_script(self):
        return subprocess.run([shutil.which("bash"), str(self.script)], env=self.env,
                              cwd="/tmp", capture_output=True, text=True)

    def backups(self):
        root = self.home / ".dotfiles-backup"
        return sorted(root.iterdir()) if root.exists() else []


@unittest.skipUnless(shutil.which("stow"), "requires GNU Stow")
class LinkScriptTests(LinkScriptBase):
    def setUp(self):
        super().setUp()
        stow_dir = str(Path(shutil.which("stow")).parent)
        self.env["PATH"] = os.pathsep.join([str(self.bin), stow_dir, "/usr/bin", "/bin"])

    def assert_repo_link(self, rel):
        path = self.home / rel
        self.assertTrue(path.is_symlink(), rel)
        self.assertEqual(path.resolve(), (self.repo / rel).resolve())

    def assert_nushell_linked(self):
        self.assertTrue(self.native.is_symlink())
        self.assertEqual(self.native.resolve(), self.config.resolve())

    def run_ok(self):
        result = self.run_script()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        return result

    def test_fresh_home_links_everything_without_backups(self):
        self.run_ok()
        for rel in [".config/nushell/config.nu", ".config/nushell/env.nu", ".config/kitty/kitty.conf"]:
            self.assert_repo_link(rel)
        self.assertFalse(self.config.is_symlink(), "--no-folding keeps a real directory")
        for rel in ["README.md", "scripts", ".stow-local-ignore"]:
            self.assertFalse(os.path.lexists(self.home / rel), rel)
        self.assert_nushell_linked()
        self.assertEqual(self.backups(), [])

    def test_backs_up_conflicting_file_and_keeps_its_path(self):
        kitty = self.home / ".config/kitty/kitty.conf"
        kitty.parent.mkdir(parents=True)
        kitty.write_text("# mine\n")
        self.run_ok()
        self.assert_repo_link(".config/kitty/kitty.conf")
        [backup] = self.backups()
        self.assertEqual((backup / ".config/kitty/kitty.conf").read_text(), "# mine\n")

    def test_backs_up_foreign_symlink_and_directory_conflicts(self):
        other = self.root / "elsewhere.nu"
        other.write_text("")
        self.config.mkdir(parents=True)
        (self.config / "env.nu").symlink_to(other)
        (self.config / "config.nu").mkdir()
        (self.config / "config.nu/inner").write_text("x")
        self.run_ok()
        self.assert_repo_link(".config/nushell/env.nu")
        self.assert_repo_link(".config/nushell/config.nu")
        [backup] = self.backups()
        self.assertEqual((backup / ".config/nushell/env.nu").resolve(), other.resolve())
        self.assertEqual((backup / ".config/nushell/config.nu/inner").read_text(), "x")

    def test_backs_up_native_nushell_dir_and_keeps_history(self):
        self.native.mkdir(parents=True)
        (self.native / "config.nu").write_text("# default\n")
        (self.native / "history.txt").write_text("ls\n")
        self.run_ok()
        self.assert_nushell_linked()
        [backup] = self.backups()
        self.assertEqual((backup / "Library/Application Support/nushell/config.nu").read_text(), "# default\n")
        self.assertEqual((self.config / "history.txt").read_text(), "ls\n")

    def test_does_not_overwrite_existing_history(self):
        self.config.mkdir(parents=True)
        (self.config / "history.txt").write_text("new\n")
        self.native.mkdir(parents=True)
        (self.native / "history.txt").write_text("old\n")
        self.run_ok()
        self.assertEqual((self.config / "history.txt").read_text(), "new\n")

    def test_replaces_nushell_link_pointing_elsewhere(self):
        other = self.root / "other"
        other.mkdir()
        self.native.parent.mkdir(parents=True)
        self.native.symlink_to(other)
        self.run_ok()
        self.assert_nushell_linked()
        [backup] = self.backups()
        self.assertEqual((backup / "Library/Application Support/nushell").resolve(), other.resolve())

    def test_second_run_changes_nothing(self):
        kitty = self.home / ".config/kitty/kitty.conf"
        kitty.parent.mkdir(parents=True)
        kitty.write_text("# mine\n")
        self.run_ok()
        result = self.run_ok()
        self.assertIn("already uses", result.stdout)
        self.assertNotIn("Backed up", result.stdout)
        self.assertEqual(len(self.backups()), 1)
        self.assert_nushell_linked()

    def test_rejects_linux_before_changing_anything(self):
        self.env["TEST_OS"] = "Linux"
        result = self.run_script()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("requires macOS", result.stderr)
        self.assertEqual(list(self.home.iterdir()), [])


@unittest.skipIf(HOMEBREW_STOW, "Homebrew's stow is installed and would be found first")
class MissingStowTests(LinkScriptBase):
    def setUp(self):
        super().setUp()
        for tool in ["dirname", "basename", "date", "mkdir"]:
            (self.bin / tool).symlink_to(shutil.which(tool))
        self.env["PATH"] = str(self.bin)

    def test_installs_stow_with_homebrew(self):
        self.executable("brew", '#!/bin/sh\nprintf "%s\\n" "$@" > "$BREW_LOG"\nexit 9\n')
        self.env["BREW_LOG"] = str(self.root / "brew.log")
        result = self.run_script()
        self.assertEqual(result.returncode, 9)
        self.assertEqual((self.root / "brew.log").read_text().split(), ["install", "stow"])

    def test_explains_missing_homebrew(self):
        result = self.run_script()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("https://brew.sh", result.stderr)


if __name__ == "__main__":
    unittest.main()
