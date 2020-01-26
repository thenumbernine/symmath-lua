#!/usr/bin/env luajit
require 'ext'
require 'symmath'.setup{MathJax={title='Kaluza-Klein - index notation'}}

-- this sets simplifyConstantPowers 
local units = require 'symmath.physics.units'()


local function betterSimplify(x)
	return x():factorDivision()
	:map(function(x)
		if symmath.op.add.is(x) then
			x = x:clone()
			for i=1,#x do
				x[i] = x[i]():factorDivision()
			end
			return x
		end
	end)
end


-- units
local m = units.m
local s = units.s
local kg = units.kg
local C = units.C


local c = units.c
local k_e = units.k_e
local G = units.G


printbr[[
Kaluza-Klein with constant scalar field<br>
<br>

unit coordinate convention: $dx^0 = c dt$<br>
<br>
]]

printbr(units.c_in_m_s, '= 1 = speed of light')
printbr(units.G_in_SI, ' = 1 = gravitational constant')
printbr(units.k_e_in_SI_and_C, " = 1 = Coulomb's constant")

local kg_C_eq_1 = sqrt( units.k_e_in_SI_and_C:rhs() / units.G_in_SI:rhs() )():eq(1)
printbr(sqrt(k_e / G):eq( kg_C_eq_1 ), ' = conversion from kg to C')
local kg_in_C = kg_C_eq_1:solve(kg)
printbr(kg_in_C)


Tensor.coords{{variables={'txyz','5'}}}


local greekSymbols = require 'symmath.tensor.symbols'.greekSymbolNames
	-- :sort(function(a,b) return a < b end)
	:filter(function(s) return s:match'^[a-z]' end)		-- lowercase
	:mapi(function(s) return '\\'..s end)				-- append \ to the beginning for LaTeX

Tensor.defaultSymbols = greekSymbols



local A = var'A'
printbr(A'_u', '= electromagnetic four-potential, in units', (kg*m)/(C*s))
printbr(A'_5':eq(1), 'in natural units, but to cancel the units of $\\phi$ it is in units of', (kg*m)/(C*s),
	'so $A_5 = c \\sqrt{\\frac{k_e}{G}} = $', (units.c_in_m_s:rhs() * sqrt(units.k_e_in_SI_and_C:rhs() / units.G_in_SI:rhs()))():factorDivision() )
printbr()

local phi = var'\\phi'
printbr(phi, '= scalar field, in units', (C*s)/(kg*m))
printbr()


symmath.simplifyConstantPowers = false


local g = var'g'
printbr(g'_\\mu _\\nu', '= 4D metric tensor, with units 1')
printbr(g'^\\mu ^\\nu', '= 4D metric inverse')
printbr()

local g5 = var'\\tilde{g}'
printbr(g5'_uv', '= 5D metric tensor')
printbr(g5'_ab':eq(
	Tensor('_ab',
		{g5'_\\alpha _\\beta', g5'_\\alpha _5'},
		{g5'_5 _\\beta', g5'_55'}
	)
))

local g5_def = Tensor('_ab',
	{g'_\\alpha _\\beta' + phi^2 * A' _\\alpha' * A' _\\beta', phi^2 * A' _\\alpha' * A'_5'},
	{phi^2 * A' _\\beta' * A'_5', phi^2 * (A'_5')^2}
)

-- TODO in the print function, for variables with indexes of numbers that are raised to powers,
-- or with variables with numbers
-- make sure to wrap the variable and indexes in ()'s
printbr(g5'_ab':eq(g5_def))

--[[ omit A_5
printbr'Notice that I included the $A_5$ terms to show the units align.  From here on I will omit them since their value is 1.'

g5_def = g5_def:replace(A'_5', 1)()
printbr(g5'_ab':eq(g5_def))
--]]
printbr()


printbr(g5'^uv', '= 5D metric inverse')
--[[
local g5U_def = Tensor('^ab',
	{g'^\\alpha ^\\beta', -g'^\\alpha ^\\mu' * A' _\\mu'},
	{-g'^\\beta ^\\mu' * A' _\\mu', g'^\\mu ^\\nu' * A' _\\mu' * A' _\\nu' + 1/phi^2}
)
printbr(g5'^ab':eq(g5U_def))
--]]
printbr'Notice, if you see a raised 4-index, it is being raised by the 4-metric and not the 5-metric.'

local g5U_def = Tensor('^ab',
	{g'^\\alpha ^\\beta', -A' ^\\alpha' / A'_5'},
	{-A' ^\\beta' / A'_5', (A' _\\mu' * A' ^\\mu' + phi^-2)  * (A'_5')^-2}
)
printbr(g5'^ab':eq(g5U_def))
printbr()

local delta = var'\\delta'
local delta5_from_g5_def = 
	(
		g5_def'_ac'():reindex{ [' \\beta'] = ' \\gamma'}
		* g5U_def'^cb'():reindex{ [' \\alpha'] = ' \\gamma'}
	)() 
		:replace(A' _\\gamma' * g' ^\\gamma ^\\beta', A' ^\\beta')
		:replace(A' ^\\gamma' * g' _\\alpha _\\gamma', A' _\\alpha')
		:replace(g' ^\\gamma ^\\beta' * g' _\\alpha _\\gamma', delta' _\\alpha ^\\beta')
		:tidyIndexes{fixed=' \\alpha \\beta'}
printbr((g5'_ac' * g5'^cb'):eq(delta5_from_g5_def):eq(delta5_from_g5_def()))
printbr()


printbr'The cylindrical constraint is'
local cylConstraint = g5'_ab,5':eq(0)
printbr(cylConstraint)
printbr'Therefore'
--printbr(cylConstraint:splitOffDerivIndexes():replace(g5'_ab', g5_def)())
-- TODO matrix with index comma derivative -> simplify to -> matrix components with index comma derivative
-- (seems this is a dilemma with scalar comma derivatives vs constant comma derivatives as well)
printbr(Array:lambda({2,2}, function(a,b) return g5_def[a][b]'_,5'() end):eq(0))

-- TODO this can be derived, in order its presented, using the matrix equality
printbr'Therefore, if $A_{5,5} = 0$ then we find:'
printbr(phi'_,5':eq(0))
printbr(A' _\\mu _,5':eq(0))
printbr(g' _\\alpha _\\beta _,5':eq(0))
printbr()

printbr"For now I'll use a constant scalar as well"
printbr(phi'_,a':eq(0))
printbr()

printbr'metric partial:'
local dg5_2x2_def = Tensor('_ab', function(a,b)
	return g5_def[a][b]'_,c'()
		:replace(phi'_,c', 0)()
end)
printbr(g5'_ab,c':eq(dg5_2x2_def))

-- indexed [c][a][b]
local dg5_def = Tensor('_cab', function(c,a,b)
	if c == 1 then
		return dg5_2x2_def[a][b]:reindex{c=' \\gamma'}
	elseif c == 2 then
		return dg5_2x2_def[a][b]:reindex{c=5}():map(function(x)
			if TensorRef.is(x) and x:hasDerivIndex(5) then return 0 end
		end)()
	end
end):map(function(x)
	if TensorRef.is(x) and x[1] == A and x[2].symbol == 5 and x[3] and x[3].derivative then return 0 end
end)()
printbr(g5'_ab,c':eq(dg5_def))
printbr()

-- alright, here we do the same exact index gymnastics as with dense tensors
-- hence the original motivation for mixed indexes (which is a bit of a clusterfuck, so I haven't finished it).

printbr'lower connection'
local conn5 = var'\\tilde{\\Gamma}'
local conn5L_def = Tensor('_abc', function(a,b,c)
	return (frac(1,2) * (
		-- g_ab,c
		dg5_def[c][a][b]	
		-- + g_ac,b
		+ dg5_def[b][a][c]:reindex{[' \\beta \\gamma'] = ' \\gamma \\beta'}
		-- - g_bc,a
		- dg5_def[a][b][c]:reindex{[' \\alpha \\beta \\gamma'] = ' \\beta \\gamma \\alpha'}
	))()
end)
printbr(conn5'_abc':eq(conn5L_def))

local F = var'F'
local conn4 = var'\\Gamma'
conn5L_def = conn5L_def:replace(
	(g' _\\alpha _\\beta _,\\gamma' + g' _\\alpha _\\gamma _,\\beta' - g' _\\beta _\\gamma _,\\alpha')(), 
	2 * conn4'_\\alpha _\\beta _\\gamma'
)()
--[[ TODO ... this only seems to make things worse.  seems it is replacing too many A_alpha,gamma's
conn5L_def = conn5L_def:replaceIndex(
	A' _\\alpha _,\\gamma',
	F'_\\gamma _\\alpha' + A' _\\gamma _,\\alpha'
)()
--]]
-- [[
conn5L_def = conn5L_def:replace(
	A' _\\alpha _,\\beta',
	F'_\\beta _\\alpha' + A' _\\beta _,\\alpha'
)()
conn5L_def = conn5L_def:replace(
	A' _\\alpha _,\\gamma',
	F'_\\gamma _\\alpha' + A' _\\gamma _,\\alpha'
)()
--]]
printbr(conn5'_abc':eq(conn5L_def))
printbr()


printbr'upper connection'
local conn5U_def = (
	g5U_def'^ae':reindex{[' \\beta'] = ' \\epsilon'}()
	* conn5L_def'_ebc':reindex{[' \\alpha'] = ' \\epsilon'}()
)
printbr(conn5'^a_bc':eq(conn5U_def))
conn5U_def = conn5U_def()
printbr(conn5'^a_bc':eq(conn5U_def))
conn5U_def = conn5U_def:replace(
	g' ^\\alpha ^\\epsilon' * conn4' _\\epsilon _\\beta _\\gamma',
	conn4' ^\\alpha _\\beta _\\gamma'
)()
conn5U_def = conn5U_def:replace(
	A' ^\\epsilon' * conn4' _\\epsilon _\\beta _\\gamma',
	A' _\\epsilon' * conn4' ^\\epsilon _\\beta _\\gamma'
)()

conn5U_def = conn5U_def:replace(
	F' _\\beta _\\epsilon' * g' ^\\alpha ^\\epsilon',
	F' _\\beta ^\\alpha'
)()
conn5U_def = conn5U_def:replace(
	F' _\\gamma _\\epsilon' * g' ^\\alpha ^\\epsilon',
	F' _\\gamma ^\\alpha'
)()
conn5U_def = conn5U_def:replace(
	A' _\\epsilon' * g' ^\\alpha ^\\epsilon',
	A' ^\\alpha'
)()
conn5U_def = conn5U_def:reindex{[' \\epsilon'] = ' \\mu'}()
conn5U_def = conn5U_def:replace(
	A' ^\\mu' * F' _\\gamma _\\mu',
	A' _\\mu' * F' _\\gamma ^\\mu'
)()
conn5U_def = conn5U_def:replace(
	A' ^\\mu' * F' _\\beta _\\mu',
	A' _\\mu' * F' _\\beta ^\\mu'
)()
printbr(conn5'^a_bc':eq(conn5U_def))
printbr()



local d2x_ds2 = var'\\ddot{x}'
local dx_ds = var'\\dot{x}'

printbr()
printbr'geodesic:'
local geodesicEqn = (d2x_ds2'^a' + conn5'^a_bc' * dx_ds'^b' * dx_ds'^c'):eq(0)
printbr(geodesicEqn)
printbr()

printbr'only look at spacetime components:'
geodesicEqn = geodesicEqn:replace(
	conn5'^a_bc' * dx_ds'^b' * dx_ds'^c',
	conn5' ^\\alpha _\\beta _\\gamma' * dx_ds' ^\\beta' * dx_ds' ^\\gamma'
		--+ conn5' ^\\alpha _5 _\\gamma' * dx_ds'^5' * dx_ds' ^\\gamma'
		+ 2 * conn5' ^\\alpha _\\beta _5' * dx_ds' ^\\beta' * dx_ds'^5'
		+ conn5' ^\\alpha _5 _5' * dx_ds'^5' * dx_ds'^5'
):replace(d2x_ds2'^a', d2x_ds2' ^\\alpha')
()
printbr(geodesicEqn)

geodesicEqn = geodesicEqn:replace(
	conn5' ^\\alpha _\\beta _\\gamma',
	conn5U_def[1][1][1]
)()
geodesicEqn = geodesicEqn:replace(
	conn5' ^\\alpha _\\beta _5',
	conn5U_def[1][1][2]
)()
geodesicEqn = geodesicEqn:replace(
	conn5' ^\\alpha _5 _\\gamma',
	conn5U_def[1][2][1]
)()
geodesicEqn = geodesicEqn:replace(
	conn5' ^\\alpha _5 _5',
	conn5U_def[1][2][2]
)()
geodesicEqn = geodesicEqn:replace(
	(phi^2 * A' _\\gamma' * dx_ds' ^\\beta' * dx_ds' ^\\gamma' * F' _\\beta ^\\alpha')(),
	phi^2 * A' _\\beta' * dx_ds' ^\\beta' * dx_ds' ^\\gamma' * F' _\\gamma ^\\alpha'
)()
printbr(geodesicEqn)

printbr[[Let $\dot{x}^5 = \frac{q}{m} \sqrt{\frac{k_e}{G}}, A_5 = c \sqrt{\frac{k_e}{G}}, \phi = \frac{1}{c} \sqrt{\frac{G}{k_e}}$]]
local mass = var'M'
local q = var'q'
geodesicEqn = geodesicEqn:replace(
	dx_ds'^5',
	--var'\\frac{q}{m} \\sqrt{\\frac{k_e}{G}}'	--frac(q, var'm')	-- using a var so it doesn't combine with other terms
	frac(q, mass) * sqrt(frac(k_e, G))
):replace(
	phi,
	frac(1, c) * sqrt(frac(G, k_e))
):replace(
	A'_5',
	c * sqrt(frac(k_e, G))
)():factorDivision()
printbr(geodesicEqn)
printbr()
printbr'There you have gravitational force, Lorentz force, and an extra term.'
printbr()

printbr'separate space and time, substitute spacetime geodesic with Newtonian gravity, etc:'
printbr()

-- this should replace all terms, summed together ... unless they are multiplied, then replace the multiplication as a whole
function splitIndexes(expr, splitMap)
	return symmath.map(expr, function(term)
		if symmath.op.add.is(term) then
			local newAdd = table()
			for i,x in ipairs(term) do
				local forThisTerm = table{x:clone()}
				local fixed, summed = x:getIndexesUsed()
--printbr('fixed', #fixed, fixed:mapi(tostring):concat', ')
--printbr('summed', #summed, summed:mapi(tostring):concat', ')
--printbr('element within add op:', x)
				for _,s in ipairs(summed) do
					local newForThisTerm = table()
--printbr('finding symbol in splitMap '..s.symbol)						
assert(splitMap[s.symbol], "failed to find split for symbol "..s.symbol)
					for _,repl in ipairs(splitMap[s.symbol]) do
--printbr('...replacing symbol with '..repl)						
						-- TODO between strings, numbers, and multi-char symbols, right now the symbol system is a mess
						local symbol = s.symbol
						if type(symbol) == 'string' and #symbol > 1 then symbol = ' '..symbol end
						newForThisTerm:append(
							forThisTerm:mapi(function(y)
--printbr('replacing indexes in term ', y)
								return y:reindex{[symbol]=repl}
							end)
						)
					end
					forThisTerm = newForThisTerm
				end
				newAdd:append(forThisTerm)
			end
			return #newAdd == 1 and newAdd[1] or symmath.op.add(newAdd:unpack())
		end
	end)
end

printbr'spatial evolution:'
local spatialGeodesicEqn = geodesicEqn:reindex{[' \\alpha']='i'}
printbr(spatialGeodesicEqn)
printbr'splitting spacetime indexes into space+time'
spatialGeodesicEqn = splitIndexes(spatialGeodesicEqn, {['\\beta'] = {0, 'j'}, ['\\gamma'] = {0, 'k'}})
spatialGeodesicEqn = (spatialGeodesicEqn * c^2)():factorDivision()
printbr(spatialGeodesicEqn)
printbr('low-velocity approximation:', dx_ds'^0':eq(1))
spatialGeodesicEqn = spatialGeodesicEqn:replace(dx_ds'^0', 1)():factorDivision()
printbr(spatialGeodesicEqn)
printbr('assume spacetime connection is only', conn4'^i_00')
local E = var'E'
printbr('assume', F'_0^i':eq(-frac(1,c) * E'^i'))
local epsilon = var'\\epsilon'
local B = var'B'
printbr('assume', F'_i^j':eq(epsilon'_i^jk' * B'_k'))
spatialGeodesicEqn = spatialGeodesicEqn
	:replace(conn4'^i_j0', 0)
	:replace(conn4'^i_0k', 0)
	:replace(conn4'^i_jk', 0)
	:replace(F'_0^i', -frac(1,c) * E'^i')
	:replace(F'_j^i', epsilon'^i_jl' * B'^l')
	:replace(F'_k^i', epsilon'^i_kl' * B'^l')
	--():factorDivision()
spatialGeodesicEqn = betterSimplify(spatialGeodesicEqn)
printbr(spatialGeodesicEqn)

local phi_q = var('\\phi_q')
printbr('assume', A'_0':eq(frac(1,c) * phi_q), 'is the electric field potential')
spatialGeodesicEqn = betterSimplify(spatialGeodesicEqn
	:replace(A'_0', frac(1,c) * phi_q)
)
printbr(spatialGeodesicEqn)
local r = var'r'
local mass2 = var'M_2'
printbr('assume', conn4'^i_00':eq( frac(G * mass2 * var'x''^i', c^2 * r^3 )))
spatialGeodesicEqn = spatialGeodesicEqn
	:replace(conn4'^i_00', frac(G * mass2 * var'x''^i', c^2 * r^3 ))
	():factorDivision()
printbr(spatialGeodesicEqn)

--[[
printbr'time evolution:'
local timeGeodesicEqn = geodesicEqn:reindex{[' \\alpha']=0}
printbr(timeGeodesicEqn)
timeGeodesicEqn = splitIndexes(timeGeodesicEqn, {['\\beta'] = {0, 'j'}, ['\\gamma'] = {0, 'k'}})
printbr(timeGeodesicEqn)
printbr()

printbr(spatialGeodesicEqn)
printbr()

printbr'TODO 5th dimension evolution:'
printbr()
--]]

printbr('For an electron,', units.m_e_in_kg, ',', units.e_in_C)

-- TODO like maxima, :simplify{scopeVars}
symmath.simplifyConstantPowers = true
local elec_q_sqrt_ke_over_m_sqrt_G = (units.e_in_C:rhs() / units.m_e_in_kg:rhs()):subst(kg_in_C)()

printbr('so $\\frac{q}{m} \\sqrt{\\frac{k_e}{G}} = $', 
	elec_q_sqrt_ke_over_m_sqrt_G 
	'=', 
	(elec_q_sqrt_ke_over_m_sqrt_G * units.c_in_m_s:rhs())()
)
symmath.simplifyConstantPowers = false

printbr()


printbr'connection partial:'
local dconn5_2x2x2_def = Tensor('^a_bc', function(a,b,c)
	return betterSimplify(conn5U_def[a][b][c]',d'()
		:replace(phi'_,d', 0)()
		:map(function(x)
			if TensorRef.is(x) and x[1] == A and x[2].symbol == 5 and x[3] and x[3].derivative then return 0 end
		end))
end)
printbr(conn5'^a_bc,d':eq(dconn5_2x2x2_def))

local dconn5U_def = Tensor('^a_bcd', function(a,b,c,d)
	if d == 1 then
		return dconn5_2x2x2_def[a][b][c]:reindex{d=' \\delta'}
	elseif d == 2 then
		return dconn5_2x2x2_def[a][b][c]:reindex{d=5}
	end
end):map(function(x)
	if TensorRef.is(x) and x:hasDerivIndex(5) then return 0 end
end)()
dconn5U_def = betterSimplify(dconn5U_def)
printbr(conn5'^a_bc,d':eq(dconn5U_def))
printbr()


local conn5USq_def = 
	conn5U_def'^a_ec'():reindex{[' \\beta'] = ' \\epsilon'}
	* conn5U_def'^e_bd'():reindex{[' \\alpha \\gamma \\mu'] = ' \\epsilon \\delta \\nu'}
printbr((conn5'^a_be' * conn5'^e_cd'):eq(conn5USq_def))
conn5USq_def = conn5USq_def():permute'abcd'
conn5USq_def = betterSimplify(conn5USq_def)
printbr((conn5'^a_be' * conn5'^e_cd'):eq(conn5USq_def))
printbr()


-- TODO Riemann5_def[1][1][1][2] can replace A_5 F_beta^alpha_,gamma + ... with A_5 F_beta^alpha_;gamma
printbr'Riemann curvature tensor:'
local R = var'R'
local R5 = var'\\tilde{R}'
printbr(R5'^a_bcd':eq( conn5'^a_bd,c' - conn5'^a_bc,d' + conn5'^a_ec'*conn5'^e_bd' - conn5'^a_ed'*conn5'^e_bc' ))

local Riemann5_def = Tensor('^a_bcd', function(a,b,c,d)
	return (
		dconn5U_def[a][b][d][c]:reindex{[' \\gamma \\delta'] = ' \\delta \\gamma'}
		- dconn5U_def[a][b][c][d]
		+ conn5USq_def[a][b][c][d]
		- conn5USq_def[a][b][d][c]:reindex{[' \\gamma \\delta'] = ' \\delta \\gamma'}
	)
	:simplify()
end)

Riemann5_def = Riemann5_def
	:replace( A' _\\beta _,\\delta _,\\gamma', A' _\\beta _,\\gamma _,\\delta')	
	:replace( A' _\\delta _,\\beta _,\\gamma', F' _\\gamma _\\delta _,\\beta' + A' _\\gamma _,\\beta _,\\delta')
	:simplify()

Riemann5_def = Riemann5_def
	:replace(
		conn4' ^\\alpha _\\beta _\\delta _,\\gamma',
		R' ^\\alpha _\\beta _\\gamma _\\delta'
		+ conn4' ^\\alpha _\\beta _\\gamma _,\\delta'
		- conn4' ^\\epsilon _\\beta _\\delta' * conn4' ^\\alpha _\\epsilon _\\gamma'
		+ conn4' ^\\epsilon _\\beta _\\gamma' * conn4' ^\\alpha _\\epsilon _\\delta'
	)()
	:replace(
		A' _\\mu' * conn4' ^\\mu _\\beta _\\delta _,\\gamma' ,
		A' _\\mu' * R' ^\\mu _\\beta _\\gamma _\\delta'
		+ A' _\\mu' * conn4' ^\\mu _\\beta _\\gamma _,\\delta'
		- A' _\\mu' * conn4' ^\\epsilon _\\beta _\\delta' * conn4' ^\\mu _\\epsilon _\\gamma'
		+ A' _\\mu' * conn4' ^\\epsilon _\\beta _\\gamma' * conn4' ^\\mu _\\epsilon _\\delta'
	)()
	:replace(
		A' _\\delta _,\\beta',
		F' _\\beta _\\delta' + A' _\\beta _,\\delta'
	)()
	:replace(
		A' _\\beta _,\\gamma',
		F' _\\gamma _\\beta' + A' _\\gamma _,\\beta'
	)()
	:replace(
		A' _\\delta _,\\gamma',
		F' _\\gamma _\\delta' + A' _\\gamma _,\\delta'
	)()
	:replace(
		A' _\\delta _,\\epsilon',
		F' _\\epsilon _\\delta' + A' _\\epsilon _,\\delta'
	)()
	:replace(
		A' _\\gamma _,\\epsilon',
		F' _\\epsilon _\\gamma' + A' _\\epsilon _,\\gamma'
	)()

Riemann5_def = Riemann5_def:symmetrizeIndexes(conn4, {2,3})()
Riemann5_def = betterSimplify(Riemann5_def)
printbr(R5'^a_bcd':eq(Riemann5_def))
printbr()


Riemann5_def[1][1][1][1] = Riemann5_def[1][1][1][1]:reindex{[' \\nu'] = ' \\epsilon'}()
Riemann5_def[1][1][1][2] = Riemann5_def[1][1][1][2]:reindex{[' \\nu'] = ' \\epsilon'}()
Riemann5_def[1][1][2][1] = Riemann5_def[1][1][2][1]:reindex{[' \\nu'] = ' \\epsilon'}()

Riemann5_def = (Riemann5_def
	:replace(
		F' _\\delta ^\\alpha _,\\gamma',
		- F' _\\delta ^\\epsilon' * conn4' ^\\alpha _\\epsilon _\\gamma' 
		+ F' _\\epsilon ^\\alpha' * conn4' ^\\epsilon _\\gamma _\\delta'
		+ F' _\\delta ^\\alpha _;\\gamma'
	)
	:replace(
		F' _\\gamma ^\\alpha _,\\delta',
		- F' _\\gamma ^\\epsilon' * conn4' ^\\alpha _\\epsilon _\\delta' 
		+ F' _\\epsilon ^\\alpha' * conn4' ^\\epsilon _\\gamma _\\delta'
		+ F' _\\gamma ^\\alpha _;\\delta'
	)
	:replace(
		F' _\\beta ^\\alpha _,\\gamma',
		- F' _\\beta ^\\epsilon' * conn4' ^\\alpha _\\epsilon _\\gamma'
		+ F' _\\epsilon ^\\alpha' * conn4' ^\\epsilon _\\beta _\\gamma'
		+ F' _\\beta ^\\alpha _;\\gamma'
	)
	:replace(
		F' _\\beta ^\\alpha _,\\delta',
		- F' _\\beta ^\\epsilon' * conn4' ^\\alpha _\\epsilon _\\delta'
		+ F' _\\epsilon ^\\alpha' * conn4' ^\\epsilon _\\beta _\\delta'
		+ F' _\\beta ^\\alpha _;\\delta'
	)
	:replace(
		F' _\\delta ^\\mu _,\\gamma',
		- F' _\\delta ^\\epsilon' * conn4' ^\\mu _\\epsilon _\\gamma'
		+ F' _\\epsilon ^\\mu' * conn4' ^\\epsilon _\\delta _\\gamma'
		+ F' _\\delta ^\\mu _;\\gamma'
	)
	:replace(
		F' _\\gamma ^\\mu _,\\delta',
		- F' _\\gamma ^\\epsilon' * conn4' ^\\mu _\\epsilon _\\delta'
		+ F' _\\epsilon ^\\mu' * conn4' ^\\epsilon _\\gamma _\\delta'
		+ F' _\\gamma ^\\mu _;\\delta'
	)
	:replace(
		F' _\\beta ^\\mu _,\\delta',
		- F' _\\beta ^\\epsilon' * conn4' ^\\mu _\\epsilon _\\delta'
		+ F' _\\epsilon ^\\mu' * conn4' ^\\epsilon _\\beta _\\delta'
		+ F' _\\beta ^\\mu _;\\delta'
	)
	:replace(
		F' _\\beta ^\\mu _,\\gamma',
		- F' _\\beta ^\\epsilon' * conn4' ^\\mu _\\epsilon _\\gamma'
		+ F' _\\epsilon ^\\mu' * conn4' ^\\epsilon _\\beta _\\gamma'
		+ F' _\\beta ^\\mu _;\\gamma'
	)
	:replace(
		F' _\\gamma _\\delta _,\\beta',
		F' _\\epsilon _\\delta' * conn4' ^\\epsilon _\\beta _\\gamma'
		- F' _\\epsilon _\\gamma' * conn4' ^\\epsilon _\\beta _\\delta'
		+ F' _\\gamma _\\delta _;\\beta'
	)()

)()
Riemann5_def = Riemann5_def:symmetrizeIndexes(conn4, {2,3})()
Riemann5_def = betterSimplify(Riemann5_def)

-- TODO honestly I should be doing this much earlier
Riemann5_def = Riemann5_def:tidyIndexes{fixed=' \\alpha \\beta \\gamma \\delta'}

Riemann5_def = betterSimplify(Riemann5_def)
printbr(R5'^a_bcd':eq(Riemann5_def))
printbr()


-- TODO a 'safeReindex' or a 'relabelToUnusedIndex' function: same as reindex, but errors if the new destination index is already present
printbr'Ricci tensor:'
local Ricci5_def = Riemann5_def'^e_aeb'()
	:reindex{[' \\alpha \\beta \\gamma \\delta'] = ' \\sigma \\alpha \\sigma \\beta'}
	:replace(R' ^\\sigma _\\alpha _\\sigma _\\beta', R' _\\alpha _\\beta')
	:replace(F' _\\sigma ^\\sigma', 0)()
	:replace(F' _\\gamma ^\\gamma _;\\beta', 0)()
	:replace(F' _\\sigma ^\\sigma _;\\beta', 0)()

Ricci5_def = Ricci5_def:symmetrizeIndexes(conn4, {2,3})()
Ricci5_def = Ricci5_def:tidyIndexes{fixed=' \\alpha \\beta'}()
	
printbr(R5'_ab':eq(R5'^c_acb'))
printbr()
printbr(R5'_ab':eq(Ricci5_def))
printbr()


printbr'Gaussian curvature:'

local Gaussian5_def = (Ricci5_def'_ab' * g5U_def'^ab')()

Gaussian5_def = Gaussian5_def:replace(R' _\\alpha _\\beta' * g' ^\\alpha ^\\beta', R)()
Gaussian5_def = Gaussian5_def:tidyIndexes()()
Ricci5_def = Ricci5_def:symmetrizeIndexes(g, {1,2})()

Gaussian5_def = Gaussian5_def:replace( (A' _\\zeta' * g' ^\\zeta ^\\epsilon')(), A' ^\\epsilon' )()
Gaussian5_def = Gaussian5_def:replace( (A' _\\epsilon' * g' ^\\zeta ^\\epsilon')(), A' ^\\zeta' )()
Gaussian5_def = Gaussian5_def:replace( (A' _\\epsilon' * g' ^\\epsilon ^\\zeta')(), A' ^\\zeta' )()
Gaussian5_def = Gaussian5_def:replace( (F' _\\zeta _\\eta' * g' ^\\eta ^\\epsilon')(), F' _\\zeta ^\\epsilon' )()
Gaussian5_def = Gaussian5_def:replace( (F' _\\zeta _\\epsilon' * g' ^\\eta ^\\epsilon')(), F' _\\zeta ^\\eta' )()
Gaussian5_def = Gaussian5_def:tidyIndexes()()

Gaussian5_def = Gaussian5_def:reindex{[' \\alpha \\beta'] = ' \\mu \\nu'}	-- don't use alpha beta gamma delta, or anything already used in Ricci5_def ... in fact, add in an extra property for fixed indexes

printbr(R5:eq(Gaussian5_def))
printbr()


printbr'Einstein curvature:'
local G5 = var'\\tilde{G}'
local Einstein_def = (Ricci5_def'_ab' - frac(1,2) * Gaussian5_def * g5_def'_ab')()
Einstein_def = Einstein_def:tidyIndexes{fixed=' \\alpha \\beta'}()
Einstein_def = betterSimplify(Einstein_def
	:replace( F' _\\beta ^\\epsilon' * F' _\\epsilon _\\alpha',  -F' _\\beta _\\epsilon' * F' _\\alpha ^\\epsilon' )
	:replace( F' _\\epsilon _\\beta', -F' _\\beta _\\epsilon')
)
printbr(G5'_ab':eq(Einstein_def))
printbr()


-- TODO check units here
-- TODO build this better?  or just rho/c^2 u_a u_b + P g5_ab ?
printbr'stress-energy tensor:'

local rho = var'\\rho'
local p = var'p'
local T5_def = Tensor('_ab', 
	{
		c^2 * rho * dx_ds' _\\alpha' * dx_ds' _\\beta' + p * g5' _\\alpha _\\beta',
		c^2 * rho * dx_ds' _\\alpha' * dx_ds'_5' + p * g5' _\\alpha _5',
	},
	{
		c^2 * rho * dx_ds' _\\beta' * dx_ds'_5' + p * g5' _\\beta _5',
		c^2 * rho * (dx_ds'_5')^2 + p * g5'_55'
	}
)
local T5 = var'\\tilde{T}'
printbr(T5'_ab':eq(c^2 * rho * dx_ds'_a' * dx_ds'_b' + p*g5'_ab'))
printbr(T5:eq(T5_def))
T5_def = betterSimplify(
	T5_def
		:replace(dx_ds'_5', frac(q, mass) * sqrt(k_e, G))
		:replace(g5' _\\alpha _\\beta', g5_def[1][1])
		:replace(g5' _\\alpha _5', g5_def[1][2])
		:replace(g5' _\\beta _5', g5_def[2][1])
		:replace(g5'_55', g5_def[2][2])
		:replace(A'_5', c * sqrt(frac(k_e, G)))
		:replace(phi, frac(1,c) * sqrt(frac(G, k_e)))
)
printbr(T5:eq(T5_def))


-- TODO now compare G_u5 = 8 pi T_u5


printbr()
printbr()
print(export.MathJax.footer)
