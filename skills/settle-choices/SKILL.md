---
name: settle-choices
description: Settle open choices before building. Use when work moves from a handoff, spec or feature request straight to implementation, or when an unmade choice (library, pattern, interface, config) surfaces mid-implementation.
---

Implementation starts once every choice it depends on is **settled**: decided by the user or the project, with the source named. A choice nobody made is **open**, and the user owns it.

1. **Sweep.** List every choice the work needs: libraries, patterns, interface shapes, config, test approach. Mark each settled (cite the handoff, ADR, glossary or user message) or open. Done when no choice is unmarked.
2. **Survey.** For each open choice, gather candidates from the project's guides and docs first, then from Stack Overflow via the `stackoverflow-mcp` tools: `so_search` is lexical and returns nothing for long queries, so run many short ones of two to four words: one per candidate ("jackson records", "gson java.time"), one per risk ("System.Logger level"), and one per forced pairing ("wiremock junit"). Send them in parallel. When a query returns empty, shorten it and rerun. When a result is too large to read, extract titles, scores and dates with a script, then call `get_content` on the most relevant hits to read the answers in full. 
Treat Stack Overflow as a source of candidates and known pitfalls, not as a decision: confirm each candidate against primary sources, and note answer age and votes, since old answers go stale. If the MCP is unavailable, fall back to primary sources and say so. Include "keep current" when something already exists. Hold the project's constraints as fixed **forces** and score each candidate against them. Tag each candidate fact with its source: primary doc, Stack Overflow, or own knowledge. Done when each open choice has at least two candidates besides "keep current", every candidate is scored against every force, and the risks worth a **spike** are listed.
For libraries which are unknown, read the docs with "context7" tools: `resolve-library-id` to get library id and query documentation with `query-docs`
3. **Decide.** Present one numbered round. Give each choice its own block:
   - **Alternatives**: every candidate, "keep current" included, with its scores against the forces and the source tag of its facts.
   - **Recommendation**: the force it wins on, and for each rejected candidate the force it loses on.
   - **Risks**: the unverified ones.

   Done when the user can overturn a recommendation by picking another candidate, with no further research needed. Wait for the user's answers.
4. **Record.** Write each decision where the project keeps its decisions (handoff, ADR when hard to reverse). Then build.

**Mid-implementation fork:** pause at the fork, run steps 2–4 for that one choice, then resume.

Done when every choice is settled with a named source.
