# DataDrivenControl

## Research context

This repository supports dissertation research in fully data-driven control.
Do not treat MHE or any other candidate approach as a preferred direction
unless the current task explicitly establishes that preference.

## Working agreement

- Before editing, propose the approach, affected files, and validation.
  Wait for approval unless the current request already approves that scope.
- Preserve existing work. Do not perform unrelated refactoring.
- Do not add, remove, or upgrade dependencies without approval.
- Do not commit, push, merge, or change repository visibility unless asked.
- Report exactly which checks ran and their outcomes.
- Never claim that unexecuted tests passed.

## Julia workflow

- Use Julia and Pluto notebooks, not Quarto.
- Use the repository's shared Julia project environment.
- Put reusable implementations in src/ and tests in test/.
- Keep notebooks focused on exploration, explanation, and visualization.
- Preserve Pluto cell identifiers and notebook structure.
- Prefer GLMakie for interactive exploration.
- Keep automated tests independent of interactive graphics.
- Julia is the primary language; use Pluto.jl for notebooks and prefer GLMakie
  for interactive plots.
- Favor idiomatic Julia, appropriate numeric types, type stability, efficient
  allocation, and standard naming and mutation conventions. Use generic
  functions and multiple dispatch where appropriate, introducing abstractions
  as concrete needs emerge.

## Learning and continuity

- Let the user attempt important mathematical and coding steps before giving
  complete solutions.
- Explain Git/GitHub operations until the user explicitly asks you to stop.
- When resuming a named task, read its repository record first.

## Scientific standards

- Distinguish states x, control inputs u, and measured outputs y.
- Document dimensions, units, sampling time, and indexing conventions.
- Separate simulator ground truth from information available to a method.
- Do not alter metrics, tolerances, data splits, or failing cases merely
  to obtain a passing result.
- Distinguish established facts, assumptions, and experimental findings.
