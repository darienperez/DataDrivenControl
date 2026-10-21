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

# ╔═╡ Cell order:
# ╠═8339dfbe-c98d-11f1-af7f-d9be02cc3632
# ╠═8a5b6550-e227-47f5-aba6-b631a7c66162
# ╠═4627f426-dc5c-43eb-a657-11aa5ad95a26
# ╠═9d15864f-b8b9-434c-9bde-b1b7d3b8a489
# ╠═99d9fd65-e9fb-4dbb-9c66-f736545645df
# ╠═fa7ed1fe-d177-4db1-84e7-3676aaf79534
