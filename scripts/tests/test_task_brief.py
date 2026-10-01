import os
from pathlib import Path
import subprocess
import tempfile
import unittest

DEFAULT_SCRIPT = Path(__file__).resolve().parents[2] / "skills/subagent-driven-development/scripts/task-brief"
SCRIPT = Path(os.environ.get("TASK_BRIEF_SCRIPT", str(DEFAULT_SCRIPT))).resolve()


class TaskBriefTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="task-brief-test-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.plan = self.root / "plan.md"
        self.out = self.root / "brief.md"

    def extract(self, text, number=1):
        self.plan.write_text(text)
        return subprocess.run(
            ["/bin/bash", str(SCRIPT), str(self.plan), str(number), str(self.out)],
            text=True, capture_output=True,
        )

    def test_ready_preserves_task_context_without_other_tasks(self):
        result = self.extract(
            "# Plan\n## Outcome and verification\nGLOBAL_ONLY\n"
            "### Task 1: Save and reload\n**Status:** Ready\n"
            "**Decision context:** ADR-4; criterion C1; evidence E1\n"
            "- [ ] Save, restart, reload.\n"
            "### Task 2: Later\n**Status:** Provisional\nOTHER_TASK\n"
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        body = self.out.read_text()
        self.assertIn("ADR-4; criterion C1; evidence E1", body)
        self.assertIn("Save, restart, reload.", body)
        self.assertNotIn("GLOBAL_ONLY", body)
        self.assertNotIn("OTHER_TASK", body)

    def test_provisional_invalidates_old_ready_brief_then_recovers(self):
        ready = "### Task 1: Save\n**Status:** Ready\nCURRENT\n"
        self.assertEqual(self.extract(ready).returncode, 0)
        result = self.extract("### Task 1: Save\n**Status:** Provisional\n")
        self.assertEqual(result.returncode, 4, result.stderr)
        self.assertFalse(self.out.exists())
        self.assertEqual(self.extract(ready).returncode, 0)
        self.assertIn("CURRENT", self.out.read_text())
        self.assertEqual(list(self.root.glob("brief.md.tmp.*")), [])

    def test_invalid_and_duplicate_status_are_rejected(self):
        cases = [
            "**Status:** Maybe",
            "**Status**: Ready",
            "**Status:** ready",
            "**Status:** Ready\n**Status:** Ready",
        ]
        for status in cases:
            with self.subTest(status=status):
                self.out.write_text("STALE")
                result = self.extract("### Task 1: Save\n" + status + "\n")
                self.assertEqual(result.returncode, 4, result.stderr)
                self.assertFalse(self.out.exists())

    def test_fenced_status_and_headings_are_literal(self):
        tick = chr(96)
        text = (
            "### Task 1: Edit a template\n**Status:** Ready\n"
            + tick * 4 + "markdown\n"
            "**Status:** Provisional\n"
            + tick * 3 + "python\n"
            "### Task 99: Quoted heading\n"
            + tick * 3 + "\n" + tick * 4 + "\n"
            "~~~text\n**Status:** invalid\n### Task 99: Also quoted\n~~~\n"
            "END_OF_TASK\n### Task 2: Other\nOTHER_TASK\n"
        )
        result = self.extract(text)
        self.assertEqual(result.returncode, 0, result.stderr)
        body = self.out.read_text()
        self.assertIn("END_OF_TASK", body)
        self.assertIn("Quoted heading", body)
        self.assertNotIn("OTHER_TASK", body)

    def test_legacy_without_status_is_extractable(self):
        result = self.extract("### Task 1: Legacy\n- [ ] Existing step.\n")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("Existing step.", self.out.read_text())

    def test_missing_task_invalidates_previous_output(self):
        self.out.write_text("STALE")
        result = self.extract("### Task 1: Existing\n", number=2)
        self.assertEqual(result.returncode, 3, result.stderr)
        self.assertFalse(self.out.exists())

    def test_output_cannot_replace_plan(self):
        content = "### Task 1: Existing\n**Status:** Ready\n"
        self.plan.write_text(content)
        result = subprocess.run(
            ["/bin/bash", str(SCRIPT), str(self.plan), "1", str(self.plan)],
            text=True, capture_output=True,
        )
        self.assertEqual(result.returncode, 2, result.stderr)
        self.assertEqual(self.plan.read_text(), content)


if __name__ == "__main__":
    unittest.main()
