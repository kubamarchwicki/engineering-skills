# Review response examples

## Unclear feedback and dependencies

```text
your human partner: "Fix items 1-6."
After investigation, items 4 and 5 remain unclear. Items 1-3 depend on them;
item 6 is an independent typo.
Response: "Items 1-3 depend on unclear items 4 and 5 and wait. The independent
typo in item 6 can proceed. I recommend [interpretation of item 4] because
[evidence]. Is that the intended behavior?"
```

Resolve one question at a time, then update affected plan tasks/tests and
durable decisions before resuming dependants.

## Compatibility objection

```text
Reviewer: "Remove legacy code."
Response: "The build target is 10.15+, but this API requires 13+. The fallback
is needed for supported versions. Its bundle ID is wrong; I'll fix that while
retaining the accepted support policy."
```

If the reviewer proposes dropping support, investigate the consequences and
present a recommendation before asking your human partner to decide.

## YAGNI objection

```text
Reviewer: "Add metrics tracking with a database, date filters, and CSV export."
Response: "No callers were found for this endpoint. I recommend removing it
rather than adding tracking. Is there usage outside this codebase?"
```

## Correct feedback

```text
Response: "Fixed the bundle ID in [location]. [Check] passed on [tested state]."
```

## Corrected pushback

```text
Response: "I checked [X]; it does [Y]. My earlier assumption was wrong because
[reason]. Applying the verified correction."
```

## GitHub inline reply reference

When authorized to reply to an inline review comment, reply in its comment
thread using `gh api repos/{owner}/{repo}/pulls/{pr}/comments/{id}/replies`.
A top-level PR comment does not reply to that inline thread.
