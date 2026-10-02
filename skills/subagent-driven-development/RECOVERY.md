# Recovery

Required after compaction, a resumed execution, ledger identity mismatch, or
scratch loss. Use the ledger and git history rather than recollection.

- Check for this plan's ledger at `<workspace>/progress.md`. If its first
  line names your plan file, tasks with a `Task <N>: complete` line are DONE
  — do not re-dispatch them; resume at the first task without one. A task
  whose last line is a fix round is mid-loop: resume the loop at the next
  round. A ledger whose first line names a different plan file — or a stray
  ledger at the old flat path `.superpowers/sdd/progress.md` — is another
  plan's progress: leave it in place and start your own, fresh.
- Create the ledger with its identity as the first line:
  `# SDD ledger — plan: <plan file path>`.
- The ledger is your recovery map: the commits it names exist in git even
  when your context no longer remembers creating them. After compaction,
  trust the ledger and `git log` over your own recollection.
- `git clean -fdx` will destroy the workspace (it's git-ignored scratch); if
  that happens, recover from `git log`.

After scratch loss, recover from committed documents and durable evidence,
using git history and recorded Agreement and Execution baselines. Reconcile
completed tasks and fix rounds with the commits they name before dispatch.
Recover missing acceptance evidence or run the affected checks; missing scratch
never makes an unmet requirement complete. Preserve other plans' workspaces.
