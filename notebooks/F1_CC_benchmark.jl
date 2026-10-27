### A Pluto.jl notebook ###
# v1.0.4

using Markdown
using InteractiveUtils

# ╔═╡ 7f4af9ba-cdc8-11f1-baa6-118cd4bddcbd
begin
    using Pkg

    # The project is one directory above this notebook.
    project_dir = normpath(joinpath(@__DIR__, ".."))
    Pkg.activate(project_dir)
    Pkg.instantiate()

    using DataDrivenControl
end

# ╔═╡ 0ff62bf8-5a88-42cf-872d-54b38050ce94
md"""
## Shared simulator

This notebook uses DataDrivenControl.simulate from src/simulate_lti.jl.
The package contains the reusable implementation; the system parameters,
input rule, and initial-state comparison remain in this notebook.
The callback receives zero-based time and a state vector, and returns a scalar input.
"""

# ╔═╡ 977ba3c4-de2b-49f4-865d-767fb784d804
function varied_rule(k, x)
        u = [1, 0, -1, 0]
        idx = mod(k, length(u)) + 1
        u[idx]
end

# ╔═╡ ec17b36a-a889-49ed-a508-ee9575312b32
A = [0.8 0.2; 0 0.6]

# ╔═╡ 65508e8f-4d0c-4843-9b30-019eada5979b
B = [0.0; 1.0]

# ╔═╡ b64fed71-601d-4152-b3f3-78e0bf9c0489
C = [1.0 0.0]

# ╔═╡ 564b463d-723f-40c4-b6ca-26656dffd737
D = 0.0

# ╔═╡ 9471c77d-97ad-4837-a2a5-3502f12fba19
results1 = simulate(A, B, C, D, [0.0, 0.0], varied_rule , 8)

# ╔═╡ ef8eb29f-fd66-4642-8517-f29733848d3c
results2 = simulate(A, B, C, D, [0.0, 1.0], varied_rule , 8)

# ╔═╡ cb2a2c2c-3ae9-4138-9f25-257182e8c8a8
results1.outputs

# ╔═╡ 72af1a21-9e31-4f44-a209-608c4ea158fe
results1.outputs - results2.outputs

# ╔═╡ 6d326eba-127d-482b-9834-5eba0636bcff
results1

# ╔═╡ e98dd4ab-5b07-4046-9807-ad11a512cccf
md"""
## Simulator regression checks

The five hand-reference assertions have moved to test/simulate_lti.jl and
run through test/runtests.jl in the shared Julia project. Their reference
values and tolerances are unchanged.

The separate Hankel investigation is in notebooks/F1_hankel_matrices.jl.
"""

# ╔═╡ Cell order:
# ╠═7f4af9ba-cdc8-11f1-baa6-118cd4bddcbd
# ╟─0ff62bf8-5a88-42cf-872d-54b38050ce94
# ╠═977ba3c4-de2b-49f4-865d-767fb784d804
# ╠═ec17b36a-a889-49ed-a508-ee9575312b32
# ╠═65508e8f-4d0c-4843-9b30-019eada5979b
# ╠═b64fed71-601d-4152-b3f3-78e0bf9c0489
# ╠═564b463d-723f-40c4-b6ca-26656dffd737
# ╠═9471c77d-97ad-4837-a2a5-3502f12fba19
# ╠═ef8eb29f-fd66-4642-8517-f29733848d3c
# ╠═cb2a2c2c-3ae9-4138-9f25-257182e8c8a8
# ╠═72af1a21-9e31-4f44-a209-608c4ea158fe
# ╠═6d326eba-127d-482b-9834-5eba0636bcff
# ╟─e98dd4ab-5b07-4046-9807-ad11a512cccf
