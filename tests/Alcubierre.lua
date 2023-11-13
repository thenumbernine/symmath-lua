#!/usr/bin/env luajit
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'ext.env'(env)
require 'symmath'.setup{env = env, MathJax = {title = 'Alcubierre warp bubble'}}
local MathJax = export.MathJax
require 'ext.env'(env)

local t,x,y,z = vars('t', 'x', 'y', 'z')
local coords = {t,x,y,z}

local C = Tensor.Chart{coords=coords}
local CS = Tensor.Chart{coords={x,y,z}, symbols='ijklmn', metric=function() return Matrix({1,0,0},{0,1,0},{0,0,1}) end}
local Ct = Tensor.Chart{coords={t}, symbols='t'}
local Cx = Tensor.Chart{coords={x}, symbols='x'}
local Cy = Tensor.Chart{coords={y}, symbols='y'}
local Cz = Tensor.Chart{coords={z}, symbols='z'}

local R = var'R'
printbr(R, '= warp bubble radius.')

local sigma = var'\\sigma'
printbr(1/sigma, '= warp bubble thickness.')

local xs = var('x_s', {t})
printbr(xs, '= warp bubble center location along the x axis.')

--[[
local vs = func('v_s', {t}, xs:diff(t))
printbr(vs:printEqn(), '= warp bubble velocity, as a function of t')
TODO make this zero?  constant-velocity?
--]]
-- [[
local vs = var('v_s', {t})
local vsdef = vs:eq(xs:diff(t))
printbr(vsdef, '= warp bubble velocity, as a function of t')
--]]

--[[
local rs = func('r_s', {x,y,z,xs}, sqrt((x - xs)^2 + y^2 + z^2))
printbr(rs:printEqn(), '= warp bubble radial coordinate')
--]]
-- [[
local rs = var('r_s', {t,x,y,z,xs})
local rsdef = rs:eq(sqrt((x - xs)^2 + y^2 + z^2))
printbr(rsdef, '= warp bubble radial coordinate')
--]]

local u = var('u', {t,x,y,z})

-- TODO HOW TO DEFINE CUSTOM FUNCTIONS?

local fdefrhs = (tanh(sigma * (rs + R)) - tanh(sigma * (rs - R))) / (2 * tanh(sigma * R))
--[[ using 'func' as 'Variable' ... doesn't have partial derivative evaluation
local f = func('f', {rs})
printbr(f:printEqn():eq(fdefrhs), '= shape of bubble')
local udef = u:eq(vs * f)
--]]
--[[ using Function subclass, and inserting in my own derivative evaluation
-- TODO how would I insert the derivative evaluation into symmath/Function.lua ?
local f = Function:subclass{name='f'}
function f:evaluateDerivative(deriv, ...)
	local x = table.unpack(self):clone()
	return deriv(x, ...) * Function:subclass{name="f'"}(x)
end
printbr(f(rs):eq(fdefrhs), '= shape of bubble')
local udef = u:eq(vs * f(rs))
--]]
-- [[ using 'func' as 'Function'
local f = func('f', {rs})	--, fdefrhs)
local fdef = f(rs):eq(fdefrhs)
printbr(fdef, '= shape of bubble')
local udef = u:eq(vs * f(rs))
--]]

local drs_dx_defs = table()
for i,xi in ipairs(coords) do
	drs_dx_defs[i] = rsdef:diff(xi)()
		:subst(rsdef():switch())
		:subst(vsdef:switch())
		:simplify()
	printbr(drs_dx_defs[i])
end
printbr()

local d2rs_dx2_defs = table()
for i=1,#coords do
	local xi = coords[i]
	for j=i,#coords do
		--local ij = i + j - (math.min(i,j) > 1 and 0 or 1)
		local ij = i+j-1+(math.min(i,j)>=2 and 2 or 0)+(math.min(i,j)>=3 and 1 or 0)
		local xj = coords[j]
		assert(not d2rs_dx2_defs[ij])
		d2rs_dx2_defs[ij] = drs_dx_defs[i]:diff(xj)()
			:subst(drs_dx_defs:unpack())()
			:subst(vsdef:switch())()
		printbr(d2rs_dx2_defs[ij])
	end
end
assert(#d2rs_dx2_defs == 10)
printbr()

--[[
u = v_s(t) * f(r_s(t))
du/dt = dv_s/dt * f + v_s * df/dt
	= ∂v_s/∂t * f + v_s * ∂f/∂r_s(r_s(t)) * dr_s/dt
	= ∂v_s/∂t * f + v_s * ∂f/∂r_s(r_s(t)) * ∂r_s/∂x_s * dx_s/dt
	= ∂v_s/∂t * f + v_s * ∂f/∂r_s(r_s(t)) * ∂r_s/∂x_s * v_s

TODO total derivative
--]]
printbr(udef)
printbr()

printbr(udef'_,i'())
local du_dx_defs = table()
for i,xi in ipairs(coords) do
	du_dx_defs[i] = udef:diff(xi)()
	printbr(du_dx_defs[i])
end
printbr()

-- in the mean time
local udefraw = udef
	--:replace(f, fdefrhs)	-- needed for the var version?
	:subst(rsdef)
--printbr(udefraw:subst(rsdef():switch())'_,i')

for i=1,#du_dx_defs do
	du_dx_defs[i] = du_dx_defs[i]:subst(drs_dx_defs:unpack())()
	printbr(du_dx_defs[i])
end
printbr()

local d2u_dx2_defs = table()
printbr(udef'_,ij'())
for i=1,#coords do
	local xi = coords[i]
	for j=i,#coords do
		local xj = coords[j]
		--local d2rs_dxij = 
		local tmp = udef:diff(xi,xj)()
		local d2u_dx2_def = tmp
			:subst(d2rs_dx2_defs:unpack())
			:subst(drs_dx_defs:unpack())
			:simplifyAddMulDiv()
		printbr(tmp:eq(d2u_dx2_def:rhs()))
		d2u_dx2_defs:insert(d2u_dx2_def)
	end
end
assert(#d2u_dx2_defs == 10)
printbr()

--MathJax.useCommaDerivative = true

local alpha_var = var'\\alpha'
local alpha = 1
local alpha_def = alpha_var:eq(alpha)
printbr(alpha_def, '= metric lapse')

local beta = Tensor('^i', -u, 0, 0)
printbr(var'\\beta''^i':eq(beta'^i'()), '= metric shift')

local gamma = Tensor('_ij', {1,0,0}, {0,1,0}, {0,0,1})

printbr'spatial metric:'
printbr(var'\\gamma''_ij':eq(gamma'_ij'()))
printbr(var'\\gamma''^ij':eq(gamma'^ij'()))
printbr()

local eta = var'\\eta'
local etadef = Tensor('_IJ', function(i,j) return i==j and (i==1 and -1 or 1) or 0 end)
local e = var'e'
local edef = Tensor('_a^I',
	{sqrt(1-u^2), 0, 0, 0},
	{u/sqrt(1-u^2), 1/sqrt(1-u^2), 0, 0},
	{0, 0, 1, 0},
	{0, 0, 0, 1})
printbr(e'_a^I':eq(edef'_a^I'()))
printbr()

printbr'4-metric:'
local gvar = var'g'
local g_from_e = gvar'_ab':eq(e'_a^I' * e'_b^J' * eta'_IJ')
printbr(g_from_e)
printbr()
g_from_e = g_from_e:replace(e, edef):replace(eta, etadef)()
printbr(g_from_e)

--[[ manually specify metric
local g = Tensor'_ab'
g['_tt'] = (-alpha^2 + beta'^i' * beta'^j' * gamma'_ij')()
g['_it'] = (beta'^i' / alpha^2)()
g['_ti'] = (beta'^i' / alpha^2)()
g['_ij'] = gamma'_ij'()
g = g()
--]]
-- [[ derive from tetrad
local g = g_from_e:rhs()
--]]

local detg = var('g', {t,x,y,z})
local detg_def = Matrix(table.unpack(g)):determinant()
printbr(gvar:eq(detg_def))

local gU = Tensor('^ab', table.unpack(
	(Matrix(table.unpack(g)):inverse())
))
printbr(gvar'^ab':eq(gU'^ab'()))

C:setMetric(g, gU)

printbr'hypersurface normal:'
local nL = Tensor('_u', -alpha, 0, 0, 0)
local nLdef = var'n''_u':eq(nL)
printbr(nLdef)

local nU = (nL'^u')()
local nUdef = var'n''^u':eq(nU)
printbr(nUdef)

printbr'connection:'
local Gamma = ((g'_ab,c' + g'_ac,b' - g'_bc,a') / 2)()
printbr(var'\\Gamma''_abc':eq(Gamma'_abc'()))

Gamma = Gamma'^a_bc'()
printbr(var'\\Gamma''^a_bc':eq(Gamma'^a_bc'()))

local dx = Tensor('^u', function(u) return var('\\dot{x}^'..coords[u].name) end)
local d2x = Tensor('^u', function(u) return var('\\ddot{x}^'..coords[u].name) end)
printbr'geodesic:'
-- TODO unravel equaliy, or print individual assignments
printbr(d2x'^a':eq((-Gamma'^a_bc' * dx'^b' * dx'^c')()))
printbr()

local dGamma = Tensor'^a_bcd'
dGamma['^a_bcd'] = Gamma'^a_bc,d'()
printbr(var'\\Gamma''^a_bc,d':eq(dGamma'^a_bcd'()))
printbr()

local GammaSq = Tensor'^a_bcd'
GammaSq['^a_bcd'] = (Gamma'^a_ec' * Gamma'^e_bd')()
printbr(var'(\\Gamma^2)''^a_bcd':eq(GammaSq'^a_bcd'()))
printbr()

printbr'extrinsic curvature'
printbr(var'K''_ij':eq((nL'_a' * Gamma'^a_ij')()))
printbr()

printbr'Riemann curvature:'
local Riemann = Tensor'^a_bcd'
Riemann['^a_bcd'] = (dGamma'^a_bdc' - dGamma'^a_bcd' + GammaSq'^a_bcd' - GammaSq'^a_bdc')()
printbr(var'R''^a_bcd':eq(Riemann'^a_bcd'()))
printbr()

printbr'Ricci curvature:'
local Ricci = Riemann'^c_acb'()
printbr(var'R''_ab':eq(Ricci'_ab'()))
printbr()

printbr'Gaussian curvature:'
local Gaussian = Ricci'^a_a'()
printbr(var'R':eq(Gaussian))
printbr()

printbr'Einstein curvature:'
local Einstein = (Ricci'_ab' - g'_ab' * Gaussian / 2)()
printbr(var'G''_ab':eq(Einstein'_ab'()))
printbr()

printbr'Einstein field equation:'
local c = var'c'
local T = var'T'
local EFEdef = var'G''_ab':eq( (8 * pi * var'G') / c^4 * T'_ab')
printbr(EFEdef)
local EFEdef_wrt_T = EFEdef:solve(T'_ab')
printbr(EFEdef_wrt_T)
EFEdef_wrt_T = EFEdef_wrt_T:replace(var'G''_ab', Einstein'_ab')()
printbr(EFEdef_wrt_T)
printbr()

EFEdef_wrt_T_u = EFEdef_wrt_T
	:subst(du_dx_defs:unpack())
	:subst(d2u_dx2_defs:unpack())
	:simplify()
printbr(EFEdef_wrt_T_u)
printbr()

local rho = var'\\rho'
local n = var'n'
local rho_def = rho:eq(T'_ab' * n'^a' * n'^b')
printbr'density:'
printbr(rho_def)
printbr()

rho_def = rho_def:subst(EFEdef_wrt_T)
	:replace(n'^a', nU'^a')
	:replace(n'^b', nU'^b')
	:simplify()

printbr(rho_def)
printbr('using', du_dx_defs[3], ',', du_dx_defs[4])
rho_def = rho_def:subst(du_dx_defs[3], du_dx_defs[4])()
printbr(rho_def)
printbr()

-- for G_uv = 8 pi G/c^4 T_uv
-- and rho = n^u n^v T_uv = c^4 / (8 pi G) G_uv
-- should be rho = c^4 / (8 pi G) * (-vs^2 df/drs^2 (y^2 + z^2) / (4 g^2 rs^2))
-- for g = det(g_uv)
-- but why is g a variable?  for the provided metric, det(g_uv) = -1


