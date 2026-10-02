# Record grilling outcomes in the glossary and ADRs

Grilling records agreed terminology in `GLOSSARY.md` and durable decisions with their rationale in `docs/adr/`. Heavy-track work does not require a separate living spec: the user relies on grilling and finds continuously revised specs too fluid to serve as a dependable source of decisions. Planning and review consult the glossary and applicable ADRs; changes to prior decisions are recorded explicitly so future agents can identify which decision applies.

Each numbered plan contains a short outcome-and-verification section with concrete acceptance criteria derived from grilling and linked to the applicable ADRs, alongside its slices and evidence links. The plan applies those decisions to the work; changing a plan does not silently override an ADR.

A substantive change to an accepted ADR decision is recorded in a new ADR that explicitly supersedes the previous one. In-place edits are reserved for clarifications that preserve the decision's meaning.

Before the first implementation task, execution records a Git revision containing the agreed plan and relevant glossary/ADR changes. It reuses an existing committed revision when possible; otherwise it creates a focused documentation commit containing only the agreed material, preserving a baseline against which later refinements can be reviewed.
