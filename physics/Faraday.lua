--[[
creates the Faraday tensor
using equations 2.24 through 2.28 of "The Einstein-Maxwell system in 3+1 form and initial data for multiple charged black holes"
and then tweaking signs to match "Gravitation" Misner Thorne & Wheeler eqn. 3.7
args:
	g = (optional) metric to use
	gU = (optional) metric inverse
	index = (optional) index to get the metric from
	n = (optional) hypersurface normal vector for observing electromagnetic field.  default n_a = (1,0,0,0)
	E = (optional) electric field.  default E_a = (0,E_x,E_y,E_z)
	B = (optional) magnetic field.  default B_a = (0,B_x,B_y,B_z)
--]]
return function(args)
	args = args or {}
	local var = require 'symmath.Variable'
	local Tensor = require 'symmath.Tensor'
	local sqrt = require 'symmath.sqrt'
	local abs = require 'symmath.abs'
	local basis = Tensor.metric(nil, nil, args.index)
	local g = args.g or basis.metric
	local gU = args.gU or basis.metricInverse
	local n = args.n or Tensor('_a', function(a) return a == 1 and 1 or 0 end)
	local LeviCivita = args.LeviCivita or require 'symmath.tensor.LeviCivita'(nil, sqrt(abs(Matrix.determinant(g))))
	local E = args.E or Tensor('_a', function(a) return a == 1 and 0 or var('E_{'..basis.variables[a].name..'}') end)
	local B = args.B or Tensor('_a', function(a) return a == 1 and 0 or var('B_{'..basis.variables[a].name..'}') end)
	local F = Tensor'_ab'
	F['_ab'] = (E'_a' * n'_b' - n'_a' * E'_b' - n'_e' * gU'^ed' * LeviCivita'_abdf' * gU'^fg' * B'_g')()
	return F
end
