"""Exercise the updater CLI against disposable upstream repositories."""

from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


SCRIPT = Path(__file__).resolve().parents[1] / "update-from-upstream.sh"
SOURCES = ("mattpocock-skills", "superpowers", "openclaw")


class UpstreamUpdateTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="upstream-update-test-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.init_repo(self.root)
        self.pins = {}
        for source in SOURCES:
            upstream = self.root / source
            upstream.mkdir()
            self.init_repo(upstream)
            (upstream / "README.md").write_text("Synthetic upstream.\n")
            if source == "openclaw":
                for name in ("audit-clean", "audit-conflict"):
                    skill = upstream / ".agents/skills" / name
                    skill.mkdir(parents=True)
                    (skill / "SKILL.md").write_text(
                        f"---\nname: {name}\ndescription: Synthetic audit\n---\n"
                        "Base contract.\n"
                    )
                    shutil.copytree(skill, self.root / "skills" / name)
            self.commit(upstream)
            self.pins[source] = self.git(upstream, "rev-parse", "HEAD")

        (self.root / "scripts").mkdir()
        shutil.copy2(SCRIPT, self.root / "scripts/update-from-upstream.sh")
        (self.root / "provenance.tsv").write_text(
            "name\tsubmodule\tsource_path\tstatus\tinv\trole\tchanges\n"
            + "".join(
                f"{name}\topenclaw\t.agents/skills/{name}\timported\tM\tAudit\tverbatim\n"
                for name in ("audit-clean", "audit-conflict")
            )
        )
        conflict = self.root / "skills/audit-conflict/SKILL.md"
        conflict.write_text(conflict.read_text().replace("Base contract.", "Local contract."))
        self.git(self.root, "add", "scripts", "skills", "provenance.tsv")
        for source, pin in self.pins.items():
            self.git(self.root, "update-index", "--add", "--cacheinfo", f"160000,{pin},{source}")
        self.git(self.root, "commit", "-qm", "Synthetic parent baseline")
        self.parent_head = self.git(self.root, "rev-parse", "HEAD")

    def git(self, repo, *args):
        result = subprocess.run(
            ["git", "-C", str(repo), *args], text=True, capture_output=True, check=True
        )
        return result.stdout.strip()

    def init_repo(self, repo):
        self.git(repo, "init", "-q")
        self.git(repo, "config", "user.name", "Fixture")
        self.git(repo, "config", "user.email", "fixture@example.invalid")
        self.git(repo, "config", "commit.gpgsign", "false")

    def commit(self, repo):
        self.git(repo, "add", ".")
        self.git(repo, "commit", "-qm", "Synthetic source")

    def update(self, openclaw_target=None):
        targets = dict(self.pins)
        if openclaw_target:
            targets["openclaw"] = openclaw_target
        args = ["/bin/bash", str(self.root / "scripts/update-from-upstream.sh")]
        for source, target in targets.items():
            args.extend(["--to", f"{source}={target}"])
        return subprocess.run(args, cwd=self.root, text=True, capture_output=True)

    def test_pinned_targets_are_a_clean_noop(self):
        result = self.update()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.count("up to date"), 3)
        self.assertIn("SUMMARY: conflicts=0 attention=0 new-candidates=0", result.stdout)
        self.assertEqual(self.git(self.root, "status", "--porcelain"), "")

    def test_dirty_skill_aborts_without_overwriting_it(self):
        skill = self.root / "skills/audit-clean/SKILL.md"
        skill.write_text("Uncommitted user work.\n")
        result = self.update()
        self.assertEqual(result.returncode, 2)
        self.assertIn("ABORT: skills/ or provenance.tsv", result.stderr)
        self.assertEqual(skill.read_text(), "Uncommitted user work.\n")

    def test_uninitialized_openclaw_aborts_before_merging(self):
        (self.root / "openclaw").rename(self.root / "upstream-storage")
        (self.root / "openclaw").mkdir()
        result = self.update()
        self.assertEqual(result.returncode, 2)
        self.assertIn("submodules are not initialized", result.stderr)
        self.assertIn("mattpocock-skills superpowers openclaw", result.stderr)
        self.assertNotIn("== ", result.stdout)
        self.assertEqual(self.git(self.root, "diff", "--", "skills", "provenance.tsv"), "")

    def test_openclaw_merges_reports_conflicts_and_candidates_without_advancing_pins(self):
        upstream = self.root / "openclaw"
        for name in ("audit-clean", "audit-conflict"):
            skill = upstream / ".agents/skills" / name / "SKILL.md"
            skill.write_text(skill.read_text().replace("Base contract.", "Upstream contract."))
        candidate = upstream / ".agents/skills/new-audit"
        candidate.mkdir()
        (candidate / "SKILL.md").write_text("---\nname: new-audit\ndescription: New candidate\n---\n")
        self.commit(upstream)
        target = self.git(upstream, "rev-parse", "HEAD")
        self.git(upstream, "checkout", "--detach", self.pins["openclaw"])

        result = self.update(target)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("Upstream contract.", (self.root / "skills/audit-clean/SKILL.md").read_text())
        conflict = (self.root / "skills/audit-conflict/SKILL.md").read_text()
        self.assertEqual(conflict.count("<<<<<<<"), 1)
        self.assertIn("Local contract.", conflict)
        self.assertIn("Upstream contract.", conflict)
        self.assertIn("NEW-CANDIDATE: .agents/skills/new-audit", result.stdout)
        self.assertIn("SUMMARY: conflicts=1 attention=0 new-candidates=1", result.stdout)
        self.assertFalse((self.root / "skills/new-audit").exists())
        self.assertEqual(self.git(self.root, "rev-parse", "HEAD"), self.parent_head)
        self.assertEqual(self.git(self.root, "diff", "--cached"), "")
        for source, pin in self.pins.items():
            self.assertEqual(self.git(self.root / source, "rev-parse", "HEAD"), pin)
            self.assertEqual(self.git(self.root, "rev-parse", f"HEAD:{source}"), pin)


if __name__ == "__main__":
    unittest.main()
