#!/usr/bin/env luajit
-- MTW's Gravitation ch. 16 problem 1

require 'ext'
require 'symmath'.setup()
require 'symmath.tostring.MathJax'.setup()

local t, x, y, z = vars('t', 'x', 'y', 'z')
local coords = table{t, x, y, z}
Tensor.coords{
	{variables = coords},
	{variables = {x,y,z}, symbols = 'ijklmn'},
}

local Phi = var('\\Phi', coords)
local rho = var('\\rho', coords)
local P = var('P', coords)

local delta = var'\\delta'
local deltaDef = delta'_uv':eq(Tensor('_uv', {1,0,0,0}, {0,1,0,0}, {0,0,1,0}, {0,0,0,1}))
printbr(deltaDef)

local eta = var'\\eta'
local etaDef = eta'_uv':eq(Tensor('_uv', {-1,0,0,0}, {0,1,0,0}, {0,0,1,0}, {0,0,0,1}))
printbr(etaDef)
 
local g = var'g'
local gDef = g'_uv':eq( eta'_uv' - 2 * Phi * delta'_uv' )
printbr(gDef)

local gVal = gDef:rhs():subst(deltaDef, etaDef)()	-- turn the index expression into a dense tensor ...
Tensor.metric(gVal)
local gValDef = g'_uv':eq(gVal'_uv'())
printbr(gValDef)
local gUValDef = g'^uv':eq(gVal'^uv'())
printbr(gUValDef)
printbr()

local Gamma = var'\\Gamma'
-- TODO:
-- *) automatically separate out comma derivatives into separate TensorRef's, for easier substitution
-- *) automatically reindex subst's where applicable
-- *) make dense Tensor reindexing work just like expression reindexing
local GammaLDef = Gamma'_abc':eq(frac(1,2) * (g'_ab''_,c' + g'_ac''_,b' - g'_bc''_,a'))
printbr(GammaLDef)
printbr()

local GammaLDef_wrt_eta_delta = GammaLDef:subst(
	gDef:reindex{ab='uv'},
	gDef:reindex{ac='uv'},
	gDef:reindex{bc='uv'})
printbr(GammaLDef_wrt_eta_delta)
printbr()

-- [[ can't substitute g's for eta's, then reindex, then subtitute
--	because the comma derivatives ...
-- TODO if subst gets a tensorRef on the lhs then try substituting all permutations of its indexes into the rhs
local GammaLVal = GammaLDef_wrt_eta_delta:rhs():subst(
	etaDef:reindex{ab='uv'},
	etaDef:reindex{ac='uv'},
	etaDef:reindex{bc='uv'},
	deltaDef:reindex{ab='uv'},
	deltaDef:reindex{ac='uv'},
	deltaDef:reindex{bc='uv'})
printbr(Gamma'_abc':eq(GammaLVal))
printbr()
--]]
-- [[ so instead you have to substitute the dense tensor values first

-- here's an ambiguity issue:
-- x'_uv' if x is a tensor reindex gVal
-- but x'_,c', if x is a scalar, should give the gradient of x
-- so stop using __call to reindex dense tensors -- only use :reindex 
-- but then dense tensor expressions would become ugly...
-- Gamma['_abc'] = (g:reindex{ab='uv'}'_,c' + g:reindex{ac='uv'}'_,b' + g:reindex{bc='uv'}'_,a')/2
local dgVal = gVal'_ab,c'()	-- dgVal is indexed by abc
local dgValDef = g'_ab''_,c':eq(dgVal)
local GammaLVal = GammaLDef:rhs():subst(
	dgValDef:reindex{abc='abc'},
	dgValDef:reindex{acb='abc'},
	dgValDef:reindex{bca='abc'})
--]]
printbr(Gamma'_abc':eq(GammaLVal))
printbr()

GammaLVal = GammaLVal()	-- simplify
printbr(Gamma'_abc':eq(GammaLVal))
printbr()

local GammaUVal = GammaLVal'^a_bc'()	-- here's where __call is used for reindexing
printbr(Gamma'^a_bc':eq(g'^ad' * Gamma'_dbc'))
printbr()

printbr(Gamma'^a_bc':eq(GammaUVal))
printbr()

-- assume diagonal matrix
printbr()
printbr'let $\\Phi$ ~ 0, but keep $\\partial\\Phi$ to find:'

GammaUVal = GammaUVal:replace(Phi, 0, Derivative.is)()
printbr(Gamma'^a_bc':eq(GammaUVal'^a_bc'()))

gVal = gVal:replace(Phi, 0, Derivative.is)()
Tensor.metric(gVal)
local gVal = gVal'_uv'()
local gValDef = g'_uv':eq(gVal)
printbr(gValDef)
local gUVal = gVal'^uv'()
local gUValDef = g'^uv':eq(gUVal)
printbr(gUValDef)
printbr()

local dPhi_dt_eq_0 = Phi:diff(t):eq(0)
printbr('let '..dPhi_dt_eq_0..' to find:')
GammaUVal = GammaUVal:subst(dPhi_dt_eq_0)()

printbr(Gamma'^a_bc':eq(GammaUVal'^a_bc'()))
printbr()

printbr('let')
local u = var'u'
local uVal = Tensor('^u', function(u)
	return var('u^'..coords[u].name, coords)
end)
local uDef = u'^a':eq(uVal'^a'())
printbr(uDef)
printbr()

printbr'matter stress-energy tensor:'
local T = var'T'
local TDef = T'^ab':eq( (rho + P) * u'^a' * u'^b' + P * g'^ab' )
printbr(TDef)
printbr()

local TVal = TDef:rhs():subst(
	u'^a':eq( uVal'^a'() ),
	u'^b':eq( uVal'^b'() ),
	g'^ab':eq(gUVal'^ab'() )
)
printbr(T'^ab':eq(TVal))

TVal = TVal()
printbr(T'^ab':eq(TVal))
printbr()

local divT = var'\\nabla \\cdot T'
local divT_eq_0 = divT:eq(0)
local divTVal = (TVal'^ab_,b' + GammaUVal'^a_cb' * TVal'^cb' + GammaUVal'^b_cb' * TVal'^ac')()
printbr()
printbr(divT_eq_0)
for _,eqn in ipairs(divTVal) do
	printbr(eqn:eq(0))
end

printbr()
printbr'low velocity relativistic approximations:'
local ut_eq_1 = uVal[1]:eq(1)
printbr(ut_eq_1)
divTVal = divTVal:subst(ut_eq_1)()

printbr()
printbr(divT_eq_0..' becomes:')
for _,eqn in ipairs(divTVal) do
	printbr(eqn:eq(0))
end

local Pu = (P * uVal'^i')()	
local div_Pu = Pu'^i_,i'()
printbr(div_Pu:eq(0))
divTVal[1] = (divTVal[1] - div_Pu)()

printbr()
printbr('first equation in terms of $\\partial_t \\rho$')
local drho_dt_def = divTVal[1]:eq(0):solve(rho:diff(t))
printbr(drho_dt_def)

printbr()
printbr'spatial equations neglect $P_{,t}$, $(P u^j)_{,j}$, $P$, and $\\Phi_{,i} u_j$ and substitutes the definition of $\\partial_t \\rho$'
for i=2,4 do
	-- remove time derivative of pressure
	divTVal[i] = divTVal[i]:replace(P:diff(t), 0)()
	
	-- this one's tough: neglect P,j u^j u^i ... but keep P,j
	divTVal[i] = (divTVal[i] - div_Pu * uVal[i])()

	-- this one too ... get rid of the P that's just floating out there.  but leave its gradients.
	divTVal[i] = divTVal[i]:replace(P, 0, Derivative.is)()

	-- substitute drho/dt definition to cancel some terms out
	divTVal[i] = divTVal[i]:subst(drho_dt_def)()

	-- get rid of any Phi,j times u,k of any kind ... hmm ...
	divTVal[i] = divTVal[i]:map(function(expr)
		if not op.mul.is(expr) then return end
		local dPhi = Phi'_,i'()
		local foundDPhi
		local foundU
		expr:map(function(node)
			foundDPhi = foundDPhi or table.find(dPhi, node)
			foundU = foundU or table.find(uVal, node)
		end)
		if foundDPhi and foundU then return 0 end
	end)()
end

printbr()
printbr(divT_eq_0..' becomes:')
for _,eqn in ipairs(divTVal) do
	printbr(eqn:eq(0))
end
