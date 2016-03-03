#!/usr/bin/env luajit

--[[
math for Alcubierre's "Introduction to 3+1 Numerical Relativity" (http://www.amazon.com/Introduction-Numerical-Relativity-International-Monographs/dp/0199656150)
and "The appearance of coordinate shocks in hyperbolic formalisms of General Relativity" (http://arxiv.org/pdf/gr-qc/9609015v2.pdf) 
--]]

local symmath = require 'symmath'
local MathJax = require 'symmath.tostring.MathJax'
symmath.tostring = MathJax
print(MathJax.header)

local function printbr(...) print(...) print'<br>' end

local Tensor = symmath.Tensor
local var = symmath.var
local vars = symmath.vars

local x = var'x'
local t = var('h', {x})

local x0 = var'x0'
local x1 = var'x1'

Tensor.coords{
	{variables={t,x}},
	{variables={x0, x1}, symbols='IJKLMN'},
}

local r = Tensor('^I', t, x)
printbr(var'r''^I':eq(r'^I'()))

local e = Tensor'_u^I'
e['_u^I'] = r'^I_,u'()
printbr(var'e''_u^I':eq(e'_u^I'()))

local eta = symmath.Tensor('_IJ',{-1,0},{0,1})
printbr(var'\\eta''_IJ':eq(eta'_IJ'()))
Tensor.metric(eta, eta, 'I')

local g = (e'_u^I' * e'_v^J' * eta'_IJ')()
printbr(var'g''_uv':eq(g'_uv'()))

-- [[ ...and out of nowhere, force betas to be zero
g[1][2] = symmath.Constant(0)
g[2][1] = symmath.Constant(0)
printbr'zero skew components:'
printbr(var'g''_uv':eq(g'_uv'()))
--]]

printbr'set metric'
Tensor.metric(g)
printbr(var'g''_uv':eq(g'^uv'()))

-- [[ simply solve for any unit vector ...
local nUt, nUx = vars('n^t', 'n^x')
local n = Tensor('^u', nUt, nUx)
printbr(var'n''^u':eq(n'^u'()))

-- TODO auto transform between coordinates using vielbein 
local n_dot_e = (n'^u' * e'_u^I'):eq(Tensor'^I')()
local n_dot_e_x = n_dot_e:lhs()[1]:eq(n_dot_e:rhs()[1])
printbr(var'n''_I':eq(n_dot_e))

local nUt_from_nUx = n_dot_e_x:solve(nUt)
printbr(var'n''^t'..' from '..var'n''^x'..' : '..nUt_from_nUx)

local n_norm = (n'^u' * n'_u')():eq(-1)
printbr('$n \\cdot n = -1$ : ',n_norm)
local n_norm_from_nUx = n_norm:subst(nUt_from_nUx)()
printbr(n_norm_from_nUx)
local nUx_solns = table{n_norm_from_nUx:solve(nUx)}
printbr'$n^x$ solutions:'
printbr(nUx_solns:map(function(eqn) return '\t'..eqn end):concat('<br>\n'))
printbr"solving the first one first (keep note that they're plus or minus...)"
local nUx_soln = nUx_solns[1]
printbr(var'n''^x'..' is  ',nUx_soln:rhs())
-- (-d/{dx}[h] sqrt(4 + 8 (d/{dx}[h])^4 - 12 (d/{dx}[h])^2)) / (-2 - 4 (d/{dx}[h])^4 + 6 (d/{dx}[h])^2)
local cmp = (-t:diff(x) * symmath.sqrt(4 + 8 * t:diff(x)^4 - 12 * t:diff(x)^2)) / (-2 - 4 * t:diff(x)^4 + 6 * t:diff(x)^2)
printbr('should be',cmp)
-- assert we're here.  I'm going to simplify this by hand since I don't have a good polynomial factoring algorithm ...
--assert((nUx_soln:rhs():eq(cmp):isTrue())
-- h' / sqrt((1 - h'^2)*(1 - 2 h'^2))
local nUx_soln = nUx:eq(t:diff(x) / symmath.sqrt((1 - t:diff(x)^2)*(1 - 2*t:diff(x)^2)))
printbr('rewritten by hand :',nUx_soln)
local nUt_soln = nUt_from_nUx:subst(nUx_soln)()	-- also plus or minus, since n^t is scaled by n^x
printbr'$n^t$ solutions:'
printbr(nUt_soln)
printbr(nUt:eq((-nUt_soln:rhs())()))
-- once again, polynomial simplification ...
-- (-1 + (d/{dx}[h])^2) / (-sqrt(1 - 3 (d/{dx}[h])^2 + 2 (d/{dx}[h])^4))
local cmp = (-1 + t:diff(x)^2) / (-symmath.sqrt(1 - 3 * t:diff(x)^2 + 2 * t:diff(x)^4))
printbr('should be',cmp)
--assert((nUt_soln:rhs():eq(cmp):isTrue())
-- (1 - h'^2) / sqrt((1 - h'^2)*(1 - 2 h'^2))
-- (1 - h'^2) / (sqrt(1 - h'^2)*sqrt(1 - 2 h'^2))
local nUt_soln = nUt:eq(symmath.sqrt((1 - t:diff(x)^2) / (1 - 2 * t:diff(x)^2)))
printbr(nUt_soln)

local n = Tensor('^u', nUt_soln:rhs(), nUx_soln:rhs())
printbr(var'n''^u':eq(n'^u'()))

local n_dot_e_x = (n'^u' * e'_u^I')():eq(0)
printbr('$n_\\hat{x} = 0$')
printbr(n_dot_e_x)

local n_norm = (n'^u' * g'_uv' * n'^v')():eq(-1)
printbr('n dot n = -1')
printbr(n_norm)
-- and once again, polynomial division would show this to be true ...

-- connection coefficients
local Gamma = ((g'_ab,c' + g'_ac,b' - g'_bc,a')/2)()
printbr('1st kind Christoffel')
printbr(var'\\Gamma''_abc':eq(Gamma'_abc'()))
printbr()

Gamma = Gamma'^a_bc'()	-- change form stored in Gamma from 1st to 2nd kind

-- Christoffel: G^a_bc = g^ae G_ebc
printbr('2nd kind Christoffel')
printbr(var'\\Gamma''^a_bc':eq(Gamma'^a_bc'()))
printbr()

printbr(var'n''_u':eq(n'_u'()))
printbr('$\\partial_u n_v = $'..n'_u,v'())

local diff_n = (n'_u,v' - Gamma'^w_vu' * n'_w')()
printbr('$\\nabla_u n_v = $'..diff_n'_uv'())

local P = (g'^u_v' + n'^u' * n'_v')()
--[[ explicitly force extrinsic projection values to zero?
PUL[1][2] = symmath.Constant(0)
PUL[2][1] = symmath.Constant(0)
--]]
printbr(var'\\perp':eq(var'P''^u_v'):eq(P'^u_v'()))

local proj_diff_n = (P'^c_a' * diff_n'_cd' * P'^d_b')()
printbr('$\\perp \\nabla_u n_v = $'..proj_diff_n)

local K = (-(proj_diff_n'_ab' + proj_diff_n'_ba')/2)()
printbr(var'K''_uv':eq(K'_uv'()))

-- here's another example of where overloading tensor indexing on *all* expressions is handy ... what if we put a minus sign outside one?  and tidy() gives us unm(Tensor)?
--local K = ((-diff_n'_ab' - n'_a' * n'^b' * diff_n'_ba'))()
--printbr('$K_{uv} = $'..K'_ab')	

local K = K'^a_b'()
printbr(var'K''^u_v':eq(K'^u_v'()))

local K = K'^a_a'()
printbr(var'K':eq(K))
-- ... so where did K = -h'' / sqrt(g_xx) = -h'' / sqrt(1 - h'^2) come from?
-- maybe with a different choice of n?

print(MathJax.footer)
