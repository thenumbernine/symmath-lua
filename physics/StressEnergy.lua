return {
	--[[
	args:
		F = (optional) Faraday tensor
		index = (optional) index to get metric and inverse from.
		g, gU = (optional) manual metric and inverse

	TODO how to use the default coordinate basis?
	--]]
	EM = function(args)
		args = args or {}
		local basis = args.index and Tensor.metric(nil, nil, args.index)
		local F = args.F or var'F'
		local g = args.g or (basis and basis.metric) or var'g'
		local gU = args.gU or (basis and basis.metricInverse) or var'g'
		local symmath = require 'symmath'
		local frac = symmath.frac
		local pi = symmath.pi
		return frac(1, 4 * pi) * (F'_ac' * F'_bd'
			- frac(1, 4) * g'_ab' * F'_ce' * F'_df' * gU'^ef') * gU'^cd'
	end,
}
