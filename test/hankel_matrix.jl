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

# select the run, aligned samples, and depth; enter your hand reference.
a, b, c, d = (0.8, 0.5, 1.0, 0)
T = 6
L = 3

A1 = reshape([a], 1, 1)
B1 = [b]
C1 = reshape([c], 1, 1)
x0 = [1.0]
pattern = [0, 1, -1, 1]
res1 = simulate(A1, B1, C1, [d], x0, (k, x) -> varied_rule(k, x, pattern), T)

Hu = hankel_matrix(res1.inputs, L)
Hy = hankel_matrix(res1.outputs, L)
H = vcat(Hu, Hy)

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