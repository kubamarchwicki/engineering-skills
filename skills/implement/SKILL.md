---
name: implement
description: "Implement a piece of work based on a spec or set of tickets."
disable-model-invocation: true
---

Implement the work described by the user in the spec or tickets.

Record the starting Git revision and existing working-tree changes. Preserve
unrelated work. For code-review supply this fixed revision, working-tree mode,
relevant task paths including untracked files, and the agreed outcomes and
decision sources.

Call the Skill tool with "tdd" where possible, at pre-agreed seams.

Before final code-review, read and follow
[the final-review gates](../verification-before-completion/FINAL-REVIEWS.md)
from the recorded starting revision in working-tree mode, including untracked
task files. Complete test-audit and both Thermos reviews, resolve blocking
findings, and supply their reports and dispositions to code-review.

Call the Skill tool with "code-review" on that working-tree change before committing. Resolve
findings and verify that the reviewed state still matches the change committed.

Use focused tests and typechecking appropriate to the change and satisfy
required project gates. Apply verification-before-completion for evidence
validity, reruns, and reporting before committing or claiming completion.

Commit your work to the current branch.
