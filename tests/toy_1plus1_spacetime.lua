#!/usr/bin/env luajit

--[[
math for Alcubierre's "Introduction to 3+1 Numerical Relativity" (http://www.amazon.com/Introduction-Numerical-Relativity-International-Monographs/dp/0199656150)
and "The appearance of coordinate shocks in hyperbolic formalisms of General Relativity" (http://arxiv.org/pdf/gr-qc/9609015v2.pdf) 
--]]

symmath = require 'symmath'
symmath.tostring = require 'symmath.tostring.SingleLine'

local x = symmath.var'x'
local t = symmath.var('h', {x})
local xs = table{t,x}

local r = symmath.Tensor(xs):transpose()

local e_t = r:diff(t):simplify()
print('e_t^u = '..e_t)
local e_x = r:diff(x):simplify()
print('e_x^u = '..e_x)
local e = symmath.Matrix(e_t:transpose()[1], e_x:transpose()[1]):transpose()	-- e vectors as columns, so stored e[u][a] = e_a^u
print('e_a^u = '..e)

local eta = symmath.Matrix({-1,0},{0,1})
print('eta = '..eta)

local gLL = (e:transpose() * eta * e):simplify()
print('g_uv = '..gLL)

-- [[ ...and out of nowhere, force betas to be zero
gLL[1][2] = symmath.Constant(0)
gLL[2][1] = symmath.Constant(0)
print('gLL = '..gLL)
--]]

local gUU = gLL:inverse()
print('g^uv = '..gUU)

-- [[ simply solve for any unit vector ...
local nUt = symmath.var'n^t'
local nUx = symmath.var'n^x'
local nU = symmath.Tensor{nUt, nUx}:transpose()
print('n^u = '..nU)

local n_dot_e_x = (nU:transpose() * gLL * e_x):simplify()[1][1]:equals(0)
print('n dot e_x = 0 : '..n_dot_e_x)

local nUt_from_nUx = n_dot_e_x:solve(nUt)
print('n^t from n^x : '..nUt_from_nUx)

local n_norm = (nU:transpose() * gLL * nU):simplify()[1][1]:equals(-1)
print('n dot n = -1 : '..n_norm)
local n_norm_from_nUx = n_norm:subst(nUt_from_nUx):simplify()
print(n_norm_from_nUx)
local nUx_solns = table{n_norm_from_nUx:solve(nUx)}
print('n^x solutions:')
print(nUx_solns:map(function(eqn) return '\t'..eqn end):concat('\n'))
print("solving the first one first (keep note that they're plus or minus...")
local nUx_soln = nUx_solns[1]
print('n^x is  ',nUx_soln:rhs())
-- (-d/{dx}[h] sqrt(4 + 8 (d/{dx}[h])^4 - 12 (d/{dx}[h])^2)) / (-2 - 4 (d/{dx}[h])^4 + 6 (d/{dx}[h])^2)
local cmp = (-t:diff(x) * symmath.sqrt(4 + 8 * t:diff(x)^4 - 12 * t:diff(x)^2)) / (-2 - 4 * t:diff(x)^4 + 6 * t:diff(x)^2)
print('should be',cmp)
-- assert we're here.  I'm going to simplify this by hand since I don't have a good polynomial factoring algorithm ...
assert((nUx_soln:rhs() - cmp):simplify() == symmath.Constant(0))
-- h' / sqrt((1 - h'^2)*(1 - 2 h'^2))
local nUx_soln = nUx:equals(t:diff(x) / symmath.sqrt((1 - t:diff(x)^2)*(1 - 2*t:diff(x)^2)))
print('rewritten by hand : '..nUx_soln)
local nUt_soln = nUt_from_nUx:subst(nUx_soln):simplify()	-- also plus or minus, since n^t is scaled by n^x
print('n^t solutions:')
print('\t'..nUt_soln)
print('\t'..nUt:equals((-nUt_soln:rhs()):simplify()))
-- once again, polynomial simplification ...
-- (-1 + (d/{dx}[h])^2) / (-sqrt(1 - 3 (d/{dx}[h])^2 + 2 (d/{dx}[h])^4))
local cmp = (-1 + t:diff(x)^2) / (-symmath.sqrt(1 - 3 * t:diff(x)^2 + 2 * t:diff(x)^4))
print('should be',cmp)
assert((nUt_soln:rhs() - cmp):simplify() == symmath.Constant(0))
-- (1 - h'^2) / sqrt((1 - h'^2)*(1 - 2 h'^2))
-- (1 - h'^2) / (sqrt(1 - h'^2)*sqrt(1 - 2 h'^2))
local nUt_soln = nUt:equals(symmath.sqrt((1 - t:diff(x)^2) / (1 - 2 * t:diff(x)^2)))
print(nUt_soln)

local nU = symmath.Tensor({nUt_soln:rhs()}, {nUx_soln:rhs()})
print('n^u = '..nU)

local n_dot_e_x = (nU:transpose() * gLL * e_x):simplify()[1][1]:equals(0)
print('n dot e_x = 0')
print(n_dot_e_x)

local n_norm = (nU:transpose() * gLL * nU):simplify()[1][1]:equals(-1)
print('n dot n = -1')
print(n_norm)
-- and once again, polynomial division would show this to be true ...

-- connection coefficients
local connLLL = symmath.Tensor(xs:map(function(xi,i) 
	return xs:map(function(xj,j) 
		return xs:map(function(xk,k) 
			return ((gLL[i][j]:diff(xk) + gLL[i][k]:diff(xj) - gLL[j][k]:diff(xi))/2):simplify()
		end)
	end)
end):unpack())
print('conn_ijk = '..connLLL)

local connULL = symmath.Tensor(xs:map(function(_,i) 
	return xs:map(function(_,j) 
		return xs:map(function(_,k) 
			local sum = 0
			for l=1,#xs do
				sum = sum + gUU[i][l] * connLLL[l][j][k]
			end
			return sum:simplify()
		end)
	end)
end):unpack())
print('conn^i_jk = '..connULL)

local nL = (gLL * nU):simplify()
print('n_u = '..nL)

local partialL_nL = symmath.Tensor(xs:map(function(xu,u)
	return xs:map(function(xv,v)
		return nL[v][1]:diff(xu):simplify()
	end)
end):unpack())
print('partial_u n_v = '..partialL_nL)

local diffL_nL = symmath.Tensor(xs:map(function(xu,u)
	return xs:map(function(xv,v)
		local sum = 0
		for w,xw in ipairs(xs) do
			sum = sum + connULL[w][v][u] * nL[w][1]
		end
		return (partialL_nL[u][v] - sum):simplify()
	end)
end):unpack())
print('diff_u n_v = '..diffL_nL)

local deltaUL = (eta * eta):simplify()
print('delta^u_v = '..deltaUL)

local PUL = (deltaUL + nU * nL:transpose()):simplify()
--[[ explicitly force extrinsic projection values to zero?
PUL[1][2] = symmath.Constant(0)
PUL[2][1] = symmath.Constant(0)
--]]
print('proj = P^u_v = '..PUL)

local proj_diffL_nL = (PUL:transpose() * diffL_nL * PUL):simplify()
print('proj diff_u n_v = '..proj_diffL_nL)

local KLL = (-(proj_diffL_nL + proj_diffL_nL:transpose())/2):simplify()
print('K_uv = '..KLL)

local KLL = (-(diffL_nL + nL * nU:transpose() * diffL_nL)):simplify()
print('K_uv = '..KLL)

local KUL = (gUU * KLL):simplify()
print('K^u_v = '..KUL)

local K = (KUL[1][1] + KUL[2][2]):simplify()
print('K = '..K)
-- ... so where did K = -h'' / sqrt(g_xx) = -h'' / sqrt(1 - h'^2) come from?
-- maybe with a different choice of n?
