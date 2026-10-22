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

    using DataDrivenControl, Test
end

# ╔═╡ 0ff62bf8-5a88-42cf-872d-54b38050ce94
function simulate(A, B, C, D, initial_state, rule, T)
	x₀ = initial_state
	n = length(x₀)
	m = size(B)[1]

	x = zeros(n, T + 1)
	y = zeros(T)
	u = zeros(T)

	x[:, 1] = x₀

	for k in 1:T
		xk = view(x, :, k)
		u[k] = rule(k - 1, xk)
		x[:, k + 1] = A*x[:, k] + B*u[k]
		y[k] = (C*x[:, k])[1]
	end
	
	(states=x, inputs=u, outputs=y)
end

# ╔═╡ 977ba3c4-de2b-49f4-865d-767fb784d804
function varied_rule(k, x)
        u = [1, 0, -1, 0]
        idx = mod(k, length(u)) + 1
        u[idx]
end

# ╔═╡ bfb282ee-0d93-4f46-b0dc-2cbd3419b06d


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
@testset "Initial condition's effect" begin
    trial1 = simulate(A, B, C, D, [0.0, 0.0], varied_rule, 4)
    trial2 = simulate(A, B, C, D, [0.0, 1.0], varied_rule, 4)
    
    @test isapprox(trial1.states[:, 2:3],
                  [0.0 0.2; 1.0 0.6];
                  rtol=1e-12, atol=1e-12)
    @test isapprox(trial2.states[:, 2:3],
                  [0.2 0.48; 1.6 0.96];
                  rtol=1e-12, atol=1e-12)

    @test isapprox(trial1.inputs,
                  [1.0, 0.0, -1.0, 0.0];
                  rtol=1e-12, atol=1e-12)
    @test isapprox(trial1.outputs[1:3],
                  [0.0, 0.0, 0.2];
                  rtol=1e-12, atol=1e-12)
    @test isapprox(trial2.outputs[1:3],
                  [0.0, 0.2, 0.48];
                  rtol=1e-12, atol=1e-12)
end

# ╔═╡ Cell order:
# ╠═7f4af9ba-cdc8-11f1-baa6-118cd4bddcbd
# ╠═0ff62bf8-5a88-42cf-872d-54b38050ce94
# ╠═977ba3c4-de2b-49f4-865d-767fb784d804
# ╠═bfb282ee-0d93-4f46-b0dc-2cbd3419b06d
# ╠═ec17b36a-a889-49ed-a508-ee9575312b32
# ╠═65508e8f-4d0c-4843-9b30-019eada5979b
# ╠═b64fed71-601d-4152-b3f3-78e0bf9c0489
# ╠═564b463d-723f-40c4-b6ca-26656dffd737
# ╠═9471c77d-97ad-4837-a2a5-3502f12fba19
# ╠═ef8eb29f-fd66-4642-8517-f29733848d3c
# ╠═cb2a2c2c-3ae9-4138-9f25-257182e8c8a8
# ╠═72af1a21-9e31-4f44-a209-608c4ea158fe
# ╠═6d326eba-127d-482b-9834-5eba0636bcff
# ╠═e98dd4ab-5b07-4046-9807-ad11a512cccf
