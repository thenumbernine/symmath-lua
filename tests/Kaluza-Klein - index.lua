#!/usr/bin/env luajit
require 'ext'
require 'symmath'.setup{MathJax={title='Kaluza-Klein - index notation'}}

printbr[[
Kaluza-Klein with constant scalar field<br>
<br>

unit coordinate convention: $dx^0 = c dt$<br>
<br>

$1 = c =$ speed of light<br>
$1 = G =$ gravitational constant<br>
$1 = k_e =$ Coulomb's constant<br>
<br>
]]

Tensor.coords{{variables={'txyz','5'}}}

-- units
local m = var'm'
local s = var's'
local kg = var'kg'
local C = var'C'

local A = var'A'
printbr(A'_u', '= electromagnetic four-potential, in units', (kg*m)/(C*s))
printbr(A'_5':eq(1), 'in natural units, but to cancel the units of $\\phi$ it is in units of', (kg*m)/(C*s))
printbr()

local phi = var'\\phi'
printbr(phi, '= scalar field, in units', (C*s)/(kg*m))
printbr()

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

local g5_rhs = Tensor('_ab',
	{g'_\\alpha _\\beta' + phi^2 * A' _\\alpha' * A' _\\beta', phi^2 * A' _\\alpha' * A'_5'},
	{phi^2 * A' _\\beta' * A'_5', phi^2 * (A'_5')^2}
)
local g5_def = g5'_ab':eq(g5_rhs)

-- TODO in the print function, for variables with indexes of numbers that are raised to powers,
-- or with variables with numbers
-- make sure to wrap the variable and indexes in ()'s
printbr(g5_def)

printbr'Notice that I included the $A_5$ terms to show the units align.  From here on I will omit them since their value is 1.'

g5_def = g5_def:replace(A'_5', 1)()
printbr(g5_def)
printbr()


printbr(g5'^uv', '= 5D metric inverse')
local g5U_rhs = Tensor('^ab',
	{g'^\\alpha ^\\beta', -g'^\\alpha ^\\mu' * A' _\\mu'},
	{-g'^\\beta ^\\mu' * A' _\\mu', g'^\\mu ^\\nu' * A' _\\mu' * A' _\\nu' + 1/phi^2}
)
printbr(g5'^ab':eq(g5U_rhs))

printbr'Notice, if you see a raised 4-index, it is being raised by the 4-metric and not the 5-metric.'

local g5U_rhs = Tensor('^ab',
	{g'^\\alpha ^\\beta', -A' ^\\alpha'},
	{-A' ^\\beta', A' _\\mu' * A' ^\\mu' + 1/phi^2}
)
printbr(g5'^ab':eq(g5U_rhs))
printbr()


printbr'The cylindrical constraint is'
local cylConstraint = g5'_ab,5':eq(0)
printbr(cylConstraint)
printbr'Therefore'
--printbr(cylConstraint:splitOffDerivIndexes():subst(g5_def)())
-- TODO matrix with index comma derivative -> simplify to -> matrix components with index comma derivative
-- (seems this is a dilemma with scalar comma derivatives vs constant comma derivatives as well)
printbr(Array:lambda({2,2}, function(a,b) return g5_def:rhs()[a][b]'_,5'() end):eq(0))

-- TODO this can be derived, in order its presented, using the matrix equality
printbr'Therefore'
printbr(phi'_,5':eq(0))
printbr(A' _\\mu _,5':eq(0))
printbr(g' _\\alpha _\\beta _,5':eq(0))
printbr()

printbr"For now I'll use a constant scalar as well"
printbr(phi'_,a':eq(0))
printbr()

printbr'metric partial:'
local dg5_2x2_rhs = Tensor('_ab', function(a,b)
	return g5_def:rhs()[a][b]'_,c'()
		:replace(phi'_,c', 0)()
end)
printbr(g5'_ab,c':eq(dg5_2x2_rhs))

-- indexed [c][a][b]
dg5_2x2x2_rhs = Tensor('_cab', function(c,a,b)
	if c == 1 then
		return dg5_2x2_rhs[a][b]:reindex{[' \\gamma']='c'}
	elseif c == 2 then
		return dg5_2x2_rhs[a][b]:reindex{[5]='c'}()
			:replaceIndex(A'_\\alpha _,5',0)
			:replaceIndex(g'_\\alpha _\\beta _,5',0)()
	end
end)
printbr(g5'_ab,c':eq(dg5_2x2x2_rhs))
printbr()

-- alright, here we do the same exact index gymnastics as with dense tensors
-- hence the original motivation for mixed indexes (which is a bit of a clusterfuck, so I haven't finished it).

printbr'lower connection'
local conn5 = var'\\tilde{\\Gamma}'
local conn5L_rhs = Tensor('_abc', function(a,b,c)
	return (frac(1,2) * (
		-- g_ab,c
		dg5_2x2x2_rhs[c][a][b]	
		-- + g_ac,b
		+ dg5_2x2x2_rhs[b][a][c]:reindex{
			[' \\beta'] = ' \\gamma',
			[' \\gamma'] = ' \\beta',
		}
		-- - g_bc,a
		- dg5_2x2x2_rhs[a][b][c]:reindex{
			[' \\alpha'] = ' \\gamma',
			[' \\beta'] = ' \\alpha',
			[' \\gamma'] = ' \\beta',
		}
	))()
end)
printbr(conn5'_abc':eq(conn5L_rhs))

local F = var'F'
local conn4 = var'\\Gamma'
conn5L_rhs = conn5L_rhs:replace(
	(g' _\\alpha _\\beta _,\\gamma' + g' _\\alpha _\\gamma _,\\beta' - g' _\\beta _\\gamma _,\\alpha')(), 
	2 * conn4'_\\alpha _\\beta _\\gamma'
)()
conn5L_rhs = conn5L_rhs:replace(
	A' _\\alpha _,\\beta',
	F'_\\beta _\\alpha' + A' _\\beta _,\\alpha'
)()
conn5L_rhs = conn5L_rhs:replace(
	A' _\\alpha _,\\gamma',
	F'_\\gamma _\\alpha' + A' _\\gamma _,\\alpha'
)()
printbr(conn5'_abc':eq(conn5L_rhs))
printbr()


printbr'upper connection'
local conn5U_rhs = (
	g5U_rhs'^ae' 
		:reindex{[' \\epsilon'] = ' \\beta'}
	* conn5L_rhs'_ebc'
		:reindex{[' \\epsilon'] = ' \\alpha'}
)
printbr(conn5'^a_bc':eq(conn5U_rhs))
conn5U_rhs = conn5U_rhs()
printbr(conn5'^a_bc':eq(conn5U_rhs))
conn5U_rhs = conn5U_rhs:replace(
	g' ^\\alpha ^\\epsilon' * conn4' _\\epsilon _\\beta _\\gamma',
	conn4' ^\\alpha _\\beta _\\gamma'
)()
conn5U_rhs = conn5U_rhs:replace(
	F' _\\beta _\\epsilon' * g' ^\\alpha ^\\epsilon',
	F' _\\beta ^\\alpha'
)()
conn5U_rhs = conn5U_rhs:replace(
	F' _\\gamma _\\epsilon' * g' ^\\alpha ^\\epsilon',
	F' _\\gamma ^\\alpha'
)()
conn5U_rhs = conn5U_rhs:replace(
	A' _\\epsilon' * g' ^\\alpha ^\\epsilon',
	A' ^\\alpha'
)()
conn5U_rhs = conn5U_rhs:replace(
	(A' _\\epsilon' * A' ^\\epsilon')(),
	A' _\\mu' * A' ^\\mu'
)()
printbr(conn5'^a_bc':eq(conn5U_rhs))
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
	conn5U_rhs[1][1][1]
)()
geodesicEqn = geodesicEqn:replace(
	conn5' ^\\alpha _\\beta _5',
	conn5U_rhs[1][1][2]
)()
geodesicEqn = geodesicEqn:replace(
	conn5' ^\\alpha _5 _\\gamma',
	conn5U_rhs[1][2][1]
)()
geodesicEqn = geodesicEqn:replace(
	conn5' ^\\alpha _5 _5',
	conn5U_rhs[1][2][2]
)()

geodesicEqn = geodesicEqn:replace(
	(phi^2 * A' _\\gamma' * dx_ds' ^\\beta' * dx_ds' ^\\gamma' * F' _\\beta ^\\alpha')(),
	phi^2 * A' _\\beta' * dx_ds' ^\\beta' * dx_ds' ^\\gamma' * F' _\\gamma ^\\alpha'
)()
printbr(geodesicEqn)

printbr'Let $\\dot{x}^5 = \\frac{q}{m}$'
geodesicEqn = geodesicEqn:replace(
	dx_ds'^5',
	var'\\frac{q}{m}'	--frac(var'q', var'm')	-- using a var so it doesn't combine with other terms
)()
printbr(geodesicEqn)

printbr()
printbr'There you have gravitational force, Lorentz force, and some extra terms.'
printbr()


printbr()
printbr()
print(export.MathJax.footer)
