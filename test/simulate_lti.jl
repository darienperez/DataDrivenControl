@testset "Initial condition's effect" begin
    A = [0.8 0.2; 0 0.6]
    B = [0.0; 1.0]
    C = [1.0 0.0]
    D = 0.0

    function varied_rule(k, x)
        u = [1, 0, -1, 0]
        idx = mod(k, length(u)) + 1
        u[idx]
    end

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

@testset "SISO callback, storage, and independent references" begin
    callback_indices = Int[]
    feedback = function (k, x)
        push!(callback_indices, k)
        return -x[1]
    end

    # Scalar state represented as a one-element vector. By hand, feedback
    # gives x[k+1] = 0.3*x[k]; y[k] = 2*x[k] is sampled before the update.
    trial = simulate(reshape([0.8], 1, 1), [0.5], reshape([2.0], 1, 1),
                     0.0, [1.0], feedback, 3)

    @test callback_indices == [0, 1, 2]
    @test (size(trial.states), size(trial.inputs), size(trial.outputs)) ==
          ((1, 4), (3,), (3,))
    @test isapprox(trial.states,
                   [1.0 0.3 0.09 0.027];
                   rtol=1e-12, atol=1e-12)
    @test isapprox(trial.inputs,
                   [-1.0, -0.3, -0.09];
                   rtol=1e-12, atol=1e-12)
    @test isapprox(trial.outputs,
                   [2.0, 0.6, 0.18];
                   rtol=1e-12, atol=1e-12)

    # With zero initial state and the supplied zero-input callback, the
    # origin remains invariant. This also checks that no other rule is used.
    zero_trial = simulate([0.8 0.2; 0 0.6], [0.0; 1.0], [1.0 0.0],
                          0.0, [0.0, 0.0], (k, x) -> 0.0, 4)

    @test (size(zero_trial.states), size(zero_trial.inputs),
           size(zero_trial.outputs)) == ((2, 5), (4,), (4,))
    @test zero_trial.states == zeros(2, 5)
    @test zero_trial.inputs == zeros(4)
    @test zero_trial.outputs == zeros(4)
end
