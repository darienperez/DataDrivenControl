# F1: Hankel matrices by hand and in Julia

**Status — 2026-10-27:** The numerical Hankel checkpoint is verified for $T=6$,
$L=3$ on `foundation/f1-hankel-matrices` (base `b8930e1`). The constructor is
implemented in [the notebook](../notebooks/F1_hankel_matrices.jl); validation
cleanup and separate wrapper issues remain and are deferred by the user.

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

## Deferred cleanup and next session

**User decision — 2026-10-27:** Commit and publish the current checkpoint;
leave cleanup for another session. The numerical objective is complete for
this example; publication does not mark the branch ready to merge.

- [ ] Save visible approximate assertions for `Hu`, `Hy`, and `H`, plus their
  expected shapes, using the existing `rtol=atol=1e-12`. The saved cell still
  evaluates `H == hand_H`, then displays `hand_H`, hiding the Boolean.
- [ ] Replace result placeholders and outdated unfinished/TODO wording with
  the verified outcome and the floating-point interpretation.
- [ ] Fix or explicitly defer the unused `Behavior` indexer, which still
  recurses. An isolated probe produced `StackOverflowError`; this does not
  affect the verified Hankel path.
- [ ] Remove the trailing space on the notebook's `test = [1,2, 5,6, 22, 11]`
  line (currently line 245).
- [ ] After cleanup, rerun the relevant notebook checks and package tests,
  and update this record before assessing merge readiness.

Resume this checklist on `foundation/f1-hankel-matrices`. Before broader reuse,
define valid-depth behavior: observed probes give $0\times7$ at $L=0$,
$7\times0$ at $L=7$, and `ArgumentError` at $L=8$.
This checkpoint verifies the finite example, without establishing general trajectory spanning.
