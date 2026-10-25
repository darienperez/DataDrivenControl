# Experiment 001: Data informativity

**Status:** Unfinished. Last committed simulator checkpoint: `3233f62` on
`experiment/001-data-informativity`. The scalar simulator is already extracted
into `src/`, exported, and covered by reference tests.

## Question and scope

Can a measured trajectory represent an arbitrary state-input pair
`q = [x, u]ᵀ` through `Dg = q`, with `D = [X₋; U₋]`, and then predict its
successor through `X₊g`? Can a longer record compensate for missing directions?
The user will attempt the derivation, implementation, and interpretation first.
This checkpoint supplies a scaffold, not a conclusion.

Use the fully observed, noise-free scalar system `xₖ₊₁ = a*xₖ + b*uₖ`, with
`a = 0.8`, `b = 0.5`, and `x₀ = 1`. The measured output is `yₖ = xₖ`;
states, inputs, and outputs are dimensionless. Sampling is one arbitrary time
unit per step. For `T` transitions, states run from `x₀`
through `x_T` and inputs from `u₀` through `u_{T-1}`. The rows `X₋`, `X₊`,
and `U₋` each have `T` columns; `D` is `2 × T` and `g` has length `T`.
Reconstruction uses trajectory data; known `a,b` are simulator ground truth for
validation. Controller synthesis and noisy robustness are outside scope.

## Agreed comparison

- Retain `simulate_scalar`. Compare feedback `uₖ = -xₖ` with the periodic input
  `(0, 1, -1, 1)` at `T = 20, 100`, using matching trajectory prefixes.
- Report raw singular values, `σᵢ/σ₁` with explicit zero handling, and numerical
  rank. Use the fixed relative SVD cutoff `1e-12` consistently for rank and
  reconstruction.
- Query `[1,0]`, `[0,1]`, and `[1,-1]`; zero is a separate sanity check. Report
  `‖Dg-q‖₂/‖q‖₂` for nonzero queries and absolute residual for zero. Set the
  residual acceptance rule before evaluating outcomes; retain unsupported
  queries distinctly from supported predictions.
- Validate indexing and supported predictions against independent hand cases
  and `a*x + b*u`. Record actual results and their limits.

## Validation and next step

Prior resumption assessment: Julia 1.13.2,
`julia --project=. --startup-file=no --compiled-modules=no test/runtests.jl`:
**6/6 assertions passed**, with Markdown/Test import warnings. These verify
existing reference cases; no new scientific comparison has run.

Scaffold checks: Julia syntax and all nine Markdown cells parsed; all 19 cell
IDs, order entries, and cell kinds matched. All six original cell bodies and
their relative order were preserved. `git diff --check` passed. Julia emitted
Markdown import warnings. The notebook was not executed in Pluto, and the
reference suite was not rerun for these scaffold edits.

Next: the user fills the notebook's derivation, code, results, and interpretation.
Propose further extraction only if a new helper proves reusable.
