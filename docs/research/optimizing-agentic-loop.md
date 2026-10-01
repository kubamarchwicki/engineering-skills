# Optimize the agentic loop for discovering wrong assumptions early.

Our review showed that agents can execute detailed plans, pass tests, and approve one another’s work while the underlying design still needs correction.

A useful loop is:
**Frame → investigate → challenge → prove → implement → review → update**

1. **Frame the outcome before choosing the architecture.**

   Define observable behavior, constraints, exclusions, and acceptance criteria. Separate requirements from proposed implementation choices.

   “Information survives restart” is a requirement. “Introduce a repository interface and cache” is a design proposal requiring justification.

   **Exit condition:** a reviewer can describe success without referring to proposed classes or modules.
2. **Investigate contracts and ownership before decomposing the work.**

   Establish what existing code, dependencies, and external systems already provide. Trace the real execution path, especially who creates, retains, updates, and releases state.

   Distinguish:
   - Facts verified from source, documentation, or experiments.
   - Assumptions requiring validation.
   - Product decisions requiring user judgment.

   **Exit condition:** every important responsibility has an owner, and consequential unknowns are visible.
3. **Challenge the plan independently of checking compliance.**

   Ask whether the design is necessary and sufficient:
   - Does an existing component already own this responsibility?
   - What behavior does each new abstraction add?
   - Are we copying data or maintaining another source of truth?
   - Are defensive checks enforcing an actual requirement?
   - Which assumption, if wrong, would force the largest rewrite?

   **Exit condition:** the design’s important choices have reasons beyond “this is a familiar pattern.”
4. **Prove the riskiest assumption through a small integration experiment.**

   Before broad implementation, exercise the real boundary most likely to invalidate the design. Include a normal execution, a meaningful failure, and the next operation after that failure.

   Observe actual outputs and state ownership. A test against a convenient substitute can pass while the production integration behaves differently.

   **Exit condition:** evidence supports the risky choice, or the plan changes before substantial code depends on it.
5. **Implement in small, observable slices.**

   Prefer slices that demonstrate a complete behavior across boundaries. Keep later details provisional until earlier discoveries settle them.

   Use focused tests during development. Broaden verification when integration risk, changed scope, or failures justify it. Reuse valid evidence instead of rerunning the same checks for every reviewer.

   **Exit condition:** the slice demonstrates its promised behavior, with relevant failure cases covered.
6. **Review both the implementation and the plan.**

   These are different questions:

   | Review | Question |
   | --- | --- |
   | Implementation correctness | Does the code satisfy the current contract? |
   | Design validity | Is the current contract and architecture still appropriate? |
   | Evidence quality | Would these tests detect the failure we care about? |
   | Scope and standards | Does this follow agreed boundaries and conventions? |

   Review changes across their consequences: adding an operation may also affect validation, errors, cleanup, configuration, and documentation.

   **Exit condition:** findings have evidence and disposition; approval identifies what was actually verified.
7. **Classify feedback and update the current understanding.**

   Distinguish implementation defects, mistaken assumptions, changed requirements, new dependency capabilities, and newly expressed preferences. They require different responses.

   When a decision changes, update its dependent plan steps and tests. Retire contradictory instructions. Record the rationale where future agents will find it.

   **Exit condition:** the next agent can identify the current contract without reconstructing the conversation.

**Keep the supporting documentation small.** One living brief can hold the outcome, current decisions, consequential assumptions, next steps, and evidence links. Put detailed historical reasoning behind references. Commit or otherwise version the agreed plan before implementation so later reviews can reconstruct which requirements applied.

**Use delegation where it creates independent evidence.** Good candidates include a bounded implementation slice, an alternative design assessment, or review of a distinct risk. Give each agent an exact scope, relevant sources, and completion criteria. Multiple agents checking the same detailed brief can share the same blind spot.

**Spend human attention on decisions that change behavior, ownership, or scope.** Agents should resolve routine navigation and reversible implementation choices themselves. Escalations should present a concrete tradeoff, supporting evidence, and a recommendation.

Warning signs that the loop needs correction include:

- Repeated passing reviews followed by fundamental user corrections.
- Tests asserting helper behavior while leaving the real integration unobserved.
- Growing plans with unresolved architectural assumptions.
- New wrappers, registries, or guards justified mainly by convention.
- Repeated full-suite runs producing little new information.
- Several documents claiming to describe the current design.

You can reuse this instruction between projects:

> Before producing a detailed implementation plan, establish the intended behavior, existing capabilities, ownership boundaries, and consequential assumptions. Separate verified facts from design proposals.
>
> Challenge whether each proposed component is necessary. Identify the assumption most likely to invalidate the design and define the smallest realistic experiment that tests it.
>
> Plan implementation in observable slices. Validate actual integration behavior and meaningful failure recovery. Scale testing and delegation to the uncertainty they resolve.
>
> Review both whether the implementation follows the plan and whether the plan remains sound. Classify feedback before acting on it, maintain one clear current contract, and report outcomes with evidence and explicit limits.
