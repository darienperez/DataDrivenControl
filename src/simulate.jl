function simulate_scalar(a, b, x0, input_rule, T)
	x = zeros(T + 1)
	u = zeros(T)
	x[1] = x0
	for k in 1:T
		u[k] = input_rule(k - 1, x[k])
		x[k + 1] = a*x[k] + b*u[k]
	end
	return (states=x, inputs=u)
end
