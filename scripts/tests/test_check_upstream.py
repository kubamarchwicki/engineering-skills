"""Exercise the daily check against disposable Git remotes and submodules."""

from pathlib import Path
import os
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
        self.skill_path = "skills/used"
        (self.upstream / self.skill_path).mkdir(parents=True)
        (self.upstream / self.skill_path / "SKILL.md").write_text("Imported skill.\n")
        (self.upstream / self.skill_path / "references").mkdir()
        (self.upstream / self.skill_path / "references/guide.md").write_text("Reference.\n")
        for name in ("dropped", "original", "used-extra"):
            (self.upstream / "skills" / name).mkdir()
            (self.upstream / "skills" / name / "SKILL.md").write_text("Not imported.\n")
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
        (self.repo / "provenance.tsv").write_text(
            "name\tsubmodule\tsource_path\tstatus\tinv\trole\tchanges\n"
            + "".join(
                f"{source}-used\t{source}\t{self.skill_path}\timported\tM\tFixture\tverbatim\n"
                for source in self.sources
            )
            + "dropped\tfirst\tskills/dropped\tdropped\t-\t-\tNot used\n"
            + "original\tfirst\tskills/original\toriginal\tM\tLocal fork\tLocal\n"
        )
        self.commit(self.repo)
        self.scratch = self.root / "scratch"
        self.scratch.mkdir()

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
                self.git(repo, "config", "--local", "--list"),
            ))
        return state

    def check(self):
        before = self.snapshot()
        result = subprocess.run(
            ["/bin/bash", str(self.repo / "scripts/check-upstream.sh")],
            cwd=self.root, text=True, capture_output=True,
            env={**os.environ, "TMPDIR": str(self.scratch)},
        )
        self.assertEqual(self.snapshot(), before, "The check must not change repository state")
        self.assertEqual(list(self.scratch.iterdir()), [], "Temporary Git data must be cleaned up")
        return result

    def advance_upstream(self, path="skills/used/SKILL.md"):
        (self.upstream / path).write_text("Upstream moved.\n")
        self.commit(self.upstream)
        return self.git(self.upstream, "rev-parse", "HEAD")

    def test_clean_current_pins_pass(self):
        result = self.check()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("all 2 submodules are clean and pinned; imported skills are up to date", result.stdout)

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

    def test_unrelated_upstream_commit_passes(self):
        self.advance_upstream("README.md")
        result = self.check()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_dropped_original_and_unlisted_paths_do_not_trigger_updates(self):
        for name in ("dropped", "original", "used-extra"):
            self.advance_upstream(f"skills/{name}/SKILL.md")
        result = self.check()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_reverted_upstream_changes_pass(self):
        target = self.advance_upstream()
        self.git(self.upstream, "revert", "--no-edit", target)
        result = self.check()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_imported_directory_changes_trigger_updates(self):
        for change in ("reference", "addition", "deletion", "mode", "symlink", "directory deletion"):
            with self.subTest(change=change):
                self.git(self.upstream, "reset", "--hard", self.pin)
                guide = self.upstream / self.skill_path / "references/guide.md"
                if change == "reference":
                    guide.write_text("Updated reference.\n")
                elif change == "addition":
                    guide.with_name("new.md").write_text("New reference.\n")
                elif change == "deletion":
                    guide.unlink()
                elif change == "mode":
                    guide.chmod(0o755)
                elif change == "symlink":
                    guide.unlink()
                    guide.symlink_to("../SKILL.md")
                else:
                    shutil.rmtree(self.upstream / self.skill_path)
                self.commit(self.upstream)
                result = self.check()
                self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
                for source in self.sources:
                    self.assertIn(f"{source}: imported path changed: {self.skill_path}", result.stdout)

    def test_staged_manifest_cannot_hide_imported_changes(self):
        self.advance_upstream()
        manifest = self.repo / "provenance.tsv"
        manifest.write_text(manifest.read_text().replace("\timported\t", "\tdropped\t"))
        self.git(self.repo, "add", "provenance.tsv")
        result = self.check()
        self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
        self.assertIn("first: upstream update needed", result.stdout)

    def test_imported_paths_are_scoped_to_their_submodule(self):
        manifest = self.repo / "provenance.tsv"
        manifest.write_text(manifest.read_text().replace(
            "first-used\tfirst\tskills/used\t", "first-used\tfirst\tskills/used-extra\t"
        ))
        self.commit(self.repo)
        self.advance_upstream("skills/used-extra/SKILL.md")
        result = self.check()
        self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
        self.assertIn("first: upstream update needed", result.stdout)
        self.assertNotIn("second: upstream update needed", result.stdout)
        self.assertIn("second: imported skills unchanged", result.stdout)

    def test_unfetchable_target_fails_instead_of_reporting_up_to_date(self):
        target = self.advance_upstream()
        # HEAD is still advertised, but the remote can no longer transfer its object.
        (self.upstream / ".git/objects" / target[:2] / target[2:]).unlink()
        result = self.check()
        self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
        for source in self.sources:
            self.assertIn(f"{source}: cannot inspect upstream HEAD", result.stdout)

    def test_missing_manifest_fails_instead_of_reporting_up_to_date(self):
        (self.repo / "provenance.tsv").unlink()
        self.commit(self.repo)
        result = self.check()
        self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
        self.assertIn("Cannot read committed provenance.tsv", result.stdout)

    def test_invalid_manifest_fails_instead_of_reporting_up_to_date(self):
        manifest = self.repo / "provenance.tsv"
        manifest.write_text(manifest.read_text() + "incomplete\trow\n")
        self.commit(self.repo)
        result = self.check()
        self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
        self.assertIn("Invalid committed provenance.tsv", result.stdout)

    def test_missing_imported_path_fails_instead_of_reporting_up_to_date(self):
        manifest = self.repo / "provenance.tsv"
        manifest.write_text(manifest.read_text().replace(self.skill_path + "\t", "skills/missing\t"))
        self.commit(self.repo)
        result = self.check()
        self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
        self.assertIn("imported path skills/missing is not a directory at the committed pin", result.stdout)

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
