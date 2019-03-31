#!/usr/bin/env luajit
require 'ext'
require 'symmath'.setup{tostring='MathJax', MathJax={title='Schwarzschild - isotropic'}}

-- coordinates
local t,x,y,z = vars('t','x','y','z')

local dim = 4	-- 2, 3, or 4

local allCoords = table{t, x, y, z}
local coords = allCoords:sub(1,dim)
local spatialCoords = allCoords:sub(2,dim)

Tensor.coords{
	{variables = coords},
	{variables = spatialCoords, symbols = 'ijklmn'},
}


local r = var('r', spatialCoords)

-- mass is constant
local R = var'R'

local r = var('r', spatialCoords)

local mu = var('\\mu', spatialCoords)
local mu_def = mu:eq(R / (4 * r))
printbr(mu_def)

local mu_plus = var('\\mu_+', spatialCoords)
local mu_plus_def = mu_plus:eq(1 + mu)
printbr(mu_plus_def) 

local mu_minus = var('\\mu_-', spatialCoords)
local mu_minus_def = mu_minus:eq(1 - mu)
printbr(mu_minus_def)

-- schwarzschild metric in isotropic coordinates
local g = Tensor('_uv', function(u,v)
	if u == 1 and v == 1 then
		return -(mu_minus / mu_plus)^2
	elseif u == v then
		return mu_plus^4
	else
		return 0
	end
end)

printbr'metric:'
printbr(var'g''_uv':eq(g'_uv'()))

local gInv = Tensor('^uv', table.unpack(
	(Matrix(table.unpack(g)):inverse())
))

printbr'metric inverse:'
printbr(var'g''^uv':eq(gInv'^uv'()))

printbr((var'g''_ua'*var'g''^av'):eq( (g'_ua' * gInv'^av')() ))

Tensor.metric(g, gInv)

-- metric partial
-- assume dr/dt is zero
local dg = Tensor'_uvw'
dg['_uvw'] = g'_uv,w'()
for _,xi in ipairs(spatialCoords) do
	dg = dg:subst(mu_plus_def:diff(xi)(), mu_minus_def:diff(xi)(), mu_def:diff(xi)())()
	dg = dg:replace(r:diff(xi), xi/r)()
end
printbr'metric partial derivatives:'
printbr(var'g''_uv,w':eq(dg'_uvw'()))

-- Christoffel: G_abc = 1/2 (g_ab,c + g_ac,b - g_bc,a) 
local Gamma = ((dg'_abc' + dg'_acb' - dg'_bca') / 2)()
printbr'1st kind Christoffel:'
printbr(var'\\Gamma''_uvw':eq(Gamma'_uvw'()))

-- Christoffel: G^a_bc = g^ae G_ebc
Gamma = Gamma'^u_vw'()	-- change underlying storage (not necessary, but saves future calculations)
printbr'2nd kind Christoffel:'
printbr(var'\\Gamma''^u_vw':eq(Gamma'^u_vw'()))

--[[
-1/alpha^2 = g^tt
alpha = sqrt(-1/g^tt)
--]]
local alpha = symmath.sqrt(-1/gInv[1][1])
local n = Tensor('_u', function(u)
	return u == 1 and alpha or 0
end)
printbr(var'n''_u':eq(n'_u'()))	--'_u')

-- P is really just the 4D extension of gamma ...
-- it'd be great if I could just define gamma in 4D then just reference the 3D components of it when it needed to be treated like a 3D tensor ...
local P = (g'_uv' + n'_u' * n'_v')()
printbr(var'P''_uv':eq(P'_uv'()))

local dn = Tensor'_uv'
-- simplification loop?
--dn = (dn'_uv' - Gamma'^w_vu' * n'_w'):simplify()
-- looks like chaining arithmetic operators between tensor +- and * causes problems ... 
-- ... probably because we're trying to derefernce an uevaluated multiplication ... so it has no internal structure yet ...
-- ... so should (a) tensor algebra be immediately simplified, or
--				(b) dereferences require simplification?
dn['_uv'] = (n'_v,u' - (Gamma'^w_vu' * n'_w')()'_uv')()
for _,xi in ipairs(spatialCoords) do
	dn = dn:replace(r:diff(xi), xi/r)()
end
printbr(var'dn':eq(dn))
printbr((var'\\nabla n''_uv'):eq(dn'_uv'()))

-- TODO add support for (ab) and [ab] indexes
local K = (P'^a_u' * P'^b_v' * ((dn'_ab' + dn'_ba')/2))() 
printbr(var'K''_uv':eq(K'_uv'()))

-- Geodesic: x''^u = -G^u_vw x'^v x'^w
local diffx = Tensor('^u', function(u) return symmath.var('\\dot{x}^'..coords[u].name, coords) end)
local diffx2 = (-Gamma'^u_vw' * diffx'^v' * diffx'^w'):simplify()
printbr('geodesic equation')
printbr('$\\ddot{x}^a = $'..diffx2)

--[[
-- Christoffel partial: G^a_bc,d
local dGamma = Gamma'^a_bc,d':simplify()
printbr('2nd kind Christoffel partial')
printbr('${\\Gamma^a}_{bc,d} = $'..dGamma)
printbr()

--Riemann: R^a_bcd = G^a_bd,c - G^a_bc,d + G^a_uc G^u_bd - G^a_ud G^u_bc
local Riemann = (dGamma'^a_bdc' - dGamma'^a_bcd' + Gamma'^a_uc' * Gamma'^u_bd' - Gamma'^a_ud' * Gamma'^u_bc'):simplify()
printbr('Riemann curvature tensor')
printbr('${R^a}_{bcd} = $'..Riemann)
printbr()

-- Ricci: R_ab = R^u_aub
local Ricci = Riemann'^u_aub':simplify()
printbr('Ricci curvature tensor')
printbr('$R_{ab} = $'..Ricci)
printbr()

-- Gaussian curvature: R = g^ab R_ab
local Gaussian = Ricci'^a_a':simplify()
printbr('Gaussian curvature')
printbr('$R = $'..Gaussian)
printbr()
--]]
