# Final-review gates

Required within both execution tracks before final `code-review`. These are
verification steps within the current execution stage; the caller keeps its
existing commit/stop boundary. Standalone reviews do not start this workflow.

1. **Fix the scope.** Use the caller's recorded starting revision or Execution
   base, agreed outcomes, decision sources, and relevant task paths. Include
   committed changes and, in working-tree mode, staged, unstaged, and untracked
   task files. Record the reviewed revision and content identifiers for relevant
   dirty files. All reviewers must inspect the same change and current state.
2. **Audit test proof.** Invoke `test-audit` (or read and follow its SKILL.md if
   no Skill tool is available). Record scope, audited state, protected contracts,
   retained proof, findings, dispositions, and limits. A no-applicable-tests
   result names the inspected scope. Resolve blocking findings and refresh
   affected proof before the next passes.
3. **Run both Thermos passes.** Invoke `thermo-nuclear-review` and
   `thermo-nuclear-code-quality-review` (or read and follow each SKILL.md).
   Dispatch separate subagents with fresh context windows, in parallel when
   capacity allows. Give each the same fixed base, current change artifact,
   relevant untracked file contents, agreement, repository standards, and
   acceptance evidence. The supplied artifact defines scope even if a skill
   refers to a branch or PR. Reviewers inspect code and report findings and
   concrete proposals; they do not edit, commit, publish, or merge. Preserve
   each pass's findings, evidence, reviewed state, and limits separately.
4. **Dispose and repair.** Apply `receiving-code-review` to classify and verify
   findings. Use the caller's repair procedure. A proposed change to agreed
   behavior, ownership, or scope requires the user's decision. Record reasons
   and evidence for rejected or deferred findings. Unresolved blocking findings
   leave verification incomplete. After repairs, refresh affected test-audit
   evidence and rerun the affected Thermos pass on the fix and its consequences;
   retain reports for unaffected scope. The caller's repair cap never waives a
   gate or authorizes extra repair waves.
5. **Hand evidence to final review.** Supply the test audit and both Thermos
   reports with dispositions to the existing `code-review` invocation. Preserve
   its separate Standards and Spec conclusions. After any final-review repair,
   refresh affected audit and Thermos evidence before scoped re-review. Before
   completion, verify that all reports still cover the current change. Reuse
   applicable evidence rather than recursively launching the workflow.

The Light caller retains these records in its implementation handoff. The Heavy
caller records them in the durable plan's execution record. Include commands,
exit status, inspectable output or stable references, conditions, and limits for
verification claims. Neither a passing test run nor one reviewer substitutes
for either Thermos pass or final code-review.
