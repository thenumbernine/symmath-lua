require 'symmath'
require 'ext'

symmath.toStringMethod = symmath.ToMultiLineString
symmath.simplifyConstantPowers  = true

-- primitive variables
local rho = symmath.variable('rho', nil, true)	-- density
local u = symmath.variable('u', nil, true)		-- velocity
local v = symmath.variable('v', nil, true)
local w = symmath.variable('w', nil, true)
local e = symmath.variable('e', nil, true)		-- total specific energy 

-- state variable
local q1 = symmath.variable('q1', nil, true)
local q2 = symmath.variable('q2', nil, true)
local q3 = symmath.variable('q3', nil, true)
local q4 = symmath.variable('q4', nil, true)
local q5 = symmath.variable('q5', nil, true)

-- dimension variables
local t = symmath.variable('t', nil, true)
local x = symmath.variable('x', nil, true)
local y = symmath.variable('y', nil, true)
local z = symmath.variable('z', nil, true)

local gamma = symmath.variable('gamma')
local ek = .5 * (u * u + v * v + w * w)			-- kinetic specific energy
local ei = e - .5 * ek							-- internal specific energy
local P = (gamma - 1) * rho * ei				-- pressure
local E = rho * e								-- total energy

local function printEqn(eqn)
	print('  '..eqn..' = 0') 
end

-- TODO
function symmath.equals(x) return x end

-- ...equal zero
print('original equations:')
local diff = symmath.diff
local eqns = table{
	symmath.equals(diff(rho    , t) + diff(rho * u        , x) + diff(rho * v        , y) + diff(rho * w        , z), 0),
	symmath.equals(diff(rho * u, t) + diff(rho * u * u + P, x) + diff(rho * u * v    , y) + diff(rho * u * w    , z), 0),
	symmath.equals(diff(rho * v, t) + diff(rho * v * u    , x) + diff(rho * v * v + P, y) + diff(rho * v * w    , z), 0),
	symmath.equals(diff(rho * w, t) + diff(rho * w * u    , x) + diff(rho * w * v    , y) + diff(rho * w * w + P, z), 0),
	symmath.equals(diff(rho * e, t) + diff((E + P) * u    , x) + diff((E + P) * v    , y) + diff((E + P) * w    , z), 0),
}
eqns:map(printEqn)

print('substituting state variables:')
eqns = eqns:map(function(eqn)
	eqn = symmath.replace(eqn, rho, q1)
	eqn = symmath.replace(eqn, u, q2 / q1)
	eqn = symmath.replace(eqn, v, q3 / q1)
	eqn = symmath.replace(eqn, w, q4 / q1)
	eqn = symmath.replace(eqn, e, q5 / q1)
	--eqn = symmath.simplify(eqn)
	return eqn
end)
eqns:map(printEqn)

print('simplify & expand')
eqns = eqns:map(symmath.simplify)
eqns:map(printEqn)

print('factor derivatives')
eqns = eqns:factor(function(eqn)
	return eqn:factor{symmath.diff(q1, x), symmath.diff(q2, x), symmath.diff(q3, x)}
end)

-- ... factor?  provide a list of expressions to factor by ... to get our matrix?
