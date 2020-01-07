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
local dg5_rhs = Tensor('_cab', function(c,a,b)
	if c == 1 then
		return dg5_2x2_rhs[a][b]:reindex{[' \\gamma']='c'}
	elseif c == 2 then
		return dg5_2x2_rhs[a][b]:reindex{[5]='c'}()
			:replace(A'_\\alpha _,5',0)
			:replace(A'_\\beta _,5',0)
			:replace(g' _\\alpha _\\beta _,5',0)()
	end
end)
printbr(g5'_ab,c':eq(dg5_rhs))
printbr()

-- alright, here we do the same exact index gymnastics as with dense tensors
-- hence the original motivation for mixed indexes (which is a bit of a clusterfuck, so I haven't finished it).

printbr'lower connection'
local conn5 = var'\\tilde{\\Gamma}'
local conn5L_rhs = Tensor('_abc', function(a,b,c)
	return (frac(1,2) * (
		-- g_ab,c
		dg5_rhs[c][a][b]	
		-- + g_ac,b
		+ dg5_rhs[b][a][c]:reindex{
			[' \\beta'] = ' \\gamma',
			[' \\gamma'] = ' \\beta',
		}
		-- - g_bc,a
		- dg5_rhs[a][b][c]:reindex{
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
		:reindex{[' \\epsilon'] = ' \\beta'}()
	* conn5L_rhs'_ebc'
		:reindex{[' \\epsilon'] = ' \\alpha'}()
)
printbr(conn5'^a_bc':eq(conn5U_rhs))
conn5U_rhs = conn5U_rhs()
printbr(conn5'^a_bc':eq(conn5U_rhs))
conn5U_rhs = conn5U_rhs:replace(
	g' ^\\alpha ^\\epsilon' * conn4' _\\epsilon _\\beta _\\gamma',
	conn4' ^\\alpha _\\beta _\\gamma'
)()
conn5U_rhs = conn5U_rhs:replace(
	A' ^\\epsilon' * conn4' _\\epsilon _\\beta _\\gamma',
	A' _\\epsilon' * conn4' ^\\epsilon _\\beta _\\gamma'
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
conn5U_rhs = conn5U_rhs:reindex{[' \\mu'] = ' \\epsilon'}
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
printbr'There you have gravitational force, Lorentz force, and an extra term.'
printbr()


printbr'connection partial:'
local dconn5_2x2x2_rhs = Tensor('^a_bc', function(a,b,c)
	return conn5U_rhs[a][b][c]',d'()
		:replace(phi'_,d', 0)()
		:replace(phi'_,d', 0)()
end)
printbr(conn5'^a_bc,d':eq(dconn5_2x2x2_rhs))

local dconn5U_rhs = Tensor('^a_bcd', function(a,b,c,d)
	if d == 1 then
		return dconn5_2x2x2_rhs[a][b][c]:reindex{[' \\delta']='d'}
	elseif d == 2 then
		return dconn5_2x2x2_rhs[a][b][c]
			:reindex{[5]='d'}
			:replace(conn4' ^\\alpha _\\beta _\\gamma _,5', 0)
			:replace(conn4' _\\mu _\\beta _\\gamma _,5', 0)
			:replace(A' _\\beta _,5', 0)
			:replace(A' _\\gamma _,5', 0)
			:replace(A' ^\\mu _,5', 0)
			:replace(A' _\\beta _,\\gamma _,5', 0)
			:replace(A' _\\gamma _,\\beta _,5', 0)
			:replace(F' _\\beta _\\mu _,5', 0)
			:replace(F' _\\gamma _\\mu _,5', 0)
			:replace(F' _\\gamma ^\\alpha _,5', 0)
			:replace(F' _\\beta ^\\alpha _,5', 0)
			:simplify()
	end
end)
printbr(conn5'^a_bc,d':eq(dconn5U_rhs))
printbr()


local conn5USq_rhs = 
	conn5U_rhs'^a_ec'():reindex{
		[' \\epsilon'] = ' \\beta',
	}
	* conn5U_rhs'^e_bd'()
		:reindex{
			[' \\epsilon'] = ' \\alpha',
			[' \\delta'] = ' \\gamma',
		}
printbr((conn5'^a_be' * conn5'^e_cd'):eq(conn5USq_rhs))
conn5USq_rhs = conn5USq_rhs():permute'abcd'
printbr((conn5'^a_be' * conn5'^e_cd'):eq(conn5USq_rhs))
printbr()


local R = var'R'
local R5 = var'\\tilde{R}'
printbr(R5'^a_bcd':eq( conn5'^a_bd,c' - conn5'^a_bc,d' + conn5'^a_ec'*conn5'^e_bd' - conn5'^a_ed'*conn5'^e_bc' ))
local Riemann5_rhs = Tensor('^a_bcd', function(a,b,c,d)
	return (dconn5U_rhs[a][b][d][c]:reindex{
		[' \\gamma'] = ' \\delta',
		[' \\delta'] = ' \\gamma',
	}
	- dconn5U_rhs[a][b][c][d]
	+ conn5USq_rhs[a][b][c][d]
	- conn5USq_rhs[a][b][d][c]:reindex{
		[' \\gamma'] = ' \\delta',
		[' \\delta'] = ' \\gamma',
	})
	:simplify()
end)

--[=[
Riemann5_rhs = Riemann5_rhs
	:replace( A' _\\beta _,\\delta _,\\gamma', A' _\\beta _,\\gamma _,\\delta')	
	:replace( A' _\\delta _,\\beta _,\\gamma', F' _\\gamma _\\delta _,\\beta' + A' _\\gamma _,\\beta _,\\delta')
	:simplify()

-- why isn't replace() working?
Riemann5_rhs[1][1][1][1] = (Riemann5_rhs[1][1][1][1] 
	- (
		conn4' ^\\alpha _\\beta _\\delta _,\\gamma' 
		- conn4' ^\\alpha _\\beta _\\gamma _,\\delta'
		+ conn4' ^\\epsilon _\\beta _\\delta' * conn4' ^\\alpha _\\epsilon _\\gamma'
		- conn4' ^\\epsilon _\\beta _\\gamma' * conn4' ^\\alpha _\\epsilon _\\delta'
	) + (
		R' ^\\alpha _\\beta _\\gamma _\\delta'
	)

	- (
		frac(1,4) * phi^2 * F' _\\gamma ^\\alpha' * (A' _\\delta _,\\beta' - A' _\\beta _,\\delta')
	) + (
		frac(1,4) * phi^2 * F' _\\gamma ^\\alpha' * F' _\\beta _\\delta'
	)

	- (
		frac(1,4) * phi^2 * F' _\\delta ^\\alpha' * (A' _\\beta _,\\gamma' - A' _\\gamma _,\\beta')
	) + (
		frac(1,4) * phi^2 * F' _\\delta ^\\alpha' * F' _\\gamma _\\beta'
	)

	- (
		frac(1,2) * phi^2 * F' _\\beta ^\\alpha' * (A' _\\delta _,\\gamma' - A' _\\gamma _,\\delta')
	) + (
		frac(1,2) * phi^2 * F' _\\beta ^\\alpha' * F' _\\gamma _\\delta'
	)
)()

Riemann5_rhs[2][1][1][1] = (Riemann5_rhs[2][1][1][1] + (
		A' _\\mu' * (
			conn4' ^\\mu _\\beta _\\delta _,\\gamma' 
			- conn4' ^\\mu _\\beta _\\gamma _,\\delta'
			+ conn4' ^\\epsilon _\\beta _\\delta' * conn4' ^\\mu _\\epsilon _\\gamma'
			- conn4' ^\\epsilon _\\beta _\\gamma' * conn4' ^\\mu _\\epsilon _\\delta'
		)
	) - (
		A' _\\mu' * R' ^\\mu _\\beta _\\gamma _\\delta'
	)
)()
--]=]

printbr(R5'^a_bcd':eq(Riemann5_rhs))
printbr()


printbr()
printbr()
print(export.MathJax.footer)
