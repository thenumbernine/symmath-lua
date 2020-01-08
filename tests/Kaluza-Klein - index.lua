#!/usr/bin/env luajit
require 'ext'
require 'symmath'.setup{MathJax={title='Kaluza-Klein - index notation'}}

-- this sets simplifyConstantPowers 
local units = require 'symmath.physics.units'()

-- units
local m = units.m
local s = units.s
local kg = units.kg
local C = units.C



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
printbr(sqrt(units.k_e / units.G):eq( kg_C_eq_1 ), ' = conversion from kg to C')
local kg_in_C = kg_C_eq_1:solve(kg)
printbr(kg_in_C)


Tensor.coords{{variables={'txyz','5'}}}

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

local greekSymbols = symmath.export.Console.greekSymbols
--[[
:sort(function(a,b)
	return a < b
end)
--]]
:filter(function(s)
	return s:match'^[a-z]'
end):mapi(function(s)
	return '\\'..s
end)

local delta = var'\\delta'
printbr((g5'_ac' * g5'^cb'):eq( (
		g5_def'_ac'():reindex{ [' \\beta'] = ' \\gamma'}
		* g5U_def'^cb'():reindex{ [' \\alpha'] = ' \\gamma'}
	)() 
		:replace(A' _\\gamma' * g' ^\\gamma ^\\beta', A' ^\\beta')()
	--	:replace(A' _\\gamma' * A' ^\\gamma', A' _\\mu' * A' ^\\mu')()
		:replace(A' ^\\gamma' * g' _\\alpha _\\gamma', A' _\\alpha')()
		:replace(g' ^\\gamma ^\\beta' * g' _\\alpha _\\gamma', delta' _\\alpha ^\\beta')()
	)
	:tidyIndexes{symbols=greekSymbols, fixed=' \\alpha \\beta'}
)
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
-- TODO's on replace ...
-- replace(A_alpha,beta - A_beta,alpha => F_beta,alpha) works with expressions that completely match, but not larger commutative expressions that partially match
-- replaceIndex(same) only seems to work when the indexes 
--[[
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
conn5U_def = conn5U_def:replace(
	(A' _\\epsilon' * A' ^\\epsilon')(),
	A' _\\mu' * A' ^\\mu'
)()
conn5U_def = conn5U_def:reindex{[' \\epsilon'] = ' \\mu'}
printbr(conn5'^a_bc':eq(conn5U_def))
printbr()



local d2x_ds2 = var'\\ddot{x}'
local dx_ds = var'\\dot{x}'

printbr'geodesic'
local geodesicEqn = (d2x_ds2'^a' + conn5'^a_bc' * dx_ds'^b' * dx_ds'^c'):eq(0)
printbr(geodesicEqn)

geodesicEqn = geodesicEqn:replace(
	conn5'^a_bc' * dx_ds'^b' * dx_ds'^c',
	conn5' ^\\alpha _\\beta _\\gamma' * dx_ds' ^\\beta' * dx_ds' ^\\gamma'
		--+ conn5' ^\\alpha _5 _\\gamma' * dx_ds'^5' * dx_ds' ^\\gamma'
		+ 2 * conn5' ^\\alpha _\\beta _5' * dx_ds' ^\\beta' * dx_ds'^5'
		+ conn5' ^\\alpha _5 _5' * dx_ds'^5' * dx_ds'^5'
)()
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

printbr'Let $\\dot{x}^5 = \\frac{q}{m} \\sqrt{\\frac{k_e}{G}}$'
geodesicEqn = geodesicEqn:replace(
	dx_ds'^5',
	var'\\frac{q}{m} \\sqrt{\\frac{k_e}{G}}'	--frac(var'q', var'm')	-- using a var so it doesn't combine with other terms
)()
printbr(geodesicEqn)

printbr('For an electron,', units.m_e_in_kg, ',', units.e_in_C)

-- TODO like maxima, :simplify{scopeVars}
symmath.simplifyConstantPowers = true
printbr('so $\\frac{q}{m} \\sqrt{\\frac{k_e}{G}} = $', 
	(units.e_in_C:rhs() / units.m_e_in_kg:rhs()):subst(kg_in_C)()
)
symmath.simplifyConstantPowers = false

printbr()
printbr'There you have gravitational force, Lorentz force, and an extra term.'
printbr()


printbr'connection partial:'
local dconn5_2x2x2_def = Tensor('^a_bc', function(a,b,c)
	return conn5U_def[a][b][c]',d'()
		:replace(phi'_,d', 0)()
		:map(function(x)
			if TensorRef.is(x) and x[1] == A and x[2].symbol == 5 and x[3] and x[3].derivative then return 0 end
		end)()
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
printbr(conn5'^a_bc,d':eq(dconn5U_def))
printbr()


local conn5USq_def = 
	conn5U_def'^a_ec'():reindex{[' \\beta'] = ' \\epsilon'}
	* conn5U_def'^e_bd'():reindex{[' \\alpha \\gamma \\mu'] = ' \\epsilon \\delta \\nu'}
printbr((conn5'^a_be' * conn5'^e_cd'):eq(conn5USq_def))
conn5USq_def = conn5USq_def():permute'abcd'
printbr((conn5'^a_be' * conn5'^e_cd'):eq(conn5USq_def))
printbr()


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
		A' _\\mu' * conn4' ^\\mu _\\beta _\\delta _,\\gamma' ,
		A' _\\mu' * R' ^\\mu _\\beta _\\gamma _\\delta'
		+ A' _\\mu' * conn4' ^\\mu _\\beta _\\gamma _,\\delta'
		- A' _\\mu' * conn4' ^\\epsilon _\\beta _\\delta' * conn4' ^\\mu _\\epsilon _\\gamma'
		+ A' _\\mu' * conn4' ^\\epsilon _\\beta _\\gamma' * conn4' ^\\mu _\\epsilon _\\delta'
	)()

--[[
--	:replace(F' _\\delta ^\\alpha _;\\gamma', F' _\\delta ^\\alpha _,\\gamma' - )
--	:simplify()

Riemann5_def[1][1][2][1] = (Riemann5_def[1][1][2][1] 
	- frac(1,4) * phi^4 * A' ^\\mu' * F' _\\beta _\\mu' * F' _\\delta ^\\alpha'
	+ frac(1,4) * phi^4 * A' _\\epsilon' * F' _\\beta ^\\epsilon' * F' _\\delta ^\\alpha'
)()

Riemann5_def[2][1][1][1] = (Riemann5_def[2][1][1][1] 
	+ frac(1,2) * A' _\\epsilon _,\\delta' * conn4' ^\\epsilon _\\beta _\\gamma'
	- frac(1,2) * A' _\\mu _,\\delta' * conn4' ^\\mu _\\beta _\\gamma'
	
	- frac(1,2) * A' _\\epsilon _,\\gamma' * conn4' ^\\epsilon _\\beta _\\delta'
	+ frac(1,2) * A' _\\mu _,\\gamma' * conn4' ^\\mu _\\beta _\\delta'

	+ frac(1,2) * (
		A' _\\delta _,\\epsilon' * conn4' ^\\epsilon _\\beta _\\gamma'
		- A' _\\mu _,\\delta' * conn4' ^\\mu _\\beta _\\gamma'
	)
	- frac(1,2) * F' _\\mu _\\delta' * conn4' ^\\mu _\\beta _\\gamma'

	- frac(1,2) * (
		A' _\\gamma _,\\epsilon' * conn4' ^\\epsilon _\\beta _\\delta'
		- A' _\\mu _,\\gamma' * conn4' ^\\mu _\\beta _\\delta'
	)
	+ frac(1,2) * F' _\\mu _\\gamma' * conn4' ^\\mu _\\beta _\\delta'

	- frac(1,4) * phi^4 * A' ^\\mu' * A' _\\beta' * A' _\\epsilon' * F' _\\delta _\\mu' * F' _\\gamma ^\\epsilon'
	+ frac(1,4) * phi^4 * A' ^\\mu' * A' _\\beta' * A' _\\epsilon' * F' _\\delta ^\\epsilon' * F' _\\gamma _\\mu'
)()
	:replace( A' _\\delta _,\\gamma', F' _\\gamma _\\delta' + A' _\\gamma _,\\delta')
	:replace( A' _\\beta _,\\gamma', F' _\\gamma _\\beta' + A' _\\gamma _,\\beta')
	:replace( A' _\\beta _,\\delta', F' _\\delta _\\beta' + A' _\\delta _,\\beta')
	:simplify()
--]]

printbr(R5'^a_bcd':eq(Riemann5_def))
printbr()

os.exit()

printbr'Ricci tensor:'
local Ricci5_def = Riemann5_def'^e_aeb'()
	:reindex{[' \\alpha \\beta \\gamma \\delta'] = ' \\sigma \\alpha \\sigma \\beta'}
	:replace(R' ^\\sigma _\\alpha _\\sigma _\\beta', R' _\\alpha _\\beta')
	:replace(F' _\\sigma ^\\sigma', 0)()
	:replace(F' _\\sigma ^\\sigma _,\\beta', 0)()
	
	-- hmm, not working so well...
	-- even if it was, I would have to add the ability to tell this function which symbols to use (to avoid the 5D symbols)
	--:tidyIndexes()()

Ricci5_def[1][1] = (Ricci5_def[1][1]
	+ frac(1,4) * phi^4 * A' ^\\mu' * A' _\\alpha' * F' _\\epsilon _\\mu' * F' _\\beta ^\\epsilon'
	- frac(1,4) * phi^4 * A' ^\\mu' * A' _\\alpha' * F' _\\sigma _\\mu' * F' _\\beta ^\\sigma'
	
	- frac(1,4) * phi^4 * A' ^\\mu' * A' _\\epsilon' * F' _\\beta _\\mu' * F' _\\alpha ^\\epsilon'
	+ frac(1,4) * phi^4 * A' ^\\mu' * A' _\\sigma' * F' _\\beta ^\\sigma' * F' _\\alpha _\\mu'
)()

Ricci5_def[2][1] = (Ricci5_def[2][1]
	+ frac(1,4) * phi^4 * A' _\\epsilon' * F' _\\sigma ^\\epsilon' * F' _\\beta ^\\sigma'
	- frac(1,4) * phi^4 * A' _\\sigma' * F' _\\epsilon ^\\sigma' * F' _\\beta ^\\epsilon'
	
	+ frac(1,4) * phi^4 * A' ^\\mu' * F' _\\epsilon _\\mu' * F' _\\beta ^\\epsilon'
	- frac(1,4) * phi^4 * A' ^\\mu' * F' _\\sigma _\\mu' * F' _\\beta ^\\sigma'

	- frac(1,2) * phi^2 * (F' _\\beta ^\\sigma _,\\sigma' - F' _\\sigma ^\\epsilon' * conn4' ^\\sigma _\\epsilon _\\beta' + F' _\\beta ^\\epsilon' * conn4' ^\\sigma _\\epsilon _\\sigma')
	+ frac(1,2) * phi^2 * (F' _\\beta ^\\mu _;\\mu')
)()

Ricci5_def[1][2] = (Ricci5_def[1][2]
	- frac(1,2) * phi^2 * (F' _\\alpha ^\\sigma _,\\sigma' - F' _\\epsilon ^\\sigma' * conn4' ^\\epsilon _\\alpha _\\sigma' + F' _\\alpha ^\\epsilon' * conn4' ^\\sigma _\\epsilon _\\sigma')
	+ frac(1,2) * phi^2 * (F' _\\alpha ^\\mu _;\\mu')
)()

printbr(R5'_ab':eq(R5'^c_acb'))
printbr()

printbr(R5'_ab':eq(Ricci5_def))
printbr()


printbr'Gaussian curvature:'
local Gaussian5_def = (Ricci5_def'_ab' * g5U_def'^ab')()
Gaussian5_def = (Gaussian5_def 
	- R' _\\alpha _\\beta' * g' ^\\alpha ^\\beta'
	+ R

	- frac(1,4) * phi^4 * A' ^\\rho' * A' _\\rho' * F' _\\epsilon ^\\nu' * F' _\\nu ^\\epsilon'
	+ frac(1,4) * phi^4 * A' ^\\mu' * A' _\\mu' * F' _\\epsilon ^\\nu' * F' _\\nu ^\\epsilon'
)():reindex{[' \\alpha \\beta'] = ' \\rho \\sigma'}
printbr(R5:eq(Gaussian5_def))
printbr()

printbr'Einstein curvature:'
local G5 = var'\\tilde{G}'
local Einstein_def = (Ricci5_def'_ab' - frac(1,2) * Gaussian5_def * g5_def'_ab')()
printbr(G5'_ab':eq(Einstein_def))
printbr()


printbr()
printbr()
print(export.MathJax.footer)
