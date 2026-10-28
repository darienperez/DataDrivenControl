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
- Favor idiomatic Julia, appropriate numeric types, type stability, efficient
  allocation, and standard naming and mutation conventions. Use generic
  functions and multiple dispatch where appropriate, introducing abstractions
  as concrete needs emerge.

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
  Small notebook-local prototypes are appropriate during exploration.
- Review correctness, dimensions, indexing, and agreement with independently
  checked references before recommending implementation cleanup.
- Validate against independent hand calculations or trusted references and
  relevant invariants. Preserve meaningful failures and distinguish numerical
  verification from conclusions about the research question.
- Once an implementation is useful beyond exploration, propose extracting it
  into src/ and its regression checks into test/. After extraction, rerun the
  relevant checks and make the notebook call the package implementation.
- Explain the concrete correctness, clarity, or meaningful efficiency benefit
  and tradeoff of Julia recommendations. Avoid cosmetic rewrites, speculative
  optimization, and abstractions without a present need.

## Learning and task records

- Let the user attempt important mathematical and coding steps before giving
  complete solutions.
- When resuming a named task, read its repository record first. Check current
  files and branch state before relying on historical or cross-branch notes.
- Keep one concise repository record for each substantive task; reuse the
  existing record. Research records normally live in experiments/. Include
  routine record upkeep in the proposed task scope.
- Update the record at meaningful checkpoints and before a handoff or task
  completion, rather than logging every chat exchange. Capture the question,
  agreed decisions, completed work, current checkpoint, actual validation
  outcomes and limits, unresolved or deferred issues, and the concrete next step.
- Keep current status separate from dated historical results. Identify commands
  or notebook cells actually executed, outcomes, warnings, and checks not run;
  distinguish new validation from earlier results that were not rerun.
- Distinguish proposed work from performed work and confirmed user decisions.
  Preserve explicit user deferrals and source provenance needed to reproduce
  results. A verified numerical checkpoint or published branch does not by
  itself establish that the research question is settled or the work can merge.

## Git and GitHub guidance

- Explain Git/GitHub operations until the user explicitly asks you to stop.
- On resumption, inspect the actual branch, working tree, upstream, and relevant
  history before proposing Git operations. Distinguish cached remote refs from
  live verification; do not assume a proposed operation was performed.
- Recommend one branch per coherent task. Notebook exploration, validation,
  extraction, and tests can remain on that task's branch. Recommend a separate
  branch for independent questions, fixes, alternatives, or shared policy work,
  explaining the intended base branch and eventual integration target.
- Suggest small, coherent checkpoint commits, branch publication for remote
  backup, and pull requests when a scoped contribution is ready for feedback
  or integration. Keep unfinished research questions explicit. Suggestions do
  not authorize Git mutations; the working agreement still applies.
- For simultaneous chats on different branches, recommend separate worktrees
  with one branch per working directory. Avoid switching the shared checkout
  underneath another active chat.

## Maintaining repository instructions

- `main:AGENTS.md` is the canonical approved repository policy. Active task
  branches carry its approved contents; task-specific decisions, progress, and
  deferrals belong in the existing task record rather than branch-only rules.
- Before starting or resuming substantive work, run
  `julia --startup-file=no --project=. scripts/check_agents.jl` and read the
  task record. Report the canonical commit and any differences. The default
  `origin/main` comparison uses a cached ref, not live remote verification.
- A mismatch requires inspection, not an automatic overwrite. Read the canonical
  policy and preserve branch-only preferences for review. Resolve drift before
  implementation unless the user has approved work on the policy itself.
  Read-only review can continue with the policy source and differences explicit.
- Propose shared instruction changes independently of research code, starting
  from current `main`. Follow the policy review and distribution procedure in
  `README.md`; an ordinary research PR must preserve the shared policy artifacts.
- After an approved policy change reaches `main`, propose distributing its
  policy artifacts to active branches without importing research changes.
  Synchronization does not authorize commits, pushes, or merges.
- Record policy decisions, validation outcomes, and outstanding rollout work in
  the policy change's record or PR. Keep research records focused on their task
  checkpoints rather than duplicating shared policy text.
- If the checker is absent on an older branch, use the trusted version from
  canonical `main` as described in `README.md`. Existing chats must explicitly
  reread approved instruction updates; updating a file does not refresh a
  session's already loaded instructions.
