---
name: verification-before-completion
description: Use when about to claim work is complete, fixed, or passing, before committing or creating PRs - requires inspecting applicable verification evidence and confirming output before making any success claims; evidence before assertions always
---

# Verification Before Completion

## Overview

**Core principle:** Evidence before claims, always.

**Violating the letter of this rule is violating the spirit of this rule.**

## The Iron Law

NO COMPLETION CLAIMS WITHOUT APPLICABLE VERIFICATION EVIDENCE

A previous run can support a claim when its evidence remains applicable.
A new message or reviewer does not by itself invalidate it.

## Evidence Record

For each claim retain:
- Claim and scope.
- Command, result, and exit status.
- Tested state: commit plus relevant uncommitted changes/content identifiers.
- Relevant dependency, configuration, and environment conditions.
- Inspectable output or a stable log reference.
- Limitations and the acceptance criterion supported.

Record relevant conditions, not an indiscriminate environment dump.
A reported success without supporting evidence is a claim to investigate.

## The Gate Function

Before claiming completion:
1. Identify the criterion, claim scope, and required project gates.
2. Inspect existing evidence against relevant current code, dependencies,
   configuration, and environment, including uncommitted changes.
3. Reuse applicable evidence. Run affected checks when inputs changed,
   evidence cannot be recovered, a concrete doubt remains, or a required
   project gate demands a new run.
4. Read output and exit status; verify they support the stated claim.
5. Report evidence and limits. Failed checks and uncovered criteria remain
   unresolved.

Run focused checks during development. Broaden verification for integration
risk, changed scope, failures, or required project gates. A focused check
supports only its covered claim.

## Common Failures

| Claim | Requires | Not Sufficient |
|-------|----------|----------------|
| Tests pass | Test command output: 0 failures | Previous run without applicable tested state and inspectable output, "should pass" |
| Linter clean | Linter output: 0 errors | Focused check outside the claim scope, extrapolation |
| Build succeeds | Build command: exit 0 | Linter passing, logs look good |
| Bug fixed | Test original symptom: passes | Code changed, assumed fixed |
| Regression test works | Red-green cycle verified | Test passes once |
| Agent completed | Current VCS diff and applicable supporting evidence | Agent reports "success" |
| Requirements met | Current criteria/diff and actual supporting evidence | Tests passing |

## Red Flags - STOP

- Using "should", "probably", "seems to"
- Expressing satisfaction before verification ("Great!", "Perfect!", "Done!", etc.)
- About to commit/push/PR without verification
- Trusting agent success reports
- Extrapolating beyond a focused check's covered claim
- Thinking "just this once"
- Tired and wanting work over
- **ANY wording implying success without applicable verification evidence**

## Rationalization Prevention

| Excuse | Reality |
|--------|---------|
| "Should work now" | Inspect applicable evidence or run the checks needed to support the claim |
| "I'm confident" | Confidence ≠ evidence |
| "Just this once" | No exceptions |
| "Linter passed" | Linter ≠ compiler |
| "Agent said success" | Verify independently |
| "I'm tired" | Exhaustion ≠ excuse |
| "Partial check is enough" | A focused check proves only its covered claim |
| "Different words so rule doesn't apply" | Spirit over letter |

## Key Patterns

**Tests:**
```
✅ [Inspect applicable run/output OR run the needed command] [See: 34/34 pass] "All tests pass"
❌ "Should pass now" / "Looks correct"
```

**Regression tests (TDD Red-Green):**
```
✅ Write → Run (pass) → Revert fix → Run (MUST FAIL) → Restore → Run (pass)
❌ "I've written a regression test" (without red-green verification)
```

**Build:**
```
✅ [Inspect applicable run/output OR run the needed command] [See: exit 0] "Build passes"
❌ "Linter passed" (linter doesn't check compilation)
```

**Requirements:**
```
✅ Inspect current criteria/diff → Create checklist → Inspect actual supporting evidence for each → Report gaps or completion
❌ "Tests pass, phase complete"
```

**Agent delegation:**
```
✅ Agent reports success → Inspect current criteria/diff → Independently inspect actual supporting evidence → Report actual state
❌ Trust agent report
```

## When To Apply

**ALWAYS before:**
- ANY variation of success/completion claims
- ANY expression of satisfaction
- ANY positive statement about work state
- Committing, PR creation, task completion
- Moving to next task
- Delegating to agents

**Rule applies to:**
- Exact phrases
- Paraphrases and synonyms
- Implications of success
- ANY communication suggesting completion/correctness
