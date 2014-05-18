require 'symmath'
require 'ext'

symmath.toStringMethod = symmath.ToSingleLineString
symmath.simplifyConstantPowers  = true

local rho = symmath.variable('rho', nil, true)
local u = symmath.variable('u', nil, true)
local e = symmath.variable('e', nil, true)	-- E = e * rho

local q1 = symmath.variable('q1', nil, true)
local q2 = symmath.variable('q2', nil, true)
local q3 = symmath.variable('q3', nil, true)

local t = symmath.variable('t', nil, true)
local x = symmath.variable('x', nil, true)

local gamma = symmath.variable('gamma')
local E = rho * e			--internal energy
local P = (gamma - 1) * (E - .5 * rho * u * u)

local function printEqn(eqn)
	print('  '..eqn..' = 0') 
end

-- ...equal zero
print('original equations:')
local eqns = table{
	symmath.diff(rho, t) + symmath.diff(rho * u, x),
	symmath.diff(rho * u, t) + symmath.diff(rho * u^2 + P, x),
	symmath.diff(rho * e, t) + symmath.diff((E + P) * u, x),
}
eqns:map(printEqn)

print('substituting state variables:')
eqns = eqns:map(function(eqn)
	eqn = symmath.replace(eqn, rho, q1)
	eqn = symmath.replace(eqn, u, q2 / q1)
	eqn = symmath.replace(eqn, e, q3 / q1)
	--eqn = symmath.simplify(eqn)
	return eqn
end)
eqns:map(printEqn)

print('simplify & expand')
eqns = eqns:map(symmath.simplify)
eqns:map(printEqn)

-- ... factor?  provide a list of expressions to factor by ... to get our matrix?
