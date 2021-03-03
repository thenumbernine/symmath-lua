#!/usr/bin/env luajit
require 'ext'
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath'.setup{env=env, implicitVars=true, MathJax={title='rotation group'}}

local function cot(...) return cos(...) / sin(...) end

local Props = class(require 'symmath.physics.diffgeom', {print=printbr, verbose=true})

printbr[[
<h3>Rotation Groups</h3><br>
<br>

Taken from a few problems from Misner, Thorne, Wheeler, "Gravitation":<br>
Exercise 9.13: rotation groups - generators<br>
Exercise 9.13: rotation groups - structure constants: ${c_{\alpha\beta}}^\gamma = -\epsilon_{\alpha\beta\gamma}$<br>
Exercise 10.17: rotation groups - connection coefficients: ${\Gamma^\alpha}_{\beta\gamma} = \frac{1}{2} \epsilon_{\alpha\beta\gamma}$<br>
Exercise 11.12: rotation groups - Riemann curvature: ${R^\alpha}_{\beta\gamma\delta} = \frac{1}{2} \delta^{\alpha\beta}_{\gamma\delta}$<br>
Exercise 13.15: rotation groups - metric (in non-coordinate basis of generators): $g_{\alpha\beta} = \delta_{\alpha\beta}, [e_\alpha, e_\beta] = -\epsilon_{\alpha\beta\gamma} e_\gamma$<br>
<br>
]]

local t,x,y,z = vars('t','x','y','z')
local r,phi,theta,psi = vars('r','\\phi','\\theta','\\psi')

local baseCoords = table{psi,theta,phi}

local delta3 = Matrix:lambda({3,3}, function(i,j) return i==j and 1 or 0 end)

local embedded = {x,y,z}
local flatMetric = delta3

-- notice MTW uses negative rotations, then concludes with c_ab^c = -epsilon_abc 
-- turning these from negative to positive rotations results in c_ab^c = epsilon_abc 
local Rs = Matrix.eulerAngles
local Rx, Ry, Rz = table.unpack(Rs)
for i,R in ipairs(Rs) do
	printbr('$R_'..embedded[i].name..'(\\theta) = $', R(theta))
end

printbr[[$R_i(t) = exp(t K_i)$]]
printbr[[$\frac{\partial}{\partial t} R_i(t) = K_i R_i(t)$]]
printbr[[$K_i = \frac{\partial}{\partial t} R_i(t) R_i(t)^{-1}
	= \frac{\partial}{\partial t} R_i(t) R_i(t)^T$]]
printbr[[$ = \frac{\partial}{\partial t} R_i(t)|_{t=0}$]]
local Ks = Rs:map(function(R) return R(theta):diff(theta)():replace(theta,0)() end)
for i,K in ipairs(Ks) do
	printbr('$K_'..embedded[i].name..[[ = $]], K)
end

-- assumes n is unit
local function Rn(theta, nx, ny, nz)
	return Matrix.rotation(theta, {nx,ny,nz})
end

for _,info in ipairs{
	-- proper Euler angles
	-- zxz xyx yzy zyz xzx yxy

	-- [=[
	{	-- MTW uses ZXZ
		title = [[$P = R_z(\psi) R_x(\theta) R_z(\phi) = $]],
		P = (Rz(psi) * Rx(theta) * Rz(phi))(),
	},
	--]=]

	--[=[
	{	
		title = [[$P = R_x(\psi) R_y(\theta) R_x(\phi) = $]],
		P = (Rx(psi) * Ry(theta) * Rx(phi))(),
	},
	--]=]

	-- Tait-Bryan angles
	-- xyz yzx zxy xzy zyx yxz
	--[=[
	{	-- ZYX angles
		title = [[$P = R_z(\psi) R_y(\theta) R_x(\phi) = $]],
		P = (Rz(psi) * Ry(theta) * Rx(phi))(),
	},
	--]=]

	--[=[ one rotation dimension less
	--[[
	...this means I can't just invert e_a^I to get e^a_I 
	I would have to solve the inverse equations and differentiate them
	e_a^I = dx^I/dx^a for a in x,y,z and I in psi,theta,phi
	
	(dpsi/dx d/dpsi + dtheta/dx d/dtheta + dphi/dx d/dphi) P = d/dt Rx(t=0) P
	(dpsi/dy d/dpsi + dtheta/dy d/dtheta + dphi/dy d/dphi) P = d/dt Ry(t=0) P
	(dpsi/dz d/dpsi + dtheta/dz d/dtheta + dphi/dz d/dphi) P = d/dt Rz(t=0) P

	does this mean P is not just equal to Rz(psi)*Rx(theta)*Rz(phi) ?
	...but (in order to match the model above) wouldn't P have to equal
		P = Rx(t) * Ry(t) * Rz(t) * Rz(psi) * Rx(theta) * Rz(phi), evaluated at t=0 ?

	typically, in curved space embedded in flat space
	e_a = d/dx^a, so e_a = e_a^I d/dx^I = dx^I/dx^a d/dx^I

	coordiante chart: x^I is our point in embedded space
	spherical: e_r = d/dr x^I, e_theta = d/dtheta x^I, e_phi = d/dphi x^I
		e_a = d/dx^a = e_a^I e_I = e_a^I d/dx^I

	--]]
	{
		title = [[$P = R_z(\psi) R_x(\theta) =$]],
		P = (Rz(psi) * Rx(theta))(),
	},
	--]=]
} do

	--[=[ mtw's:
	-- u spans rows, I spans cols
	local em = { 
		{-sin(psi) * cot(theta), cos(psi), sin(psi) / sin(theta)},
		{cos(psi) * cot(theta), sin(psi), -cos(psi) / sin(theta)},
		{1, 0, 0},
	}
	--]=]
	--[=[ mtw's, with rows rescaled to remove sin(theta) in denominator.  doesn't produce the same commutations	
	local em = { 
		{-sin(psi) * cos(theta), cos(psi) * sin(theta), sin(psi)},
		{cos(psi) * cos(theta), sin(psi) * sin(theta), -cos(psi)},
		{1, 0, 0},
	}
	--]=]	
	--[=[ mtw picked apart
	local invem = Matrix(
		{0, 0, 1},
		{cos(psi), sin(psi), 0},
		{sin(theta) * sin(psi), -sin(theta) * cos(psi), cos(theta)}
	)
	local em = Matrix(table.unpack(invem)):inverse())
	--]=]
	-- [=[ mtw by construction

	local P = info.P
	printbr(info.title, P)
	-- and here's me trying to remove one of the rotations
	--local P = (Rz(psi) * Ry(theta))()
	-- ... sure enough, I need to fix my linear system solver to handle multiple solutions 

local Phi = var'\\Phi'
local RPhi = Rn(Phi, x, y, z)
printbr([[$R_n(\Phi) = $]], RPhi)
for i,xi in ipairs(embedded) do
	printbr([[$\frac{\partial}{\partial ]]..xi.name..[[} R_n(\Phi) = $]], RPhi:diff(xi)())
end

-- P = Rz(psi) Rx(theta) Rz(phi)
-- it a rotation of phi about axis 'n' for n = Rz(psi) * Rx(theta) * zHat?
--local n = (Rz(psi) * Rx(theta) * Matrix{0, 0, 1}:transpose())()
--printbr(Rn(phi, table.unpack(n:transpose()[1])))

--[=[
printbr[[verifying Rodrigues' rotation formula for base axis:]]
printbr(Rn(psi,1,0,0),'vs',Rx(psi))
printbr(Rn(theta,0,1,0),'vs',Ry(theta))
printbr(Rn(phi,0,0,1),'vs',Rz(phi))
--]=]

--[=[
printbr[[representing Euler angles as local rotations:]]
-- Rz(psi) * Rx(theta) is a rotation of theta by the local x axis of the basis provided by Rz(psi)
--local nx,ny,nz = table.unpack((Rz(psi) * Matrix{1,0,0}:transpose())():transpose()[1])
--printbr(Rn(theta,nx,ny,nz),'vs', (Rz(psi) * Rx(theta))())
local nx,ny,nz = table.unpack((Rz(psi) * Matrix{1,0,0}:transpose())():transpose()[1])
printbr(Rn(theta,nx,ny,nz),'vs', (Rz(psi) * Rx(theta))())
--]=]

--	printbr([[$P \cdot x = $]], (P * symmath.Matrix{var'x', var'y', var'z'}:transpose())())

	local dP = baseCoords:map(function(theta_i,i)
		return (P:diff(theta_i)())
	end)

	for i,theta_i in ipairs(baseCoords) do 
		printbr(var'P':diff(theta_i):eq(dP[i]))
	end

--[[
from https://en.wikipedia.org/wiki/Rotation_formalisms_in_three_dimensions#Rotation_matrix_.E2.86.94_Euler_axis.2Fangle
Phi = acos((P_11 + P_22 + P_33 - 1)/2)
nx = (P_32 - P_23) / (2*sin(Phi))
ny = (P_13 - P_31) / (2*sin(Phi))
nz = (P_21 - P_12) / (2*sin(Phi))
so here's how I can find dn_i/dtheta_j, and from that its inverse dtheta_i/dn_j ?
--]]

printbr[[$\Phi = acos((tr P - 1) / 2)$]]
printbr[[$\frac{\partial \Phi}{\partial t} = -\frac{1}{2 \sqrt{1 - ((tr P - 1) / 2)^2}} \frac{\partial tr P}{\partial t}$]]
printbr[[$n_i = - \frac{1}{2 sin \Phi} \epsilon_{ijk} P_{jk}$]]
printbr[[$n_x = (P_{32} - P_{23}) / (2 sin \Phi)$]]
printbr[[$n_y = (P_{13} - P_{31}) / (2 sin \Phi)$]]
printbr[[$n_z = (P_{21} - P_{12}) / (2 sin \Phi)$]]
printbr[[$\frac{\partial n_i}{\partial \psi} = \frac{\partial}{\partial \psi} (-\frac{1}{2 sin\Phi} \epsilon_{ijk} P_{jk})$]]
printbr[[$= -\frac{1}{2} \epsilon_{ijk} (-\frac{cos(\Phi)}{(sin\Phi)^2} \frac{\partial \Phi}{\partial \psi} P_{jk} + \frac{1}{sin\Phi} \frac{\partial P_{jk}}{\partial \psi} )$]]
printbr[[$= -\frac{1}{2} \epsilon_{ijk} (\frac{cos(\Phi)}{(sin\Phi)^2} \frac{1}{2 \sqrt{1 - ((tr P - 1) / 2)^2}} \frac{\partial tr P}{\partial \psi} P_{jk} + \frac{1}{sin\Phi} \frac{\partial P_{jk}}{\partial \psi} )$]]
printbr[[$= -\frac{1}{2} \epsilon_{ijk} (\frac{tr P - 1}{4 (sin\Phi)^3} \frac{\partial tr P}{\partial \psi} P_{jk} + \frac{1}{sin\Phi} \frac{\partial P_{jk}}{\partial \psi} )$]]
local trP = P:trace()
printbr('$tr P = $',trP)
for i,thetai in ipairs(baseCoords) do
	printbr(var'trP':diff(thetai):eq(trP:diff(thetai)()))
end
local cosPhi_def = (trP - 1) / 2
printbr(cos(Phi):eq(cosPhi_def))
cosPhi_def = cosPhi_def()
printbr(cos(Phi):eq(cosPhi_def))
local sinPhi_def = symmath.sqrt(1 - cosPhi_def^2)
printbr('$sin(\\Phi) = $',sinPhi_def)
sinPhi_def = sinPhi_def()
printbr('$sin(\\Phi) = $',sinPhi_def)

	-- e_a P = e_a^I d/dtheta^I P = K_I * P
	local eP = Rs:map(function(R,i) 
		-- in MTW's problem these would be negative too
		-- I think that's where the +c_ij^k vs -c_ij^k comes in 
		-- because even with MTW's negative theta parameters above, the c_ij^k still comes out positive
		-- in fact, any coordinate representaiton should have freedom to pick its own orthogonal basis of R's (right?) and not just Rx Ry Rz 
		return ((R(t):diff(t)() * P)():replace(t,0))
	end)

	for i=1,3 do
		printbr([[$e_]]..embedded[i].name..[[(P) = \frac{\partial}{\partial t} R_]]..embedded[i].name..[[(t) |_{t=0} \cdot P = K_]]..embedded[i].name..[[ \cdot P = $]], eP[i])
	end
	-- print the matrix equation with variables of e_a(P) = e_a^I d/dtheta^I P = K_a P	
	-- ... but 'a' is flat cartesian and 'I' is curved rotation angles?
	-- that's probably why e_a^I coefficients look more like the inverse of 3 rotations, and the inverse e^a_I coefficients look like 3 rotations ...
	for i=1,3 do
		local s = table()
		s:insert([[\frac{\partial}{\partial ]]..embedded[i].name..[[} P =]])
		s:insert([[e_{]]..embedded[i].name..[[} P =]])
		local sum = table()
		for j=1,3 do
			sum:insert([[\frac{\partial ]]..baseCoords[j].name..[[}{\partial ]]..embedded[i].name..[[} \frac{\partial}{\partial ]]..baseCoords[j].name..[[} P]])
		end
		s:insert(sum:concat'+')
		s:insert'='
		local sum = table()
		for j=1,3 do
			sum:insert([[{e_]]..embedded[i].name..[[}^{]]..baseCoords[j].name..[[} \frac{\partial}{\partial ]]..baseCoords[j].name..[[} P]])
		end
		s:insert(sum:concat'+')
		printbr('$'..s:concat()..[[= K_]]..embedded[i].name..[[ \cdot P$]])
	end
	--[[
	(ei1 d/dpsi + ei2 d/dtheta + ei3 d/dphi) P = Ri(t):diff(t) * P
	solve for eij
	--]]
	printbr[[
$\left[\matrix{
\frac{\partial P}{\partial \psi} |
\frac{\partial P}{\partial \theta} |
\frac{\partial P}{\partial \phi}
}\right] \left[\matrix{
e_x | e_y | e_z
}\right] = \left[\matrix{
K_x P | K_y P | K_z P
}\right]$
]]

	printbr'determining ${e_a}^I$ via linear combination of $K_i P$:'

	-- unraveled d/dtheta^I P matrices
	local dPm = Matrix(range(9):map(function(ij)
		local i, j = math.floor((ij-1)/3)+1, (ij-1)%3+1 return range(3):map(function(k)
			return dP[k][i][j]
		end)
	end):unpack())

	-- e_a^I coefficients of e_a, as a matrix
	-- here's the variables
	local emv = Matrix(range(3):map(function(i)
		return range(3):map(function(j)
			return var('{e_'..embedded[j].name..'}^{'..baseCoords[i].name..'}')
		end)
	end):unpack())

	-- unraveled e_a(P) matrices
	local ePm = Matrix(range(9):map(function(ij)
		local i, j = math.floor((ij-1)/3)+1, (ij-1)%3+1
		return range(3):map(function(k)
			return eP[k][i][j]
		end)
	end):unpack())

	-- matrix representation of (d/dtheta^I P)_ij e_b^I = e_a(P)_ij
	printbr((dPm * emv):eq(ePm))

	-- [[ using a pseudoinverse
	local emvsoln
	do
		local A = dPm
		local b = ePm
		local APlus, determinable = A:pseudoInverse()
		if not determinable then
			printbr"the pseudoinverse was not determinable"
		end
		emvsoln = (APlus * b)()
		printbr(emv:eq(APlus * b))
		printbr(emv:eq(emvsoln))
	end
	--]]
	--[[ attempting a rectangular linear solver ...
	local results = table.pack(dPm:inverse(ePm, nil, true))
	for i=1,results.n do
		printbr(i,results[i])
	end
	local emvsoln = results[1]
	printbr(emv:eq(emvsoln))
	--]]
	local em = emvsoln:transpose()

	local coords = range(3):map(function(i) 
		local ei = var('e_'..embedded[i].name)	-- this is typically e_coords[i], not embedded.  another reason I think this problem is done backwards.
		function ei:applyDiff(x)
			return range(3):map(function(j) 
				return em[i][j] * x:diff(baseCoords[j])
			end):sum()
		end
		return ei
	end)

	Tensor.coords{
		{variables=coords},
		{variables=embedded, symbols='IJKLMN', metric=flatMetric}
	}
	
	printbr('coordinates:', table.unpack(coords))
	printbr('base coords:', table.unpack(baseCoords))
	printbr('embedding:', table.unpack(embedded))
	
	printbr'determining ${e_a}^I$ via Lie bracket:'

	-- Levi-Civita permutation tensor for flat-space (density +- 1)
	local LeviCivita3 = Tensor('_ijk', function(i,j,k)
		if i%3+1 == j and j%3+1 == k then return 1 end
		if k%3+1 == j and j%3+1 == i then return -1 end
		return 0
	end)
	printbr(var'\\epsilon''_ijk':eq(LeviCivita3))
	
	local eta = Tensor('_IJ', table.unpack(flatMetric))
	printbr'flat metric:'
	printbr(var'\\eta''_IJ':eq(eta'_IJ'()))
	printbr()
--	Tensor.metric(eta, eta, 'I')

	local e = Tensor'_u^I'

	printbr'tetrad:'
	e['_u^I'] = Tensor('_u^I', table.unpack(em))
	printbr(var'e''_u^I':eq(e'_u^I'()))
	printbr()

	printbr'inverse tetrad by inverting the coefficients of the tetrad:'
	local eUm = Matrix(table.unpack(e)):inverse():transpose()
	eU = Tensor('^u_I', function(u,I) return eUm[{u,I}] or 0 end)
	printbr(var'e''^u_I':eq(eU))

	-- TODO NOW do the inverse via operator:
	-- find operators omega^a such that omega^a(e_b(P)) = delta^a_b
	-- what do these operators look like?

	printbr'verify that the two are orthogonoal:'
	printbr((var'e''_u^I' * var'e''^v_I'):eq((e'_u^I' * eU'^v_I')()))
	printbr((var'e''_u^I' * var'e''^u_J'):eq((e'_u^I' * eU'^u_J')()))

	-- TODO this is the coordinate metric, not the orthonormalized non-coordinate metric that has commutation equal to the permutation tensor
	printbr'coordinate metric:'
	local g = (e'_u^I' * e'_v^J' * eta'_IJ')()

	printbr(var'g''_uv':eq(var'e''_u^I' * var'e''_v^J' * var'\\eta''_IJ'))
	printbr(var'g''_uv':eq(g'_uv'()))

	local gU = Tensor'^uv'
	gU['^uv'] = (eU'^u_I' * eU'^v_J' * eta'^IJ')()
	printbr(var'g''^uv':eq(var'e''^u_I' * var'e''^v_J' * var'\\eta''^IJ'))
	printbr(var'g''^uv':eq(gU'^uv'()))

	Tensor.metric(g, gU)

	--[[
	e_u = e_u^I d/dx^I
	and e^v_J is the inverse of e_u^I 
	such that e_u^I e^v_I = delta_u^v and e_u^I e^u_J = delta^I_J

	[e_u, e_v] = e_u e_v - e_v e_u
		= e_u^I d/dx^I (e_v^J d/dx^J) - e_v^I d/dx^I (e_u^J d/dx^J)
		= e_u^I ( (d/dx^I e_v^J) d/dx^J + e_v^J d/dx^I d/dx^J) - e_v^I ((d/dx^I e_u^J) d/dx^J + e_u^J d/dx^I d/dx^J)
		= e_u^I (d/dx^I e_v^J) d/dx^J - e_v^I (d/dx^I e_u^J) d/dx^J
		= (e_u^I e_v^J_,I - e_v^I e_u^J_,I) d/dx^J 
		= (e_u^I (dx^a/dx^I d/dx^a e_v^J) - e_v^I (dx^a/dx^I d/dx^a e_u^J)) d/dx^J
		= (e_u^I e_v^J_,a - e_v^I e_u^J_,a) e^a_I d/dx^J
		= (delta_u^a e_v^J_,a - delta_v^a e_u^J_,a) d/dx^J
		= (e_v^J_,u - e_u^J_,v) d/dx^J
		
	so for [e_u, e_v] = c_uv^w e_w = c_uv^w e_w^J d/dx^J
	we find c_uv^w e_w^I = (e_v^I_,u - e_u^I_,v)
	or c_uv^w = (e_v^I_,u - e_u^I_,v) e^w_I
	is it just me, or does this look strikingly similar to the spin connection?
	--]]
	local c = Tensor'_ab^c'
	c['_ab^c'] = ((e'_b^I_,a' - e'_a^I_,b') * eU'^c_I')()
	printbr(var'c''_ab^c':eq(c'_ab^c'()))

	local cL = Tensor'_abc'
	cL['_abc'] = c'_abc'()
	printbr(var'c''_abc':eq(cL'_abc'()))

	local dg = Tensor'_abc'
	dg['_abc'] = g'_ab,c'()
	printbr(var'g''_ab,c':eq(dg'_abc'()))

--[[
	local GammaL = Tensor'_abc'
	GammaL['_abc'] = (frac(1,2) * (dg'_abc' + dg'_acb' - dg'_bca' + cL'_abc' + cL'_acb' - cL'_bca'))()
	printbr(var'\\Gamma''_abc':eq(frac(1,2)*(var'g''_ab,c' + var'g''_ac,b' - var'g''_bc,a' + var'c''_abc' + var'c''_acb' - var'c''_bca')))
	printbr(var'\\Gamma''_abc':eq(GammaL'_abc'()))

	local Gamma = Tensor'^a_bc'
	Gamma['^a_bc'] = GammaL'^a_bc'()
	printbr(var'\\Gamma''^a_bc':eq(var'g''^ad' * var'\\Gamma''_dbc'))
	printbr(var'\\Gamma''^a_bc':eq(Gamma'^a_bc'()))
--]]
	local Gamma = Tensor'^a_bc'
	-- purely antisymmetric 
	Gamma['^a_bc'] = (frac(1,2) * c'_cb^a')()

	local dGamma = Tensor'^a_bcd'
	dGamma['^a_bcd'] = Gamma'^a_bc,d'()
	
	local GammaSq = Tensor'^a_bcd'
	GammaSq['^a_bcd'] = (Gamma'^a_ec' * Gamma'^e_bd')()

	local Riemann = Tensor'^a_bcd'
	Riemann['^a_bcd'] = (dGamma'^a_bdc' - dGamma'^a_bcd' + GammaSq'^a_bcd' - GammaSq'^a_bdc' - Gamma'^a_be' * c'_cd^e')()
	printbr(var'R''^a_bcd':eq(Riemann'^a_bcd'()))
os.exit()

	local props = Props(g, nil, c)
	local Gamma = props.Gamma

--[=[
	local dx = Tensor('^u', function(u)
		return var('\\dot{' .. coords[u].name .. '}')
	end)
	local d2x = Tensor('^u', function(u)
		return var('\\ddot{' .. coords[u].name .. '}')
	end)

	local A = Tensor('^i', function(i) return var('A^{'..coords[i].name..'}', baseCoords) end)
	--[[
	TODO can't use comma derivative, gotta override the :applyDiff of the anholonomic basis variables
	 but when doing so, you must make the embedded variables dependent on the ... variables that the anholonomic are spun off of
		i.e. if the anholonomic basis is rHat, phiHat, thetaHat, then the A^I variables must be dependent upon r, theta, phi
	--]]
	local divVarExpr = var'A''^i_,i' + var'\\Gamma''^i_ji' * var'A''^j'
	local divExpr = divVarExpr:replace(var'A', A):replace(var'\\Gamma', Gamma)
	-- TODO only simplify TensorRef, so the indexes are fixed
	printbr('divergence:', divVarExpr:eq(divExpr):eq(divExpr():factorDivision())) 

	printbr'geodesic:'
	-- TODO unravel equaliy, or print individual assignments
	printbr(((d2x'^a' + Gamma'^a_bc' * dx'^b' * dx'^c'):eq(Tensor'^u'))())
	printbr()
--]=]

end

