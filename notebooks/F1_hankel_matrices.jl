### A Pluto.jl notebook ###
# v1.0.4

using Markdown
using InteractiveUtils

# ╔═╡ 1ad29f53-cc2d-42bf-aa24-a056de538aa1
begin
    using Pkg

    # Use the repository's shared Julia project.
    project_dir = normpath(joinpath(@__DIR__, ".."))
    Pkg.activate(project_dir)
    Pkg.instantiate()

    using DataDrivenControl, Test
end

# ╔═╡ e3e5a974-8b2c-4851-817d-eec7ac3cfb4b
md"""
# F1: hand and Julia Hankel matrices

Compare the hand-built input/output Hankel example with the Julia construction,
including dimensions, column order, and sample alignment. The saved checks below
verify this finite example against independent hand references.

The one-state example uses noise-free dynamics and measured output

```math
\begin{aligned}
x_{k+1} &= a x_k + b u_k,\\
y_k &= c x_k.
\end{aligned}
```

Here ``a=0.8``, ``b=0.5``, ``c=1``, ``d=0``, and ``x_0=1``.
It uses the package simulator, ``T=6`` transitions, window depth ``L=3``,
and the periodic input pattern ``(0,1,-1,1)``.
The original two-state benchmark remains in `F1_CC_benchmark.jl`.

Recorded inputs and outputs cover ``k=0,\ldots,5``, while simulator states
cover ``k=0,\ldots,6``. Julia index ``k+1`` corresponds to mathematical time
``k``. Use matching input/output windows and keep simulator states separate
from measured output data. The hand record assigns no physical units or sampling
interval; ``k`` indexes discrete samples.

**Completed numerical checkpoint:** the hand and Julia matrices agree with
``\mathrm{rtol}=\mathrm{atol}=10^{-12}``. Exact floating-point equality is
unnecessary for this comparison; the observed discrepancy is discussed below.
"""

# ╔═╡ bfb282ee-0d93-4f46-b0dc-2cbd3419b06d
function varied_rule(k, x, pattern)
        u = pattern
        idx = mod(k, length(u)) + 1
        u[idx]
end

# ╔═╡ 5fbc865b-3573-4f14-8f48-1093c2b72cc2
begin
    # Fixed scalar run, aligned samples, and window depth.
    a, b, c, d = (0.8, 0.5, 1.0, 0)
    T = 6
    L = 3

    A1 = reshape([a], 1, 1)
    B1 = [b]
    C1 = reshape([c], 1, 1)
    x0 = [1.0]
    pattern = [0, 1, -1, 1]
    res1 = simulate(A1, B1, C1, [d], x0, (k, x) -> varied_rule(k, x, pattern), T)
end

# ╔═╡ d3f29046-210c-4cc9-9c16-3453ada83ebd
md"""
## Completed hand reference

Source: your `F6_F1_Progress_Record_2026-10-27.pdf`, section 3 on page 2;
model assumptions are in section 2 on page 1. These reference values were
transcribed from that record, independently of the simulator and your
Hankel constructor.

The corrected sample is ``y_4=0.8296``; ``y_5=0.66368`` is retained without
further rounding. The ``N=6`` recorded input/output pairs are

```math
\begin{aligned}
u_{0:5} &= \begin{bmatrix}
0 & 1 & -1 & 1 & 0 & 1
\end{bmatrix},\\
y_{0:5} &= \begin{bmatrix}
1 & 0.8 & 1.14 & 0.412 & 0.8296 & 0.66368
\end{bmatrix}.
\end{aligned}
```

For depth ``L=3``, the block dimensions are

```math
L \times (N-L+1) = 3 \times 4.
```

```math
H_3(u) =
\begin{bmatrix}
0 & 1 & -1 & 1 \\
1 & -1 & 1 & 0 \\
-1 & 1 & 0 & 1
\end{bmatrix}
\in \mathbb{R}^{3\times4}.
```

```math
H_3(y) =
\begin{bmatrix}
1 & 0.8 & 1.14 & 0.412 \\
0.8 & 1.14 & 0.412 & 0.8296 \\
1.14 & 0.412 & 0.8296 & 0.66368
\end{bmatrix}
\in \mathbb{R}^{3\times4}.
```

The combined matrix places the three input rows before the three output rows:

```math
H =
\begin{bmatrix} H_3(u) \\ H_3(y) \end{bmatrix}
=
\begin{bmatrix}
0 & 1 & -1 & 1 \\
1 & -1 & 1 & 0 \\
-1 & 1 & 0 & 1 \\
1 & 0.8 & 1.14 & 0.412 \\
0.8 & 1.14 & 0.412 & 0.8296 \\
1.14 & 0.412 & 0.8296 & 0.66368
\end{bmatrix}
\in \mathbb{R}^{6\times4}.
```

| Julia column | Mathematical time window |
|:--|:--|
| 1 | ``k=0{:}2`` |
| 2 | ``k=1{:}3`` |
| 3 | ``k=2{:}4`` |
| 4 | ``k=3{:}5`` |

Each column is one finite, time-aligned input/output trajectory segment.
For this scalar example, ``u_k`` influences ``x_{k+1}`` and ``y_{k+1}``,
rather than ``y_k`` directly. Keep input and output windows at the same start
time; their causal history is represented within the trajectory. A column of
``H`` is distinct from the single state-input pair represented by a column
of ``D`` in Experiment 001.

This hand construction does not establish a general trajectory-spanning or
persistent-excitation claim.
"""

# ╔═╡ c1e62a0b-06eb-44e2-918b-70d9663762bf
begin
    # Literal hand references from PDF page 2; do not derive them from res1
    # or hankel_matrix, so they remain independent comparison targets.
    hand_u = [0.0, 1.0, -1.0, 1.0, 0.0, 1.0]
    hand_y = [1.0, 0.8, 1.14, 0.412, 0.8296, 0.66368]

    hand_Hu = [
         0.0  1.0 -1.0  1.0
         1.0 -1.0  1.0  0.0
        -1.0  1.0  0.0  1.0
    ]
    hand_Hy = [
        1.0  0.8   1.14   0.412
        0.8  1.14  0.412  0.8296
        1.14 0.412 0.8296 0.66368
    ]
    hand_H = [
         0.0  1.0  -1.0     1.0
         1.0 -1.0   1.0     0.0
        -1.0  1.0   0.0     1.0
         1.0  0.8   1.14    0.412
         0.8  1.14  0.412   0.8296
         1.14 0.412 0.8296  0.66368
    ]

    (inputs=hand_u, outputs=hand_y,
     input_block=hand_Hu, output_block=hand_Hy, stacked=hand_H)
end

# ╔═╡ 11ac5983-cb17-4b82-98f1-7562aa59fcdd
md"""
### Construct the matrices

For this example, column ``j`` contains Julia samples ``j:j+L-1``. Construct
``H_3(u)`` and ``H_3(y)`` with matching windows, then stack input rows before
output rows. The constructor stays notebook-local; a reusable depth contract
and package extraction are deferred until broader use is needed.
"""

# ╔═╡ 8658ce82-6c30-4e82-82cf-86cff3bb551d
begin
    # Notebook-local construction for the fixed depth L = 3.

    function hankel_matrix(data::AbstractVector, L::Int)
        T = length(data)
        N = T - L + 1

        H = zeros(eltype(data), L, N)
        for j in 1:N
            H[:, j] = data[j:(j + L - 1)]
        end
        return H
    end

	Hu = hankel_matrix(res1.inputs, L)
	Hy = hankel_matrix(res1.outputs, L)
	H = vcat(Hu, Hy)
end

# ╔═╡ 8decf3be-6061-4210-8742-64b6ab6c8892
Hu

# ╔═╡ fafff0e2-bb52-459c-98d9-e821d9561dfb
Hy

# ╔═╡ ee3e54ea-4822-49c4-9a64-be0bec124103
H

# ╔═╡ 485b8301-bc8b-44be-9ed8-252be3a1826b
md"""
### Compare with the hand calculation

The checks use the existing ``\mathrm{rtol}=\mathrm{atol}=10^{-12}`` for all
approximate comparisons. Both blocks are ``3\times4`` and the stacked matrix is
``6\times4``. All entries agree with the independent hand matrices, including
the first and last aligned trajectory windows.

The input block compares exactly equal. Exact equality fails for the output
and stacked blocks because of floating-point roundoff: the maximum absolute
discrepancy is ``2.220446049250313\times10^{-16}``. The data, hand references,
and tolerances were not changed to obtain agreement.

This completes the finite numerical comparison. It does not establish a
general trajectory-spanning or persistent-excitation result. The original
benchmark's initial-state difference derivation and behavior explanation remain
separate learning checkpoints.
"""

# ╔═╡ 71eb0dce-60db-41b0-9f86-f1f324ee43e1
@testset "Hankel matrix construction" begin
    @test size(Hu) == (3, 4)
    @test size(Hy) == (3, 4)
    @test size(H) == (6, 4)
    @test isapprox(res1.inputs, hand_u; rtol=1e-12, atol=1e-12)
    @test isapprox(res1.outputs, hand_y; rtol=1e-12, atol=1e-12)
    @test isapprox(Hu, hand_Hu; rtol=1e-12, atol=1e-12)
    @test isapprox(Hy, hand_Hy; rtol=1e-12, atol=1e-12)
    @test isapprox(H, hand_H; rtol=1e-12, atol=1e-12)
    @test isapprox(H[:, 1], [hand_u[1:3]; hand_y[1:3]];
                   rtol=1e-12, atol=1e-12)
    @test isapprox(H[:, end], [hand_u[4:6]; hand_y[4:6]];
                   rtol=1e-12, atol=1e-12)
end

# ╔═╡ a9c1c90d-bb83-47f9-a69b-e5d161e1b273
H

# ╔═╡ 0949a87a-0e3e-4a7e-94bd-4249851a9ed2
Hu

# ╔═╡ 693736b7-a2c0-4283-8eda-8c0bb611d9f8
Hy

# ╔═╡ Cell order:
# ╠═1ad29f53-cc2d-42bf-aa24-a056de538aa1
# ╟─e3e5a974-8b2c-4851-817d-eec7ac3cfb4b
# ╠═bfb282ee-0d93-4f46-b0dc-2cbd3419b06d
# ╠═5fbc865b-3573-4f14-8f48-1093c2b72cc2
# ╟─d3f29046-210c-4cc9-9c16-3453ada83ebd
# ╠═c1e62a0b-06eb-44e2-918b-70d9663762bf
# ╟─11ac5983-cb17-4b82-98f1-7562aa59fcdd
# ╠═8658ce82-6c30-4e82-82cf-86cff3bb551d
# ╠═8decf3be-6061-4210-8742-64b6ab6c8892
# ╠═fafff0e2-bb52-459c-98d9-e821d9561dfb
# ╠═ee3e54ea-4822-49c4-9a64-be0bec124103
# ╟─485b8301-bc8b-44be-9ed8-252be3a1826b
# ╠═71eb0dce-60db-41b0-9f86-f1f324ee43e1
# ╠═a9c1c90d-bb83-47f9-a69b-e5d161e1b273
# ╠═0949a87a-0e3e-4a7e-94bd-4249851a9ed2
# ╠═693736b7-a2c0-4283-8eda-8c0bb611d9f8
