---
name: dispatching-parallel-agents
description: Use when facing 2+ independent tasks that can be worked on without shared state or sequential dependencies
---

# Dispatching Parallel Agents

Delegate one agent per independent problem domain, with isolated context. Construct exactly the context each agent needs; agents should never inherit your session's context or history. Keep coordination in the controller.

## Eligibility

Use parallel agents when all of these hold:

- There are at least two tasks with separate outcomes: investigations, reviews, or fixes.
- Each task can be understood and completed without another task's result. Investigate related failures together until their dependencies are understood.
- Agents have separate write ownership and can work without interfering through shared state. Check files, fixtures, databases, generated artifacts, and the Git index, as well as other shared resources.

If a task needs full system context, narrow it first. Run dependent tasks sequentially. Shared read-only context is safe; shared mutations need a single owner.

## Procedure

### 1. Partition

Group work by independent domain and assign ownership of files and resources. Keep shared integration changes with the controller or a designated owner. For example, tool approval, batch completion, and abort failures may be separate domains once their dependencies are checked.

**Complete when:** every task has a distinct outcome, its dependencies are settled, and mutation ownership does not overlap.

### 2. Brief

Give each agent a self-contained task:

- **Scope:** the exact subsystem, files, or review question it owns.
- **Outcome and acceptance:** what result is needed and what evidence will establish it.
- **Context:** relevant requirements, failure messages, test names, source locations, and established decisions.
- **Constraints:** allowed changes, shared resources, user decisions, and work outside its scope.
- **Output:** findings, changes, verification evidence, unresolved questions, and risks for integration.

Keep the accepted behavior explicit. A changed test expectation requires support from that agreement; a newly proposed behavior or scope change returns to the controller and your human partner before dependent work proceeds.

When constructing a debugging brief or comparing a completed investigation with a worked example, read [EXAMPLES.md](EXAMPLES.md).

**Complete when:** an agent can determine its task, boundaries, and acceptance without the controller's conversation history.

### 3. Dispatch

Start eligible tasks before waiting for completion. Use the available concurrency slots; as one finishes, dispatch the next eligible task. Send each agent only its brief and required context.

**Complete when:** eligible tasks are running or queued behind the concurrency limit, with dependent work held until its prerequisites are settled.

### 4. Collect and verify

Read every returned report and inspect the actual changes or findings. Check ownership conflicts, shared assumptions, and interactions between results. Resolve conflicting findings before integrating; route unclear review feedback through **receiving-code-review**.

Use **verification-before-completion** to choose and run checks covering the combined changes, relevant integration risks, and required project gates. Spot-check the evidence behind agent claims; run a full suite when the project gate or integration risk requires it.

**Complete when:** every task's acceptance is supported by inspected evidence, combined results are compatible, required checks have passed, and unresolved work is reported accurately. Report the result and stop at the current stage boundary; your human partner owns the next stage and merging.
