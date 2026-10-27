# F1: Initial states and input/output behavior

## Current numerical Hankel checkpoint — 2026-10-27

Working branch: `foundation/f1-hankel-matrices`, based on `b8930e1`.
The existing simulator is exported as `DataDrivenControl.simulate` from
[src/simulate_lti.jl](../src/simulate_lti.jl). Five original F1 assertions and
nine simulator regressions live in [test/simulate_lti.jl](../test/simulate_lti.jl);
the benchmark notebook calls the package.

The user has implemented the constructor in
[notebooks/F1_hankel_matrices.jl](../notebooks/F1_hankel_matrices.jl).
The $T=6$, $L=3$ hand-versus-Julia comparison is numerically verified:
**10/10 external checks passed** at the existing `rtol=atol=1e-12`.
The largest discrepancy was $2.220446049250313\times10^{-16}$.
The user's reflection is recorded: nearly identical floating-point results
can fail exact equality, making `isapprox()` important. References and tolerances
were not changed.

See [the Hankel record](F1_hankel_matrices.md) for source provenance, results,
and unresolved issues. The saved notebook still needs persistent approximate
assertions and updated result text. Its unused `Behavior` indexer remains
recursive; reusable depth handling is not yet established.

Session report: [F1 Hankel numerical progress record](../output/pdf/F1_Hankel_Numerical_Progress_Record_2026-10-27.pdf).

Validation chronology: the latest direct package suite passed **15/15**.
Earlier extraction checks passed **15/15** in both the direct suite and CI
`Pkg.test(; allow_reresolve=false)`; project/manifest were unchanged.
The pre-move baseline completed 18 non-setup cells with five assertions.
After extraction, 12 benchmark/7 Hankel non-setup cells and **5/5** binding/
trajectory checks passed. Six Julia files/five Markdown cells parsed, with
original cell IDs and user work preserved. Direct checks emitted Markdown/Test
import warnings. These are earlier executed checks, not numerical tests rerun
for this documentation update. Setup cells and Pluto UI remain untested.

Earlier notes and validation results below are historical.

## Status and continuity

The four-step numerical F1 checkpoint is verified: its earlier verification
passed **5 notebook assertions** and **9 independent trajectory checks**. The
saved notebook is `notebooks/F1_CC_benchmark.jl`; the user's reference to
`F2_CC_benchmark.jl` was confirmed to be a typo. Current demonstrations extend
the horizon to eight steps by repeating the input pattern, while the original
four-step assertions remain and pass. The user observes different trajectories;
the initial-state difference derivation and behavior explanation remain open.
A current-state view is used for the callback but not yet reused in the
state/output calculations. No notebook or implementation edits have been made
by the assistant.
Read this record before resuming F1. Keep it updated with agreed decisions,
completed checkpoints, actual validation outcomes, and the next step. Let the
user attempt the mathematical and coding steps before supplying complete
solutions.

Experiment 001 remains unfinished. Its scalar simulator checkpoint is preserved
at `3233f62` on `experiment/001-data-informativity`, including its notebook and
reference tests. Its record, `experiments/001_data_informativity.md`, is currently
empty on that branch. F1 starts separately from `main`; the scalar simulator has
not been copied into F1.

## Guiding question

For a fixed LTI system and input sequence, how does changing the initial state
change the output trajectory, and why do both input/output trajectories belong
to the same behavior?

## Fixed benchmark

The discrete-time LTI system is

```text
x[k+1] = A*x[k] + B*u[k]
y[k]   = C*x[k]

A = [0.8 0.2; 0.0 0.6]
B = [0.0, 1.0]
C = [1.0 0.0]
```

- State: `x[k] ∈ ℝ²`; control input: `u[k] ∈ ℝ`; measured output: `y[k] ∈ ℝ`.
- `A` is 2 × 2, `B` is a length-2 vector representing a 2 × 1 input map,
  and `C` is 1 × 2. Keep the scalar output convention explicit in Julia.
- All state, input, and output variables are dimensionless.
- Sampling interval: `Δt = 1 s`, with `t[k] = k*Δt`.
- Measurements are exact; there are no disturbances or measurement noise.
  Floating-point roundoff is separate from these modeling assumptions.

Both runs apply the same input sequence:

```text
[u[0], u[1], u[2], u[3]] = [1.0, 0.0, -1.0, 0.0]
```

| Run | Initial state `x[0]` |
| --- | --- |
| 1 | `[0.0, 0.0]` |
| 2 | `[0.0, 1.0]` |

Mathematical time indexing begins at `k = 0`. At each step, `y[k]` corresponds
to `x[k]` before applying `u[k]` to obtain `x[k+1]`. Four inputs produce states
`x[0]` through `x[4]`; outputs may also be evaluated through `y[4]`.
For a Julia array that stores the initial sample first, storage index `k+1`
corresponds to mathematical time `k`. Document the eventual storage layout
before implementing it. Align the input/output time windows explicitly before
later Hankel construction; a terminal output has no supplied `u[4]` here.
For the four-step benchmark, the implementation returns states at times `0:4`
and input/output vectors at times `0:3`; it does not return the optional terminal
output `y[4]`. The current eight-step demonstration is a separate extension:
states cover `0:8`, and inputs/outputs cover `0:7`, with the pattern repeated.

The state trajectories are simulator ground truth for this learning exercise.
Keep them separate from the recorded input/output trajectories that later
data-driven work will use. No state measurement assumption for a future method
is established by this benchmark.

## Next learning checkpoint

The learning checkpoint consists of the following, with the user's attempt
preceding a complete solution:

1. Calculate `x₁`, `x₂`, `y₀`, `y₁`, and `y₂` for both runs, showing the steps.
2. Predict how the output trajectories compare.
3. Derive how the initial-state difference determines the output difference
   under the common input sequence, stating the run subtraction order.
4. Explain why both input/output trajectories belong to the same behavior.

Item 1 is now numerically verified in the saved notebook for both runs,
following the handwritten review and corrections below. Both state references,
both output references, and the saved input reference pass. The user describes
the trajectories as diverging; the recorded outputs do differ, but their gap
eventually decreases within the eight-step demonstration. Use that distinction
when refining the comparison. The difference formula and behavior explanation
have not been supplied for review. The next learning step is the user's attempt
at those derivations. Later work will connect the recorded input/output
trajectories to Hankel matrices.

### Handwritten calculation review (before reported corrections)

Source: the user's two images, `IMG_2570.jpeg` and `IMG_2571.jpeg`, supplied on
2026-10-21. The benchmark matrices, input sequence, initial states, dimensions,
units, and sampling interval in the notes match this record.

| Run | `x₁` | `x₂` | `(y₀, y₁, y₂)` | Review outcome |
| --- | --- | --- | --- | --- |
| 1 | `[0.0, 1.0]` | `[0.2, 0.6]` | `(0.0, 0.0, 0.2)` | All correct. |
| 2 | `[0.2, 1.6]` | Revision needed. | `y₀ = 0.0`, `y₁ = 0.2`; revise `y₂`. | Correct `x₁` and these two output values; remaining step incomplete. |

Run 2's next matrix product substitutes `[0.2, 0.6]` for the correctly calculated
`x₁ = [0.2, 1.6]`, losing the input contribution in the second state component.
There is also a multiplication error: the written first-component expression
`0.16 + 0.48` does not match the displayed row–column product, even with the
incorrectly substituted vector. The reported `x₂ = [0.64, 0.36]` and `y₂ = 0.64`
therefore need revision.

The `y₁` calculation also writes the incorrect second state component, although
its value remains correct because `C` selects only the first component. Keep
the state vector consistent in that line too.

The retry hints were to carry the complete `x₁` into `x₂ = A*x₁ + B*u₁`,
evaluate each component as a row–vector dot product, and then apply `C` to the
revised `x₂`. In discussion, `0.96` was identified as the second component and
`0.32` as one contribution to the first component; the latter must also include
`0.8*0.2`. The user subsequently reported making the necessary corrections.
The user did not supply the full final corrected vector and output after those
hints. During the later code review, independent arithmetic and Julia checks
confirmed Run 2's `x₂ = [0.48, 0.96]` and `y₂ = 0.48` as the correct reference.

## Notebook setup guide

Current working file: `notebooks/F1_CC_benchmark.jl`. It contains a Pluto header,
the environment setup cell, simulator and input-rule definitions, system
parameters, a demonstration call, a validation cell, and matching cell-order
entries. The setup cell activates the repository root with
`Pkg.activate(project_dir)`, calls `Pkg.instantiate()`, and imports
`DataDrivenControl` and `Test`. The review executed the other cells in the shared
repository environment; it did not execute the setup cell or open Pluto.
The earlier placeholder path, `notebooks/F1_classical_control_benchmark.jl`, is
no longer present in the working tree. The original planned path was
`notebooks/F1_benchmark.jl`.

1. From the repository root, run `julia --project=.`. The `--project=.` option
   selects the repository's Julia environment for the session.
2. At the Julia prompt, run `using Pluto`, then `Pluto.run()` to open Pluto.
3. Open the saved notebook, `notebooks/F1_CC_benchmark.jl`, in Pluto.
4. Keep the notebook on the repository's shared environment. The existing setup
   cell already selects it; this is a minimal example of that pattern:

   ```julia
   begin
       import Pkg
       Pkg.activate(joinpath(@__DIR__, ".."))
       using DataDrivenControl, LinearAlgebra
   end
   ```

   `@__DIR__` locates the notebook directory; its parent is the repository root.
   An explicit `Pkg.activate` in a notebook selects Pluto's shared-environment
   workflow. See the [official Pluto environment documentation](https://plutojl.org/en/docs/packages-advanced/).
   Pluto and GLMakie are already declared in `Project.toml`; setup requires no
   dependency additions or upgrades. Pluto package loading and the full notebook
   session have not been tested by the assistant.
5. The user adds the problem definition, simulation, and validation against the
   hand calculations, following the general pattern used for Experiment 001.
   Include the question, benchmark, units, and indexing conventions in Markdown.
   Preserve Pluto-generated cell identifiers and cell order.

Prefer GLMakie when interactive plots are introduced. Reusable implementation
belongs in `src/`, with tests in `test/` independent of interactive graphics;
the notebook should focus on explanation, exploration, and visualization.
Assistant implementation edits require a proposed scope and approval under
`AGENTS.md`.

## Agreed implementation and review workflow

- The user writes the problem definition, simulation, and hand-reference
  validation before asking the assistant to review the code. Do not supply the
  implementation or begin that code review prematurely.
- Review correctness first: the two runs, state/input/output dimensions,
  time-to-array indexing, and agreement with independently checked hand values.
- Recommend changes with concrete value for efficient, idiomatic Julia:
  appropriate numeric and storage types, type stability, useful function
  boundaries, standard naming and mutation conventions, and avoidable
  allocations. Use generic functions and multiple dispatch when a concrete
  need makes them useful.
- Explain the benefit and tradeoff of each recommendation. Prioritize changes
  that improve correctness, clarity, or meaningful efficiency; avoid cosmetic
  rewrites, speculative optimization, and abstractions without a present need.
- Request clarification when a choice affects correctness or the intended
  interface and cannot be inferred from the implementation or this record.

## Verified checkpoints and validation

Initial documentation setup, inspected on 2026-10-21 (historical snapshot):

- `git status --short --branch` and the full porcelain status showed a clean
  working tree before these documentation edits, on `foundation/f1-benchmark`.
- Branch listings, logs, and reflogs confirmed F1 was created from local `main`
  at `62c2b4a`. `git merge-base foundation/f1-benchmark main` returned that
  commit; `git rev-list --left-right --count foundation/f1-benchmark...main`
  returned `0 0`.
- A live read of GitHub's branches API confirmed remote `main` at `62c2b4a` and
  remote `experiment/001-data-informativity` at `3233f62`. The experiment push
  is verified. No remote F1 branch was listed; local F1 has no upstream.
- `git show` and `git ls-tree` confirmed the scalar simulator checkpoint and
  its reference test files are preserved on the experiment branch. Those tests
  were inspected, not rerun; no new pass result is claimed.
- `git diff --check` returned exit status 0. The new-file check,
  `git diff --no-index --check /dev/null experiments/F1_benchmark.md`, returned
  exit status 1 with no whitespace diagnostics (the file differs from
  `/dev/null`). An independent Python whitespace scan passed for both files:
  no trailing whitespace, and each file ends with a newline.
- A one-off Python documentation check passed: every original `AGENTS.md` line
  remains in order, all five requested preferences and the benchmark/checkpoint
  details are present, and the notebook remains uncreated. A separate read-only
  review found no issues with completeness, indexing, or the Git record.
- `git diff --exit-code -- Project.toml Manifest.toml src test notebooks README.md .github`
  returned exit status 0: no changes to those paths. Final scope checks found
  only modified `AGENTS.md` and new `experiments/F1_benchmark.md`, both unstaged.

During that initial setup, no Julia tests, notebook execution, plots, or F1
numerical validation ran. No dependencies, commits, pushes, merges, or visibility
settings were changed.

Resuming on 2026-10-21 before the images were supplied (historical snapshot):

- The user reports completing `x₁`, `x₂`, `y₀`, `y₁`, and `y₂`. No values or
  intermediate steps were available in the message or saved notebook to check.
- Read `AGENTS.md`, this record, and the current notebook file.
  `wc -c notebooks/F1_classical_control_benchmark.jl` confirmed 0 bytes.
- `git status --short --branch` showed `foundation/f1-benchmark`, modified
  `AGENTS.md`, and untracked F1 record and notebook files. `git diff --name-only`
  and `git diff --cached --name-only` confirmed no other tracked changes and
  nothing staged. These commands inspect state without changing branches or
  files. No new live remote check was performed.
- Numerical review remains pending. No Julia tests or notebook execution ran.
- Documentation checks: `git diff --check` returned exit status 0. A one-off
  Python check passed for record content, whitespace, Markdown fences, actual
  notebook path/size, and Git scope. Existing edits and the empty notebook were
  preserved.

Handwritten review on 2026-10-21:

- Read both supplied images and checked the handwritten substitutions,
  arithmetic, and output indexing against the specified state and output
  equations. An independent manual review agreed with the outcomes above.
- Run 1 passed this manual review. Run 2's `x₁`, `y₀`, and `y₁` numerical values
  passed; its written state vector needs consistent substitution, and its `x₂`
  and `y₂` did not pass. No tolerances or benchmark data were changed.
- The notebook still has 0 bytes. No simulator was implemented or executed,
  and no Julia tests or notebook execution ran. This is a manual mathematical
  review, not an automated test result.
- Documentation validation: `git diff --check` passed. A Python check passed
  for whitespace, Markdown fences, unchanged Git scope, and the notebook's
  unchanged empty state.

Notebook implementation plan on 2026-10-21:

- The user reports applying the hand-calculation corrections and chooses to
  implement and validate in the notebook before requesting code review.
  This report does not establish independent verification of the final values.
- Inspected `notebooks/F1_CC_benchmark.jl`: the Pluto structure and environment
  setup cell are present. No problem definition, simulator, or validation cells
  were present in the saved file at this inspection.
- `git status --short --branch`, `git diff --name-only`,
  `git diff --cached --name-only`, and `git ls-files --others --exclude-standard`
  showed branch `foundation/f1-benchmark`, existing modified `AGENTS.md`,
  untracked F1 record and current notebook, and nothing staged. These were
  read-only checks of the working state; no branch switch or Git mutation ran.
- No Julia tests, notebook execution, or performance measurements ran.
- Documentation validation passed: `git diff --check` and a Python whitespace
  and Markdown-fence check. SHA-256 comparisons confirmed the notebook and
  `AGENTS.md` were unchanged during this update. The implementation/dependency
  diff was empty, and a separate read-only review found no record issues.

## Initial notebook review on 2026-10-22 (historical snapshot)

### Findings and useful next improvements

1. `simulate` accepts `rule`, but its loop calls the global `varied_rule`
   instead. The initial `rule` result is overwritten. A zero-input callback
   reproduced the problem: stored inputs remained `[1.0 0.0 -1.0 0.0]`.
   Use the supplied rule consistently and avoid evaluating the first input
   twice. This is an interface correctness issue, not a performance preference.
2. `C` and `D` are unused; no output trajectory is computed or returned.
   This benchmark requires `y[k] = C*x[k]`. Choose an explicit scalar-output
   storage convention and time window, then record and validate the outputs.
   `D` is outside this benchmark's specified equation and can be omitted until
   a direct-feedthrough model is actually needed.
3. The notebook tests only initial state `[0.0, 0.0]`. Add the second run and
   independent hand-reference checks for both states and outputs. Run 2's
   correct first three states are `[0.0 0.2 0.48; 1.0 1.6 0.96]`, with outputs
   `[0.0, 0.2, 0.48]`. Run 1's output reference is `[0.0, 0.0, 0.2]`.
4. Add brief Markdown explaining the guiding question, dimensions, units,
   sampling interval, exact/no-disturbance assumptions, and time indexing.
   Distinguish simulator state information from measured input/output data.
5. For idiomatic Julia, preserve the vector interpretation of the initial
   state when assigning the first state column; the adjoint `x₀'` is unnecessary
   for that assignment. It runs for the current real-valued benchmark and is
   not a demonstrated failure here.
6. Concrete allocation opportunities are the input-pattern vector constructed
   inside every `varied_rule` call and repeated `x[:, k]` column copies. Reuse
   the fixed sequence and consider views of the current state column. Defer
   more involved workspaces or in-place matrix multiplication until a measured
   need warrants the added complexity. No performance measurements were made.

The current `Float64` storage fits this benchmark. Untyped function arguments
are not themselves a Julia performance defect. The state/input matrices use
columns for time; the present input update implements the scalar-input case,
even though `m = length(u₀)` could suggest broader support. Keep that scope
explicit before generalizing.

Filename suggestion, not yet an agreed rename: `F1_initial_state_response.jl`
describes the experiment's question more directly. No file was renamed.

### Actual execution and outcomes

- Julia `1.13.2`, launched with `--startup-file=no --project=.`, reported this
  repository's `Project.toml` as its active project. Pluto's source path was
  discoverable; Pluto itself was not loaded or launched.
- A temporary stdin review harness extracted and executed the eight saved
  non-setup cells. All eight executed successfully. The original notebook
  testset passed **2/2** assertions with its existing `rtol=1e-12`, `atol=1e-12`.
- The same harness ran **8 independent checks: 6 passed, 2 failed**. The passes
  checked both runs' first three states, the intended common input sequence,
  equality of the two input records, and the first three outputs calculated
  externally from each state record. These external output calculations do
  not mean the simulator records outputs.
- The two failures checked for a returned output trajectory (`:outputs`) and
  whether a supplied zero-input rule produced zero stored inputs. The result
  has no output field, and the zero-rule call still stored the fixed pattern.
  The review process exited with status 1 because these checks failed. A
  particular output field name is not a fixed interface requirement; computing
  and returning the output trajectory is the substantive missing behavior.
- The tests were run against the original code without repairs. No reference
  values, tolerances, or failing cases were changed to obtain a pass.
- The harness was not saved into the repository. `Pkg.instantiate()`, Pluto UI
  execution, the package-wide test suite, and performance benchmarks were not
  run. No dependencies were changed.
- Separate read-only scientific and Julia reviews agreed on the priority
  findings. Static review found no problem with the first-run hand references
  or the mapping from columns 2:3 to mathematical times 1:2.
- Documentation checks passed: `git diff --check` and a Python whitespace,
  final-newline, and Markdown-fence check. SHA-256 comparisons confirmed the
  notebook, project/manifest, source, tests, and `AGENTS.md` were unchanged
  during review. A read-only consistency review found no issues in this record.

## Column slicing discussion on 2026-10-22

- Current source inspection confirmed the user's loop now calls `rule` and
  initializes the first state column with `x₀` directly. The callback and
  unnecessary-adjoint findings from the initial review have been addressed;
  the duplicate initial callback evaluation remains.
- Suggested a local view, `xk = view(x, :, k)`, reused in the callback and state
  update. This avoids copying the current state column for those reads.
  `x[:, k+1] = ...` already writes into the destination matrix column.
- A view shares storage with the state history. A callback receiving it must
  treat the state as read-only to preserve the intended simulation. The view
  is a `SubArray`, accepted by the current generic callback. The proposal has
  not been applied to the notebook or adopted as an agreed interface change.
- Views address the column-data copies; arithmetic-result allocations remain.
  No overall speedup or allocation count was measured. See the official
  [Julia view documentation](https://docs.julialang.org/en/v1/base/arrays/#Base.view).
- A temporary Julia stdin example ran in the shared project: **3/3** copy/view
  semantics checks, **6/6** proposed-loop hand-reference and equivalence checks
  across both initial states, and **1/1** current-code zero-input rule check
  passed (**10/10** total). The proposed loop was evaluated in memory only.
  The environment setup cell, full Pluto session, and package test suite were
  not run. No notebook files or dependencies were changed.

## Scalar-output storage discussion on 2026-10-22

- Current source has `y = zeros(T)` and `u = zeros(T)`, a view for the callback's
  state argument, and state assertions for both initial conditions. The initial
  callback is no longer evaluated outside the loop. These are source-inspection
  observations, not a new full notebook test result.
- With `C` stored as a 1 × 2 matrix, `C*xk` is a length-one vector. Suggested
  `y[k] = only(C*xk)` to extract its sole scalar for the existing output vector.
  The commented `C*x[:, k][1]` instead selects a state component before the
  multiplication and does not extract the output scalar.
- With a length-`T` output vector and the existing loop, stored samples represent
  `y[0]` through `y[T-1]`. Including terminal `y[T]` requires an additional
  sample. Outputs also need to be included in the returned result.
- A standalone Julia example using the shared project passed **3/3** checks:
  the product is a length-one vector, scalar extraction reproduces
  `[0.0, 0.2, 0.48]`, and a stored output sample is `Float64`. No notebook cells,
  environment setup, package tests, or performance measurements ran.
- On the next full review, check the input reference's shape: the saved input
  assertion still uses a row matrix while `u` is now stored as a vector.

## Incremental notebook review on 2026-10-22

- `(C*x[:, k])[1]` now correctly extracts the scalar output after multiplication.
  The loop populates the length-`T` vector with `y[0]` through `y[T-1]`, but the
  return still includes only `x₀`, `states`, and `inputs`. Return the outputs and
  add hand-reference output assertions for both runs.
- `inputs` is a length-4 vector. The saved input reference is a 1 × 4 row matrix.
  Match the reference's shape to the chosen vector convention without changing
  its benchmark values or the existing tolerances.
- The view `xk` is passed to `rule`; the state and output expressions still read
  `x[:, k]`. Reuse `xk` in those calculations to apply the earlier view suggestion.
- Executed the eight original non-setup cells in the shared Julia project:
  **7 completed, 1 errored**. The saved testset reported **2 passed, 1 errored**:
  both state checks passed, while the input check threw `DimensionMismatch` for
  shapes `(4,)` and `(1, 4)`. The process exited with status 1. No failing case,
  reference, tolerance, or code was changed before or during this execution.
- Diagnostic calls confirmed the input values `[1.0, 0.0, -1.0, 0.0]` for both
  runs and the absence of a returned output field. Outputs reconstructed
  externally from the first three saved states were `[0.0, 0.0, 0.2]` and
  `[0.0, 0.2, 0.4800000000000001]`; the last number reflects floating-point
  arithmetic. These diagnostics do not validate the unreturned local `y` array.
- The setup cell, full Pluto session, package-wide tests, and performance
  benchmarks were not run. The harness was supplied via stdin and not saved
  into the repository. A separate static review agreed with the findings.

## Numerical checkpoint verification on 2026-10-22

- The saved simulator now returns `states`, `inputs`, and `outputs`. The input
  reference matches vector storage, and both runs have state and output
  assertions. No static correctness blockers remain for the specified four-step
  benchmark.
- Julia `1.13.2`, launched with `--startup-file=no --project=.`, reported the
  repository's `Project.toml` as its active project. Executed **8 nonempty,
  non-setup cells** successfully; skipped the setup cell and one empty cell.
- The original notebook testset passed **5/5** assertions: state references for
  each run, the first run's input sequence, and output references for each run.
  Its `rtol=1e-12` and `atol=1e-12` were retained.
- A temporary stdin harness passed **9/9 independent checks**: the second run's
  input sequence; equality of both input records; state/input/output sizes for
  each run; agreement of each complete recorded output vector with `C` applied
  to the matching state columns; and zero inputs, states, and outputs when a
  zero-input callback is supplied from the zero initial state. The process
  exited with status 0.
- No notebook code, reference values, tolerances, or failing cases were changed
  during verification. The harness was not saved into the repository. The setup
  cell, full Pluto session, package-wide tests, and performance measurements
  were not run.
- Remaining nonblocking work: reuse `xk` in the state/output calculations,
  remove unused `m` and `D` (`size(B)[1]` is the state dimension here), and add
  brief Markdown explaining the benchmark and time/storage conventions.
  Reusing the fixed input sequence is optional allocation cleanup; no speedup
  has been measured. No additional abstraction or numeric-type change is needed
  for this benchmark.

## Output comparison and further suggestions on 2026-10-22

- The saved demonstrations now use eight steps. `varied_rule` repeats its
  four-element pattern, so the input is
  `[1.0, 0.0, -1.0, 0.0, 1.0, 0.0, -1.0, 0.0]` in both runs. This continuation
  is not a change to the original four-step benchmark or its tests.
- The notebook subtracts Run 2 from Run 1. The absolute recorded output gap
  peaks at approximately `0.296` at mathematical time `k=3`, then decreases to
  approximately `0.1817216` at `k=7`. Different output trajectories are observed;
  unbounded divergence is not supported by this observation.
- `A` has eigenvalues `0.6` and `0.8`. With identical continuing inputs, the
  initial-state effect tends to zero; this does not mean each driven output
  must tend to zero under the continuing periodic input. The user will still
  derive the initial-state/output-difference relation rather than receiving
  its complete solution here.
- Suggested, not implemented: label the eight-step continuation; plot the common
  input, both outputs, and their difference with GLMakie and matched time axes;
  state the subtraction order; and document the scalar-input/output interface,
  array shapes, sample indexing, and read-only callback state in a docstring.
- Suggested validation improvements: preserve the existing hand checks, add a
  reference that exercises the negative input at `u[2]` through `x[3]`, and
  retain the zero-input callback regression as a permanent test. After the user
  derives the difference relation, it can supply another full-horizon check.
- The reusable simulator and its regression checks can be extracted into `src/`
  and `test/`, with the notebook focused on setup, interpretation, and plots.
  Assistant extraction requires a proposed scope and approval; no extraction
  or other implementation change has been made.
- Execution: **12 nonempty non-setup cells** completed, and the original
  notebook testset again passed **5/5** assertions without changed values or
  tolerances. The eight-step input/output difference and eigenvalues were
  inspected numerically. The earlier nine independent checks were not rerun.
  The process exited with status 0. No setup cell, full Pluto session,
  package-wide tests, or performance benchmarks ran.

## Local checkpoint preparation on 2026-10-22

- The user requested staging and committing the current work on
  `foundation/f1-benchmark`, with further Julia edits deferred until returning
  to the branch. Scope: `AGENTS.md`, this record, and
  `notebooks/F1_CC_benchmark.jl`. No push was requested.
- Re-executed the **12 nonempty non-setup notebook cells** using Julia `1.13.2`
  with `--startup-file=no --project=.`: all completed, and the saved notebook
  assertions passed **5/5** with unchanged references and tolerances.
- Ran `julia --startup-file=no --project=. test/runtests.jl`: the repository's
  package/numerical smoke test passed **1/1**. Both Julia commands exited 0.
- `git diff --no-index --check /dev/null notebooks/F1_CC_benchmark.jl` reported
  trailing whitespace on lines 37 and 82 and exited 3. Those whitespace-only
  lines were preserved with the rest of the user's notebook; this check did
  not pass. No implementation cleanup was performed to prepare the checkpoint.
- The notebook setup cell, full Pluto session, `Pkg.test()`, performance
  benchmarks, and the earlier nine independent trajectory checks were not run
  during this checkpoint preparation. No dependencies were changed.
- Deferred Julia suggestions include reusing `xk`, a fixed tuple for the periodic
  input pattern, removing unused `m`/`D`, and documenting the simulator contract.
  `only(C*xk)` is an optional way to enforce the scalar-output contract; the
  existing `[1]` is correct for this benchmark. Extraction into `src/`/`test/`,
  plots, and the remaining mathematical explanation are still future work.

## Remaining Git setup

The experiment push and creation of F1 from updated `main` were verified at the
initial setup check; they do not need to be repeated. F1 was local only at that
check; remote status has not been rechecked during this checkpoint resumption.

The user explicitly authorized a local commit of the checkpoint described above.
Inspect `git log -1 --oneline` and `git status --short --branch` to verify the
completed commit and working state. This authorization is for that checkpoint,
not future commits. `git push -u origin foundation/f1-benchmark` would publish
F1 and configure its upstream; pushing still requires a separate explicit
request under `AGENTS.md`.

## Next step

The user explains how the output trajectories compare, then derives how their
difference depends on the initial-state difference under identical inputs, and
explains why both input/output trajectories belong to the same behavior.
Let the user attempt those steps before supplying complete solutions. Add the
brief problem and indexing explanation to the notebook; the nonblocking cleanup
above can be addressed incrementally.
Reusable implementation and automated tests belong in `src/` and `test/`
respectively; propose and approve that extraction before assistant edits.
