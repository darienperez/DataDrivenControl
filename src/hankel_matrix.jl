function varied_rule(k, x, pattern)
        u = pattern
        idx = mod(k, length(u)) + 1
        u[idx]
end

function hankel_matrix(data::AbstractVector, L::Int)
    T = length(data)
    N = T - L + 1

    H = zeros(eltype(data), L, N)
    for j in 1:N
        H[:, j] = data[j:(j + L - 1)]
    end
    return H
end