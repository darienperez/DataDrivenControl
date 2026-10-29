"""
    simulate(A, B, C, D, initial_state, rule, T)

Simulate T transitions of x[k+1] = A*x[k] + B*u[k], recording y[k] = C*x[k].
The current implementation uses vector states, scalar inputs and outputs,
and Float64 history storage.

For n states, use an n-by-n matrix A, a length-n vector B, a 1-by-n matrix C,
a length-n initial_state vector, and a nonnegative integer T. A one-state
system uses the same matrix/vector representation with n = 1.

The callback rule(k, xk) receives zero-based sample index k and a view of the
current state vector; it must return a scalar input. Treat that view as
read-only: mutating it changes the stored state history.

Return a named tuple:

- states: n-by-(T+1) matrix, containing x[0] through x[T];
- inputs: length-T vector, containing u[0] through u[T-1];
- outputs: length-T vector, containing y[0] through y[T-1].

D is retained for compatibility with the existing calls but is currently
ignored: the output equation has no direct-feedthrough term. Sampling time
and physical units are specified by the caller; k counts discrete samples.
"""
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
