@testset "Fixed-feedback reference" begin
    trial = simulate_scalar(0.8, 0.5, 1.0, (k, x) -> -x, 4)

    @test isapprox(trial.states,
                  [1.0, 0.3, 0.09, 0.027, 0.0081];
                  rtol=1e-12, atol=1e-12)

    @test isapprox(trial.inputs,
                  [-1.0, -0.3, -0.09, -0.027];
                  rtol=1e-12, atol=1e-12)
end

@testset "Varied input reference" begin
    pattern = (0, 1, -1, 1)
    rule = (k, x) -> pattern[mod(k, length(pattern)) + 1]
    trial = simulate_scalar(0.8, 0.5, 1.0, rule, 8)

    @test trial.inputs == [0, 1, -1, 1, 0, 1, -1, 1]

    @test isapprox(trial.states[1:5],
                  [1.0, 0.8, 1.14, 0.412, 0.8296];
                  rtol=1e-12, atol=1e-12)

    @test length(trial.states) == 9
end
