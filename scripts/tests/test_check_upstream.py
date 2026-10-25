"""Exercise the daily check against disposable Git remotes and submodules."""

from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


SCRIPT = Path(__file__).resolve().parents[1] / "check-upstream.sh"


class UpstreamCheckTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="upstream-check-test-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.upstream = self.root / "upstream"
        self.repo = self.root / "parent"
        for repo in (self.upstream, self.repo):
            repo.mkdir()
            self.git(repo, "init", "-q", "-b", "upstream-default")
            self.git(repo, "config", "user.name", "Fixture")
            self.git(repo, "config", "user.email", "fixture@example.invalid")
            self.git(repo, "config", "commit.gpgsign", "false")
        (self.upstream / "README.md").write_text("Original upstream.\n")
        self.commit(self.upstream)
        self.pin = self.git(self.upstream, "rev-parse", "HEAD")
        # Two real submodules also prove that a failure does not skip later checks.
        self.sources = ("first", "second")
        for source in self.sources:
            self.git(
                self.repo, "-c", "protocol.file.allow=always", "submodule", "add",
                "-q", "--depth", "1", self.upstream.as_uri(), source,
            )
        (self.repo / "scripts").mkdir()
        shutil.copy2(SCRIPT, self.repo / "scripts/check-upstream.sh")
        self.commit(self.repo)

    def git(self, repo, *args):
        result = subprocess.run(
            ["git", "-C", str(repo), *args], check=True, text=True, capture_output=True
        )
        return result.stdout.strip()

    def commit(self, repo):
        self.git(repo, "add", ".")
        self.git(repo, "commit", "-qm", "Synthetic fixture")

    def snapshot(self):
        state = []
        for repo in (self.repo, *(self.repo / source for source in self.sources)):
            if not (repo / ".git").exists():
                continue
            state.append((
                self.git(repo, "rev-parse", "HEAD"),
                self.git(repo, "show-ref"),
                self.git(repo, "status", "--porcelain", "--untracked-files=all"),
                self.git(repo, "diff", "HEAD", "--binary"),
                self.git(repo, "diff", "--cached", "--binary"),
            ))
        return state

    def check(self):
        before = self.snapshot()
        result = subprocess.run(
            ["/bin/bash", str(self.repo / "scripts/check-upstream.sh")],
            cwd=self.root, text=True, capture_output=True,
        )
        self.assertEqual(self.snapshot(), before, "The check must not change repository state")
        return result

    def advance_upstream(self):
        (self.upstream / "README.md").write_text("Upstream moved.\n")
        self.commit(self.upstream)
        return self.git(self.upstream, "rev-parse", "HEAD")

    def test_clean_current_pins_pass(self):
        result = self.check()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("all 2 submodules are clean, pinned, and up to date", result.stdout)

    def test_live_upstream_movement_fails_even_with_stale_local_remote_refs(self):
        target = self.advance_upstream()
        result = self.check()
        self.assertEqual(result.returncode, 1, result.stderr)
        for source in self.sources:
            self.assertIn(f"{source}: upstream update needed ({self.pin} -> {target})", result.stdout)
            self.assertEqual(
                self.git(self.repo / source, "rev-parse", "origin/upstream-default"), self.pin
            )
        self.assertIn("$update-from-upstream", result.stdout)

    def test_checkout_mismatch_uses_committed_pin_even_when_new_pin_is_staged(self):
        target = self.advance_upstream()
        source = self.repo / "first"
        self.git(source, "fetch", "-q", "origin")
        self.git(source, "checkout", "-q", "--detach", target)
        self.git(self.repo, "add", "first")
        result = self.check()
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertIn(f"checkout {target} does not match committed pin {self.pin}", result.stdout)

    def test_dirty_submodule_fails_for_unstaged_staged_and_untracked_changes(self):
        source = self.repo / "first"
        for kind in ("unstaged", "staged", "untracked"):
            with self.subTest(kind=kind):
                path = source / ("new-file" if kind == "untracked" else "README.md")
                path.write_text("Local work.\n")
                if kind == "staged":
                    self.git(source, "add", "README.md")
                result = self.check()
                self.assertEqual(result.returncode, 1, result.stderr)
                self.assertIn("first: submodule has uncommitted changes or untracked files", result.stdout)
                self.assertEqual(path.read_text(), "Local work.\n")
                if kind == "untracked":
                    path.unlink()
                else:
                    self.git(source, "restore", "--staged", "--worktree", "README.md")

    def test_uninitialized_submodule_fails_and_later_submodules_are_checked(self):
        self.git(self.repo, "submodule", "deinit", "-f", "first")
        result = self.check()
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertIn("first: submodule is not initialized", result.stdout)
        self.assertIn("second: pin=", result.stdout)

    def test_unreachable_remote_fails_instead_of_reporting_up_to_date(self):
        self.git(self.repo / "first", "remote", "set-url", "origin", str(self.root / "missing"))
        result = self.check()
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertIn("first: cannot read upstream HEAD", result.stdout)
        self.assertIn("second: pin=", result.stdout)

    def test_remote_without_head_fails_instead_of_reporting_up_to_date(self):
        empty = self.root / "empty.git"
        self.git(self.root, "init", "-q", "--bare", str(empty))
        self.git(self.repo / "first", "remote", "set-url", "origin", str(empty))
        result = self.check()
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertIn("first: cannot read upstream HEAD", result.stdout)


if __name__ == "__main__":
    unittest.main()
