import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


@unittest.skipUnless(shutil.which("stow"), "requires GNU Stow")
class StowTests(unittest.TestCase):
    def test_links_configs_without_deploying_state_or_linux_files(self):
        repo = Path(__file__).resolve().parents[1]
        with tempfile.TemporaryDirectory(prefix="macos stow ") as target:
            home = Path(target)
            command = ["stow", "--no-folding", "--dir", str(repo.parent),
                       "--target", target, repo.name]
            result = subprocess.run(command, capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            for name in ["nvim/init.lua", "kitty/kitty.conf", "nushell/config.nu", "mpv/mpv.conf", "mpd/mpd.conf"]:
                link = home / ".config" / name
                self.assertTrue(link.is_symlink(), name)
                self.assertEqual(link.resolve(), (repo / ".config" / name).resolve())
            for name in [".git", ".gitmodules", ".agents", ".aws", ".codex", "Brewfile", "scripts", "tests",
                         "assets", "vial-layouts", "nvim.log", ".config/mpd/database",
                         ".config/quickshell", ".config/systemd", ".config/kitty/kitty.conf.save",
                         ".config/nushell/oldconfig-2025-05-02-15-12-25.nu"]:
                self.assertFalse(os.path.lexists(home / name), name)
            result = subprocess.run(command[:1] + ["--delete"] + command[1:], capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertFalse(os.path.lexists(home / ".config/nvim/init.lua"))
