using DataDrivenControl, LinearAlgebra, Test

# This checks the package and numerical setup, not a control algorithm.
@testset "Package and numerical smoke test" begin
    # Dimensionless 2 × 2 system with a hand-verifiable solution.
    M = [2.0 1.0; 1.0 3.0]
    b = [1.0, 2.0]
    @test isapprox(M \ b, [1/5, 3/5]; rtol=1e-12, atol=1e-12)
end
