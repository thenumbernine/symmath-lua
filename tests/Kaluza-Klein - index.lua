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

local g5_def = Tensor('_ab',
	{g'_\\alpha _\\beta' + phi^2 * A' _\\alpha' * A' _\\beta', phi^2 * A' _\\alpha' * A'_5'},
	{phi^2 * A' _\\beta' * A'_5', phi^2 * (A'_5')^2}
)

-- TODO in the print function, for variables with indexes of numbers that are raised to powers,
-- or with variables with numbers
-- make sure to wrap the variable and indexes in ()'s
printbr(g5'_ab':eq(g5_def))

--[[
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
	{g'^\\alpha ^\\beta', -A' ^\\alpha'},
	{-A' ^\\beta', A' _\\mu' * A' ^\\mu' + 1/phi^2}
)
printbr(g5'^ab':eq(g5U_def))
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
printbr'Therefore'
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
		return dg5_2x2_def[a][b]:reindex{[' \\gamma']='c'}
	elseif c == 2 then
		return dg5_2x2_def[a][b]:reindex{[5]='c'}():map(function(x)
			if TensorRef.is(x) and x:hasDerivIndex(5) then
				return 0
			end
		end)()
	end
end)
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
		+ dg5_def[b][a][c]:reindex{
			[' \\beta'] = ' \\gamma',
			[' \\gamma'] = ' \\beta',
		}
		-- - g_bc,a
		- dg5_def[a][b][c]:reindex{
			[' \\alpha'] = ' \\gamma',
			[' \\beta'] = ' \\alpha',
			[' \\gamma'] = ' \\beta',
		}
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
	g5U_def'^ae' 
		:reindex{[' \\epsilon'] = ' \\beta'}()
	* conn5L_def'_ebc'
		:reindex{[' \\epsilon'] = ' \\alpha'}()
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
conn5U_def = conn5U_def:reindex{[' \\mu'] = ' \\epsilon'}
printbr(conn5'^a_bc':eq(conn5U_def))
printbr()


os.exit()


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
local dconn5_2x2x2_def = Tensor('^a_bc', function(a,b,c)
	return conn5U_def[a][b][c]',d'()
		:replace(phi'_,d', 0)()
		:replace(phi'_,d', 0)()
end)
printbr(conn5'^a_bc,d':eq(dconn5_2x2x2_def))

local dconn5U_def = Tensor('^a_bcd', function(a,b,c,d)
	if d == 1 then
		return dconn5_2x2x2_def[a][b][c]:reindex{[' \\delta']='d'}
	elseif d == 2 then
		return dconn5_2x2x2_def[a][b][c]
			:reindex{[5]='d'}
			:replace(conn4' ^\\alpha _\\beta _\\gamma _,5', 0)
			:replace(conn4' ^\\mu _\\beta _\\gamma _,5', 0)
			:replace(conn4' _\\mu _\\beta _\\gamma _,5', 0)
			:replace(A' _\\beta _,5', 0)
			:replace(A' _\\gamma _,5', 0)
			:replace(A' _\\mu _,5', 0)
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
printbr(conn5'^a_bc,d':eq(dconn5U_def))
printbr()


local conn5USq_def = 
	conn5U_def'^a_ec'():reindex{
		[' \\epsilon'] = ' \\beta',
	}
	* conn5U_def'^e_bd'()
		:reindex{
			[' \\epsilon'] = ' \\alpha',
			[' \\delta'] = ' \\gamma',
		}
printbr((conn5'^a_be' * conn5'^e_cd'):eq(conn5USq_def))
conn5USq_def = conn5USq_def():permute'abcd'
printbr((conn5'^a_be' * conn5'^e_cd'):eq(conn5USq_def))
printbr()


printbr'Riemann curvature tensor:'
local R = var'R'
local R5 = var'\\tilde{R}'
printbr(R5'^a_bcd':eq( conn5'^a_bd,c' - conn5'^a_bc,d' + conn5'^a_ec'*conn5'^e_bd' - conn5'^a_ed'*conn5'^e_bc' ))
local Riemann5_def = Tensor('^a_bcd', function(a,b,c,d)
	return (dconn5U_def[a][b][d][c]:reindex{
		[' \\gamma'] = ' \\delta',
		[' \\delta'] = ' \\gamma',
	}
	- dconn5U_def[a][b][c][d]
	+ conn5USq_def[a][b][c][d]
	- conn5USq_def[a][b][d][c]:reindex{
		[' \\gamma'] = ' \\delta',
		[' \\delta'] = ' \\gamma',
	})
	:simplify()
end)

Riemann5_def = Riemann5_def
	:replace( A' _\\beta _,\\delta _,\\gamma', A' _\\beta _,\\gamma _,\\delta')	
	:replace( A' _\\delta _,\\beta _,\\gamma', F' _\\gamma _\\delta _,\\beta' + A' _\\gamma _,\\beta _,\\delta')
	:simplify()

-- why isn't replace() working?
Riemann5_def[1][1][1][1] = (Riemann5_def[1][1][1][1] 
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
--	:replace(F' _\\delta ^\\alpha _;\\gamma', F' _\\delta ^\\alpha _,\\gamma' - )
--	:simplify()

Riemann5_def[1][1][2][1] = (Riemann5_def[1][1][2][1] 
	- frac(1,4) * phi^4 * A' ^\\mu' * F' _\\beta _\\mu' * F' _\\delta ^\\alpha'
	+ frac(1,4) * phi^4 * A' _\\epsilon' * F' _\\beta ^\\epsilon' * F' _\\delta ^\\alpha'
)()

Riemann5_def[2][1][1][1] = (Riemann5_def[2][1][1][1] 
	+ (
		A' _\\mu' * (
			conn4' ^\\mu _\\beta _\\delta _,\\gamma' 
			- conn4' ^\\mu _\\beta _\\gamma _,\\delta'
			+ conn4' ^\\epsilon _\\beta _\\delta' * conn4' ^\\mu _\\epsilon _\\gamma'
			- conn4' ^\\epsilon _\\beta _\\gamma' * conn4' ^\\mu _\\epsilon _\\delta'
		)
	) - (
		A' _\\mu' * R' ^\\mu _\\beta _\\gamma _\\delta'
	)

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


printbr(R5'^a_bcd':eq(Riemann5_def))
printbr()

printbr'TODO FIXME there is a double $\\mu$ index in $R_{2111}$'

os.exit()

printbr'Ricci tensor:'
local Ricci5_def = Riemann5_def'^e_aeb'()
	:reindex{
		[' \\rho'] = ' \\alpha',
		[' \\alpha'] = ' \\beta',
		[' \\nu'] = ' \\gamma',
		[' \\beta'] = ' \\delta',
	}
	-- ... you will never need to turn one letter into two, but there are times when you will need to turn two into one, like with traces
	-- ... so TODO swap the 'from' and 'to' in 'reindex'
	:reindex{
		[' \\nu'] = ' \\rho',
	}
	:replace(R' ^\\nu _\\alpha _\\nu _\\beta', R' _\\alpha _\\beta')
	:replace(F' _\\nu ^\\nu', 0)()
	:replace(F' _\\nu ^\\nu _,\\beta', 0)()
	
	-- hmm, not working so well...
	-- even if it was, I would have to add the ability to tell this function which symbols to use (to avoid the 5D symbols)
	--:tidyIndexes()()

Ricci5_def[1][1] = (Ricci5_def[1][1]
	+ frac(1,4) * phi^4 * A' ^\\mu' * A' _\\alpha' * F' _\\epsilon _\\mu' * F' _\\beta ^\\epsilon'
	- frac(1,4) * phi^4 * A' ^\\mu' * A' _\\alpha' * F' _\\nu _\\mu' * F' _\\beta ^\\nu'
	
	- frac(1,4) * phi^4 * A' ^\\mu' * A' _\\epsilon' * F' _\\beta _\\mu' * F' _\\alpha ^\\epsilon'
	+ frac(1,4) * phi^4 * A' ^\\mu' * A' _\\nu' * F' _\\beta ^\\nu' * F' _\\alpha _\\mu'
)()

Ricci5_def[2][1] = (Ricci5_def[2][1]
	+ frac(1,4) * phi^4 * A' _\\epsilon' * F' _\\nu ^\\epsilon' * F' _\\beta ^\\nu'
	- frac(1,4) * phi^4 * A' _\\nu' * F' _\\epsilon ^\\nu' * F' _\\beta ^\\epsilon'
	
	+ frac(1,4) * phi^4 * A' ^\\mu' * F' _\\epsilon _\\mu' * F' _\\beta ^\\epsilon'
	- frac(1,4) * phi^4 * A' ^\\mu' * F' _\\nu _\\mu' * F' _\\beta ^\\nu'

	- frac(1,2) * phi^2 * (F' _\\beta ^\\nu _,\\nu' - F' _\\nu ^\\epsilon' * conn4' ^\\nu _\\epsilon _\\beta' + F' _\\beta ^\\epsilon' * conn4' ^\\nu _\\epsilon _\\nu')
	+ frac(1,2) * phi^2 * (F' _\\beta ^\\mu _;\\mu')
)()

Ricci5_def[1][2] = (Ricci5_def[1][2]
	- frac(1,2) * phi^2 * (F' _\\alpha ^\\nu _,\\nu' - F' _\\epsilon ^\\nu' * conn4' ^\\epsilon _\\alpha _\\nu' + F' _\\alpha ^\\epsilon' * conn4' ^\\nu _\\epsilon _\\nu')
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
)():reindex{
	[' \\rho'] = ' \\alpha',
	[' \\sigma'] = ' \\beta',
}
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
