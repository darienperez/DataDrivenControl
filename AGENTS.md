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

## Research development checkpoints

- Begin a new investigation in a Pluto notebook: define the question, model,
  dimensions, units, sampling time, indexing, inputs, and initial conditions.
- Small notebook-local prototypes are appropriate during exploration. Let the
  user attempt the mathematics and implementation before providing solutions.
- Validate against independent hand calculations or trusted references and
  relevant invariants. Preserve meaningful failures and distinguish numerical
  verification from conclusions about the research question.
- Once an implementation is useful beyond exploration, propose extracting it
  into src/ and its regression checks into test/. After extraction, rerun the
  relevant checks and make the notebook call the package implementation.
- Recommend Julia improvements with a concrete correctness, clarity, or
  efficiency benefit. Introduce abstractions and generality as needs arise.
- Keep each task record concise: question, agreed decisions, current checkpoint,
  actual validation outcomes and limits, unresolved issues, and the next step.
  Update it at meaningful checkpoints rather than logging every chat exchange.

## Git and GitHub guidance

- On resumption, inspect the actual branch, working tree, upstream, and relevant
  history before proposing Git operations. Distinguish cached remote refs from
  live verification; do not assume a proposed operation was performed.
- Recommend one branch per coherent task. Notebook exploration, validation,
  extraction, and tests can remain on that task's branch. Recommend a separate
  branch for independent questions, fixes, alternatives, or shared policy work,
  explaining the intended base branch and eventual integration target.
- Suggest small, coherent checkpoint commits; branch publication for remote
  backup; and pull requests when a scoped contribution is ready for feedback
  or integration. Keep unfinished research questions explicit. Existing
  authorization requirements for Git mutations remain in force.
- Keep repository-wide instruction changes separable from experiment code so
  they can reach main and other active branches without importing an experiment.
- For simultaneous chats on different branches, recommend separate worktrees
  with one branch per working directory. Avoid switching the shared checkout
  underneath another active chat.
