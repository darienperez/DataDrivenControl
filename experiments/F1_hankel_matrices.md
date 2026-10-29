# F1: Hankel matrices by hand and in Julia

**Status — 2026-10-29:** The finite numerical F1 checkpoint is closed out
locally on `foundation/f1-hankel-matrices`. The notebook now saves the verified
comparison and its interpretation. The user approved the closeout commit,
merging current `main` into the feature branch, publishing, and opening the PR.
Those approved Git operations will be recorded at the publication checkpoint.

## Current closeout checkpoint

The user's current request authorizes finishing the recorded notebook cleanup
and preparing the PR. The existing working edits were retained: the unused
recursive `Behavior` wrapper and scratch cells had already been removed, and
approximate comparisons had been started. Closeout preserves all 16 current
cell IDs/order, the constructor, setup, input rule, and independent hand values.
It adds the original explicit `rtol=atol=1e-12`, expected shapes, aligned sample
checks, and first/last trajectory windows; unfinished result text is replaced.
The saved notebook has **10 passing assertions**.

Validation executed on 2026-10-29:

- `julia --startup-file=no --project=. --compiled-modules=no /private/tmp/ddc_f1_closeout_validate.jl /Users/darien/Research/DataDrivenControl`:
  **12 benchmark and 15 Hankel non-setup cells executed**, including the saved
  **10/10** assertions; **15/15** additional independent-reference checks passed.
  The temporary harness checked exact rational scalar states through terminal
  `x_6=32217/31250`, independently assembled windows, early benchmark references,
  and the documented floating-point equality/discrepancy observations. The
  harness is a session-local file, not a committed regression test.
- `julia --startup-file=no --project=. -e 'using Pkg; Pkg.test(; allow_reresolve=false)'`:
  **15/15 passed** (1 smoke, 5 original simulator, 9 simulator regression).
  The first sandboxed attempt stopped before tests with an `EPERM` on Julia's
  depot manifest-usage lock; the rerun with depot access succeeded.
- `julia --startup-file=no --project=. test/check_agents.jl`: **108/108 passed**.
- `julia --startup-file=no --project=. scripts/check_agents.jl`: passed; canonical
  commit `a397700d982e0a1324455863f84daab09612fc5a`. Live GitHub reads separately
  confirmed that `main` and the published F1 head still match their cached refs.
- Python static checks passed for both notebooks' unique cell IDs and physical/
  declared cell order, current-user-cell preservation, and unchanged protected
  files. Final scope checks found exactly the three planned closeout files changed;
  the other **17/17 tracked files** matched the starting snapshot, including both
  dependency files, package code/tests, the PDF, and all policy artifacts. Record
  links and `git diff --check` passed.

The non-setup run emitted Markdown/Test imported-binding warnings; the package
suite succeeded and printed only the compatibility-restricted-version notice.
Setup cells were parsed, not executed. Pluto UI/reactive execution and new
GitHub Actions runs were not exercised. Earlier results below remain historical.

The numerical scope is the fixed `T=6`, `L=3` example. General depth handling
and package extraction remain deferred until broader reuse. The original
benchmark's initial-state difference derivation and behavior explanation remain
unreviewed learning work, not completed research claims. No general trajectory
spanning or persistent-excitation conclusion follows from these checks.

Approved Git sequence — 2026-10-29: commit the three closeout files, bring verified
current `main` into the feature branch to remove already-synchronized policy
history from the PR diff, publish the feature branch, and open its PR to `main`.
This feature-branch synchronization preserves published history; it does not
integrate F1 into `main`. Before these operations the branch was 4 commits ahead /
2 behind `origin/main`, and all five shared policy files already matched byte for
byte. Integration of the PR into `main` remains a separate, unapproved action.

## Historical checkpoint — 2026-10-27

The numerical Hankel checkpoint was verified for `T=6`, `L=3` on
`foundation/f1-hankel-matrices` (base `b8930e1`). Cleanup was explicitly deferred
at that checkpoint and resumed by the current closeout request.

Session report: [F1 Hankel numerical progress record](../output/pdf/F1_Hankel_Numerical_Progress_Record_2026-10-27.pdf).

## Question and hand reference

Do Julia-constructed matrices match the hand calculation in entries, dimensions,
column order, and input/output alignment?

Source: `F6_F1_Progress_Record_2026-10-27.pdf`, model §2/page 1 and F1 hand work
§3/page 2; the external PDF was not copied into the repository.

$$
x_{k+1}=0.8x_k+0.5u_k,\qquad y_k=x_k,\qquad x_0=1.
$$

No physical units or sampling interval are assigned. Recorded samples $k=0,\ldots,5$ are
$u_{0:5}=(0,1,-1,1,0,1)$ and
$y_{0:5}=(1,0.8,1.14,0.412,0.8296,0.66368)$.
The corrected $y_4=0.8296$ and unrounded $y_5=0.66368$ remain unchanged.
Simulator states additionally include $k=6$; Julia index is $k+1$.

Both blocks lie in $\mathbb{R}^{3\times4}$;
$H=[H_3(u);H_3(y)]\in\mathbb{R}^{6\times4}$ has input rows first.
Columns cover $0{:}2$, $1{:}3$, $2{:}4$, and $3{:}5$.
Inputs and outputs share their start time; in this scalar case $u_k$ affects
$y_{k+1}$, without direct feedthrough to $y_k$.

## Numerical result and reflection

The latest external review passed **10/10 checks** using the existing
`rtol=atol=1e-12`. `Hu == hand_Hu` was `true`; `Hy == hand_Hy` and
`H == hand_H` were `false`. The maximum absolute discrepancy was
$2.220446049250313\times10^{-16}$.

The user observed nearly identical results: small discrepancies produced a
false exact comparison and highlighted why `isapprox()` matters.
No data, hand references, rounding, or tolerances were changed to obtain agreement.

The latest direct package suite (`test/runtests.jl`) passed **15/15**.
Earlier extraction CI also passed **15/15**; its baseline/harness results remain
in [the benchmark record](F1_benchmark.md). Earlier PDF-reference verification
passed **11/11**. That update parsed syntax/four Markdown cells, preserved eight
prior cell IDs/order and user code, and left ten protected files unchanged;
package tests were not rerun then. Those documentation checks did not rerun
numerical tests or CI. Setup cells and Pluto UI remain untested.

**Publication check — 2026-10-27:**
`julia --project=. --startup-file=no --compiled-modules=no test/runtests.jl`
passed **15/15** assertions (1 smoke, 5 original simulator, 9 simulator regression).
Markdown/Test import warnings were emitted. The notebook checks, isolated
`Behavior` probe, and CI were not rerun; the deferred notebook issues remain.
Record links, math delimiters, and whitespace checks passed; ten protected
code/config/notebook files were unchanged. The full staged `git diff --cached
--check` reported one trailing-space warning at notebook line 245, retained
with the deferred cleanup.

## Historical cleanup deferral — 2026-10-27

**User decision — 2026-10-27:** Commit and publish the current checkpoint;
leave cleanup for another session. The numerical objective is complete for
this example; publication does not mark the branch ready to merge.

- [x] Save visible approximate assertions for `Hu`, `Hy`, and `H`, plus their
  expected shapes, using the existing `rtol=atol=1e-12`. The saved cell still
  evaluates `H == hand_H`, then displays `hand_H`, hiding the Boolean.
- [x] Replace result placeholders and outdated unfinished/TODO wording with
  the verified outcome and the floating-point interpretation.
- [x] Fix or explicitly defer the unused `Behavior` indexer, which still
  recurses. An isolated probe produced `StackOverflowError`; this does not
  affect the verified Hankel path.
- [x] Remove the trailing space on the notebook's `test = [1,2, 5,6, 22, 11]`
  line (currently line 245).
- [x] After cleanup, rerun the relevant notebook checks and package tests,
  and update this record before assessing merge readiness.

All five cleanup items above were completed by 2026-10-29; the user had removed
the unused wrapper and scratch line before this closeout. The descriptions above
refer to the saved 2026-10-27 state, not the current notebook. Before broader reuse,
define valid-depth behavior: observed probes give $0\times7$ at $L=0$,
$7\times0$ at $L=7$, and `ArgumentError` at $L=8$.
This checkpoint verifies the finite example, without establishing general trajectory spanning.
