### A Pluto.jl notebook ###
# v1.0.4

using Markdown
using InteractiveUtils

# ╔═╡ 8339dfbe-c98d-11f1-af7f-d9be02cc3632
begin
    using Pkg

    # The project is one directory above this notebook.
    project_dir = normpath(joinpath(@__DIR__, ".."))
    Pkg.activate(project_dir)
    Pkg.instantiate()

    using DataDrivenControl, Test
end

# ╔═╡ d7210637-d620-46e7-a2c3-37fca16c7201
md"""
# Experiment 001: data informativity

Can collected data reconstruct any requested state–input pair
``q=[x,u]^{\mathsf T}`` and predict its next state directly from those data?
Does a longer record compensate for missing state–input directions?

**Checkpoint:** scaffold only. The derivation, implementation, results, and
interpretation below are for your first attempt. The existing simulator and
its short reference checks are retained.

This experiment covers noise-free reconstruction and one-step prediction.
Controller synthesis and noisy-data robustness belong to later experiments.
"""

# ╔═╡ 74b06145-3970-4d3e-96d5-2046121ff1c4
md"""
## Model, measurements, and conventions

The simulator uses the discrete-time scalar dynamics
``x_{k+1}=a x_k+b u_k``, with ``a=0.8``, ``b=0.5``, and ``x_0=1``.
The state is fully observed: measured output ``y_k=x_k``, without noise.
States, inputs, and outputs are dimensionless; the sampling interval is one
arbitrary time unit.

- Mathematical time starts at ``k=0``; ``T`` counts transitions.
- The returned states contain ``x_0,\ldots,x_T`` and the inputs contain
  ``u_0,\ldots,u_{T-1}``. Julia index `k + 1` corresponds to time ``k``.
- ``X_-``, ``U_-``, and ``X_+`` are each ``1\times T``;
  ``D=[X_-;U_-]\in\mathbb R^{2\times T}``,
  ``q\in\mathbb R^2``, and ``g\in\mathbb R^T``.
- The requested reconstruction is ``Dg=q``, followed by the data prediction
  ``\hat{x}^{+}=X_+g``.

Use only recorded data and the query for reconstruction and prediction.
The known parameters ``a,b`` are simulator ground truth for validation.
"""

# ╔═╡ f754b5e7-e74c-46cb-b221-14c95d125e25
md"""
## Existing simulator references

These short cases check simulator arithmetic. The experiment comparison at
``T=20,100`` is separate and remains to be implemented below.
"""

# ╔═╡ 8a5b6550-e227-47f5-aba6-b631a7c66162
function varied_rule(k, x)
	u = [0, 1, -1, 1]
	idx = mod(k, length(u)) + 1
	u[idx]
end

# ╔═╡ 4627f426-dc5c-43eb-a657-11aa5ad95a26
simulate_scalar(0.8, 0.5, 1, (k, x) -> -x, 4)

# ╔═╡ 9d15864f-b8b9-434c-9bde-b1b7d3b8a489
simulate_scalar(0.8, 0.5, 1, varied_rule, 8)

# ╔═╡ 99d9fd65-e9fb-4dbb-9c66-f736545645df
@testset "Fixed-feedback reference" begin
    trial = simulate_scalar(0.8, 0.5, 1.0, (k, x) -> -x, 4)

    @test isapprox(trial.states,
                  [1.0, 0.3, 0.09, 0.027, 0.0081];
                  rtol=1e-12, atol=1e-12)

    @test isapprox(trial.inputs,
                  [-1.0, -0.3, -0.09, -0.027];
                  rtol=1e-12, atol=1e-12)
end

# ╔═╡ fa7ed1fe-d177-4db1-84e7-3676aaf79534
@testset "Varied input reference" begin
    trial = simulate_scalar(0.8, 0.5, 1.0, varied_rule, 8)

    @test trial.inputs == [0, 1, -1, 1, 0, 1, -1, 1]

    @test isapprox(trial.states[1:5],
                  [1.0, 0.8, 1.14, 0.412, 0.8296];
                  rtol=1e-12, atol=1e-12)

    @test length(trial.states) == 9
end

# ╔═╡ 13265422-5807-4455-9d62-c13bb95004b0
md"""
## 1. Derivation — your attempt

1. Write aligned column definitions for ``X_-``, ``U_-``, and ``X_+``.
   Hand-check their first column using one short reference trajectory.
2. For which queries can ``Dg=q`` be solved? What condition permits every
   ``q\in\mathbb R^2``?
3. If several coefficient vectors reconstruct the same query, must their
   next-state predictions agree under the assumed dynamics? Justify your answer.
4. What directions can each input rule generate? What can adding more
   trajectory columns change?

**My derivation:** _To be completed before interpreting numerical results._
"""

# ╔═╡ 19d30531-ec11-4a37-af8b-bc424813e575
md"""
## 2. Construct the four datasets

Retain the same parameters and initial condition for both input rules.
For each rule, collect 100 transitions and use its first 20 transitions for
the shorter record.

| Input rule | Horizons |
|:--|:--|
| Fixed feedback ``u_k=-x_k`` | 20 and 100 |
| Periodic input `(0, 1, -1, 1)` via `varied_rule` | 20 and 100 |

Reuse `simulate_scalar`. Assemble the aligned data matrices from its returned
states and inputs; check their shapes and indexing before continuing.
"""

# ╔═╡ 7fdc65c6-5799-4ce0-9c93-fd2842a84b07
begin
    # TODO: generate the trajectories, select matching prefixes, and form the data.
    nothing
end

# ╔═╡ c42bff63-0216-4083-92dc-d69e513e7b6e
md"""
## 3. Rank and singular values

For each dataset, report both singular values and their normalized values
``\sigma_i/\sigma_1``. If ``\sigma_1=0``, report numerical rank zero and
mark the normalized values undefined.

Use the fixed relative SVD cutoff `1e-12`: count singular values strictly
larger than ``10^{-12}\sigma_1``. Use the same cutoff for reconstruction
when discarding singular directions. Keep this numerical classification
distinct from the exact condition in your derivation; flag borderline cases
without changing the cutoff after seeing results.
"""

# ╔═╡ b892fb2e-9cc5-4612-ae66-13c78d442e7c
begin
    # TODO: compute the singular-value diagnostics and numerical rank.
    nothing
end

# ╔═╡ cbbf7c35-954b-4bdd-a96a-aed3903c293b
md"""
## 4. Reconstruct queries and predict their successors

Use the same nonzero queries in all four cases:
``[1,0]^{\mathsf T}``, ``[0,1]^{\mathsf T}``, and
``[1,-1]^{\mathsf T}``. Check the zero query separately as a sanity case.

For a nonzero query, report the relative reconstruction residual
``\lVert Dg-q\rVert_2/\lVert q\rVert_2``. For zero, report the absolute
residual. Choose and record a reconstruction acceptance rule **before**
evaluating outcomes, and keep it fixed across the comparison.

**Reconstruction acceptance rule:** _To be chosen before running the comparison._

Retain failed reconstructions and label their queries unsupported. Interpret
``X_+g`` as a prediction for the requested pair only after checking its
reconstruction. For supported queries, compare with the independent simulator
value ``a x+b u`` and report absolute prediction error.
"""

# ╔═╡ 8613a927-242f-477e-89c3-39c4c4105b53
begin
    # TODO: attempt query reconstruction, record residuals, and validate predictions.
    nothing
end

# ╔═╡ f4c78439-4ec2-4018-a87a-cb69c6e9295c
md"""
## 5. Independent validation

- Hand-calculate an aligned data column and a supported query prediction.
- Check state/input lengths, matrix dimensions, and the scalar recurrence.
- Check that the 20-transition datasets match the longer trajectory prefixes.
- Preserve unsupported queries and any failed checks.

Record the commands or cells actually executed, their outcomes, tolerances,
and limits. The existing short references validate the simulator; the new
checks must also address data alignment and reconstruction/prediction.

**Validation outcomes:** _Pending your implementation._
"""

# ╔═╡ 0912470d-cfd2-4443-b287-dd01e25dd789
begin
    # TODO: add independent checks after making your hand calculations.
    nothing
end

# ╔═╡ dc76cd81-47c3-417a-a250-4967aec74dc4
md"""
## 6. Results and interpretation

Summarize all four cases together. Include rank, raw and normalized singular
values, and per-query reconstruction status, residual, and supported prediction
error. A table is sufficient; add a GLMakie visualization if it helps interpretation.

**Results:** _Not yet computed._

**Interpretation:** _What changed with record length? What changed with the input
rule? Do the derivation and numerical evidence support the same answer to the
question about missing directions? Distinguish finite query checks from a claim
about every state–input pair._

**Completion checkpoint:** _After validating and interpreting the comparison,
summarize the findings and limitations in the experiment record. Propose further
extraction only if a new notebook helper proves reusable._
"""

# ╔═╡ Cell order:
# ╟─d7210637-d620-46e7-a2c3-37fca16c7201
# ╠═8339dfbe-c98d-11f1-af7f-d9be02cc3632
# ╟─74b06145-3970-4d3e-96d5-2046121ff1c4
# ╟─f754b5e7-e74c-46cb-b221-14c95d125e25
# ╠═8a5b6550-e227-47f5-aba6-b631a7c66162
# ╠═4627f426-dc5c-43eb-a657-11aa5ad95a26
# ╠═9d15864f-b8b9-434c-9bde-b1b7d3b8a489
# ╠═99d9fd65-e9fb-4dbb-9c66-f736545645df
# ╠═fa7ed1fe-d177-4db1-84e7-3676aaf79534
# ╟─13265422-5807-4455-9d62-c13bb95004b0
# ╟─19d30531-ec11-4a37-af8b-bc424813e575
# ╠═7fdc65c6-5799-4ce0-9c93-fd2842a84b07
# ╟─c42bff63-0216-4083-92dc-d69e513e7b6e
# ╠═b892fb2e-9cc5-4612-ae66-13c78d442e7c
# ╟─cbbf7c35-954b-4bdd-a96a-aed3903c293b
# ╠═8613a927-242f-477e-89c3-39c4c4105b53
# ╟─f4c78439-4ec2-4018-a87a-cb69c6e9295c
# ╠═0912470d-cfd2-4443-b287-dd01e25dd789
# ╟─dc76cd81-47c3-417a-a250-4967aec74dc4
