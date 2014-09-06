require 'ext'
require 'symmath'

-- functions

function sum(f,first,last,step)
	step = step or 1
	local total
	for i=first,last,step do
		if not total then 
			total = f(i)
		else
			total = total + f(i)
		end
	end
	return total
end

-- variables

do
	local varNames = 'x y z t rho vx vy vz p P Z E Bx By Bz gamma mu c cs cf ca'
	print('variables:', varNames)
	for _,var in ipairs(varNames:split('%s+')) do
		_G[var] = symmath.Variable(var, nil, true)
	end
end

local vs = table{vx, vy, vz}
local Bs = table{Bx, By, Bz}
local xs = table{x,y,z}

local vDotB = sum(function(i) return vs[i] * Bs[i] end, 1, 3)
local divB = sum(function(i) return symmath.diff(Bs[i], xs[i]) end, 1, 3)
local BSq = sum(function(i) return Bs[i] * Bs[i] end, 1, 3)
local vSq = sum(function(i) return vs[i] * vs[i] end, 1, 3)

-- relations

print('relations')

local Z_from_E_B_rho_mu = symmath.equals(Z, E + BSq / (2 * rho * mu))
print(Z_from_E_B_rho_mu)

local P_from_p_B_mu = symmath.equals(P, p + BSq / (2 * mu))
print(P_from_p_B_mu)

local p_from_E_rho_v_gamma = symmath.equals(p, (gamma - 1) * rho * (E - vSq / 2))
print(p_from_E_rho_v_gamma)

local cSq_from_p_rho_gamma = symmath.equals(c^2, gamma * p / rho)
print(cSq_from_p_rho_gamma)

-- equations

local continuityEqn = symmath.equals(symmath.diff(rho, t) + sum(function(j) 
	return symmath.diff(rho*vs[j], xs[j])
end,1,3), 0)

print()
print('continuity')
print(continuityEqn)

local momentumEqns = range(3):map(function(i)
	return symmath.equals(
		symmath.diff(rho * vs[i], t) + sum(function(j)
			return symmath.diff(rho * vs[i] * vs[j] - Bs[i] * Bs[j] / mu, xs[j])
		end, 1,3)
		+ symmath.diff(P, xs[i]),
		-- ... equals ...
		-Bs[i] / mu * divB)
end)

print()
print('momentum')
momentumEqns:map(function(eqn) print(eqn) end)

local magneticFieldEqns = range(3):map(function(i)
	return symmath.equals(
		symmath.diff(Bs[i], t) + sum(function(j)
			return symmath.diff(vs[j] * Bs[i] - vs[i] * Bs[j], xs[j])
		end, 1,3),
		-- ... equals ...
		-vs[i] * divB)
end)

print()
print('magnetic field')
magneticFieldEqns:map(function(eqn) print(eqn) end)

local energyTotalEqn = symmath.equals(
	symmath.diff(rho * Z, t) + sum(function(j)
		return (rho * Z + p) * vs[j] - vDotB * Bs[j] / mu
	end, 1, 3),
	-- ... equals ...
	-vDotB/mu * divB)

print()
print('energy total')
print(energyTotalEqn)
