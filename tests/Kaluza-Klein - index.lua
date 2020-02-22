#!/usr/bin/env luajit
require 'ext'
require 'symmath'.setup{MathJax={title='Kaluza-Klein - index notation'}}

-- this sets simplifyConstantPowers 
local units = require 'symmath.physics.units'()


local constantScalarField = true
if arg[1] == 'varyingScalarField' then
	constantScalarField = false
end
--local constantScalarField = false	-- with implicitVars=true, you have to manually define your nil/false flags


local function betterSimplify(x)
	return x():factorDivision()
	:map(function(y)
		if symmath.op.add.is(y) then
			local newadd = table()
			for i=1,#y do
				newadd[i] = y[i]():factorDivision()
			end
			return #newadd == 1 and newadd[1] or symmath.op.add(newadd:unpack())
		end
	end)
end

function splitTermIndexes(x, splitMap)
	local newAdd = table()
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
	return #newAdd == 1 and newAdd[1] or symmath.op.add(newAdd:unpack())
end

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


-- numeric constant symbols
local pi = var'\\pi'


-- units
local m = units.m
local s = units.s
local kg = units.kg
local C = units.C


local c = units.c
local k_e = units.k_e
local G = units.G
local epsilon_0 = units.epsilon_0
local mu_0 = units.mu_0

printbr('Kaluza-Klein with '..(constantScalarField and 'constant' or 'varying')..' scalar field<br>')
printbr()

printbr'unit coordinate convention: $dx^0 = c dt$'
printbr()

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
printbr('$A_5$ is constant in natural units, but to cancel the units of $\\phi_K$ it is in units of', (kg*m)/(C*s),
	'so $A_5$ is proportional to $c \\sqrt{\\frac{k_e}{G}} = $', (units.c_in_m_s:rhs() * sqrt(units.k_e_in_SI_and_C:rhs() / units.G_in_SI:rhs()))():factorDivision() )
printbr()

local phi_K = var'\\phi_K'
printbr(phi_K, '= scalar field, in units', (C*s)/(kg*m))
printbr()


symmath.simplifyConstantPowers = false


local g = var'g'
printbr(g'_\\mu _\\nu', '= 4D metric tensor, with units $[g_{\\mu\\nu}] = 1$')
printbr(g'^\\mu ^\\nu', '= 4D metric inverse')
printbr()

local g5 = var'\\tilde{g}'
printbr(g5'_ab', '= 5D metric tensor, with units $[\\tilde{g}_{ab}] = 1$')
local g5_parts = Tensor('_ab',
	{g5'_\\alpha _\\beta', g5'_\\alpha _5'},
	{g5'_5 _\\beta', g5'_55'}
)
printbr(g5'_ab':eq(g5_parts))

local g5_def = Tensor('_ab',
	{g'_\\alpha _\\beta' + phi_K^2 * A' _\\alpha' * A' _\\beta', phi_K^2 * A' _\\alpha' * A'_5'},
	{phi_K^2 * A' _\\beta' * A'_5', phi_K^2 * (A'_5')^2}
)

-- TODO in the print function, for variables with indexes of numbers that are raised to powers,
-- or with variables with numbers
-- make sure to wrap the variable and indexes in ()'s
printbr(g5'_ab':eq(g5_def))
printbr()

printbr'<hr>'


-- I should put this in its own worksheet ...
printbr'What if we require a unit 5-velocity?'
local u = var'u'

local unitVelEqn = (g5'_ab' * u'^a' * u'^b'):eq(-1)()
printbr(unitVelEqn)

printbr'split off spacetime indexes'
--unitVelEqn[1] = splitTermIndexes(unitVelEqn[1], {a = {' \\alpha', 5}, b = {' \\beta ', 5}})
	--:reindex{[' \\beta'] = ' \\alpha'}()
	--:tidyIndexes()	-- tidy indexes doesn't work ...
	--:symmetrizeIndexes(g5, {1,2})()
unitVelEqn = ( g5' _\\alpha _\\beta' * u' ^\\alpha' * u' ^\\beta' + 2 * g5' _\\alpha _5' * u' ^\\alpha' * u'^5' + g5'_55' * (u'^5')^2 ):eq(-1)
printbr(unitVelEqn)

printbr('Substitute definition of ', g5'_ab')
unitVelEqn = unitVelEqn
	:replace(g5_parts[1][1], g5_def[1][1])() 
	:replace(g5_parts[1][2], g5_def[1][2])()
	:replace(g5_parts[2][2], g5_def[2][2])()
printbr(unitVelEqn)

--printbr('Assume', ( g' _\\alpha _\\beta' * u' ^\\alpha' * u' ^\\beta' ):eq(-1))
--unitVelEqn = unitVelEqn:replace( (g' _\\alpha _\\beta' * u' ^\\alpha' * u' ^\\beta')(), -1)()
--printbr(unitVelEqn)

printbr[[
TODO redo this for 1/4 u^5<br>

Solve quadratic for $A_5 u^5$...<br>
$ u^5 = \frac{1}{A_5} ( -A_\mu u^\mu \pm \sqrt{
	(A_\mu u^\mu)^2 - {\phi_K}^{-2} ( u_\mu u^\mu + 1)
} )$<br>
<br>

On a side note, later we are going to set $u^5 = \frac{1}{4} \frac{q}{m} \sqrt{\frac{k_e}{G}}$.<br>
If we do this now then the solution of the quadratic looks like:<br>
$\frac{1}{4} \frac{q}{m} \sqrt{\frac{k_e}{G}} = \frac{1}{c} \sqrt{\frac{G}{k_e}} ( -A_\mu u^\mu \pm \sqrt{ (A_\mu u^\mu)^2 - {\phi_K}^{-2} ( u_\mu u^\mu + 1) } )$<br>
$\frac{q}{m} = 4 \frac{1}{c} \frac{G}{k_e} ( -A_\mu u^\mu \pm \sqrt{ (A_\mu u^\mu)^2 - {\phi_K}^{-2} ( u_\mu u^\mu + 1) } )$<br>
<br>

Let's look at the magnitude of this for some real-world values.<br>
Electrons in a copper wire (from my 'magnetic field from a boosted charge' worksheet).<br>
$I = 1.89 A =$ current in wire.<br>
$\lambda = 7223 \frac{C}{m} =$ charge density per unit meter in wire.<br>
$v = \frac{I}{\lambda} = 2.625 \cdot 10^{-5} \frac{m}{s} =$ mean velocity of electrons in wire.<br>
$\beta = \frac{v}{c} = 8.756735364191964 \cdot 10^{-14} = $ unitless, spatial component of 4-velocity.<br>
$\gamma = 1 / \sqrt{1 - \beta^2} = 1 + 2.959179033 \cdot 10^{-7} = $ Lorentz factor.<br>
$u^0 = \gamma, u^1 = \beta \gamma, u^2 = u^3 = 0$ = our 4-velocity components, such that $\eta_{\mu\nu} u^\mu u^\nu = -1$.<br>
$r = 0.1 m = $ distance from the wire we are measuring fields.<br>
$A_5 = c \sqrt{\frac{k_e}{G}} = 3.4789926447386 \cdot 10^{18} \frac{kg \cdot m}{C \cdot s} =$ fifth component of electromagnetic potential, as stated above.<br>
$\phi_q = \frac{1}{2} \lambda k_e ln ( \frac{r}{r_0} ) =$ electric potential ... but what is $r_0$?  The EM potential has a constant which does not influence 4D or 3D EM, but will influence 5D EM.<br>
Let's look at the potential with and without the constant: $\phi_q = \phi'_q + \phi''_q$.<br>
$\phi'_q = \frac{1}{2} \lambda k_e ln(r) = -7.47382142321859 \cdot 10^{14} \frac{kg \cdot m^2}{C \cdot s^2}$.<br>
$\phi''_q = \frac{1}{2} \lambda k_e ln(r_0) = $ arbitrary.<br>
$A_i = 0 = $ magnetic vector potential.<br>
So $A_\mu u^\mu = A_0 u^0 = \frac{1}{c} \phi_q \gamma = -2492999.2 \frac{kg \cdot m}{C \cdot s} + \frac{1}{c} \phi''_q \gamma$.<br>
And $\frac{1}{A_5} A_\mu u^\mu = -7.165865159852 \cdot 10^{-13} + \frac{1}{c A_5} \phi''_q \gamma$<br>
<br>

Assume $u_\mu u^\mu = -1$.<br>
$u^5 = -2 \frac{1}{A_5} A_\mu u^\mu = 1.4331730319704 \cdot 10^{-12} - \frac{1}{c A_5} \gamma \phi''_q$<br>

Below in the geodesic equation, for the Lorentz force equation to arise we must set $u^5 = \frac{1}{4} \frac{q}{m} \sqrt{\frac{k_e}{G}}$.<br>
Let's insert this into the $u^5$ equation above and solve to find what $\phi''_q$ would be:<br>
$\frac{1}{c A_5} \gamma \phi''_q = \frac{1}{4} \frac{q}{m} \sqrt{\frac{k_e}{G}}$<br>
$\phi''_q = \frac{1}{4} c^2 \frac{q}{\gamma m} \frac{k_e}{G} = \frac{1}{4} c^2 \frac{q}{m} \frac{k_e}{G} \sqrt{1 - \beta^2}$<br>
For an electron this comes out to be $u^5 = \frac{1}{4} \frac{q}{m} \sqrt{\frac{k_e}{G}} = 5.1026314623865 \cdot 10^{20} = 1.529730428377 \cdot 10^{29} \frac{m}{s}$.<br>
$\phi''_q = 5.3219209087562 \cdot 10^{47} \frac{kg \cdot m^2}{C \cdot s^2}$<br>
...which is a few orders of magnitude higher than what contributes to the EM field.<br>
<br>

So, assuming we want our 5-velocity to be normalized with the 5-metric, and assuming our 4-velocity is normalized with the 4-metric,
then it looks like the 5th velocity is made up of two parts:<br>
1) the EM potential, dot the negligible 4-vel, which is on the order of $10^{-12}$ for our current through a copper wire.<br>
2) the the arbitrary constant, which must relate to the charge-mass ratio, which is on the order of $10^{21}$.<br>
Also notice that this shows then the charge-mass ratio in the Lorentz force law will be influenced by the 3-velocity.<br>
<br>

Of course you can avoid the constraint that that charge-mass ratio is dependent on the 3-velocity if you just relax the constraint of $u_\mu u^\mu = -1$.<br>
Then, for constaint $u^5 = \frac{1}{4} \frac{q}{m} \sqrt{\frac{k_e}{G}}$, any deviations in the electric potential $A_t$ could relate to deviations in the 4-vel-norm (or in deviations in the Kaluza field, which I am keeping constant in this worksheet).<br> 
<br>

Let's look at $\delta u^5$ with respect to $\delta u^\mu$ in the constraint above:<br>

$ \delta u^5 = 
-\frac{1}{(A_5)^2} \delta A_5 ( -A_\mu u^\mu \pm \sqrt{
	(A_\mu u^\mu)^2 - {\phi_K}^{-2} ( u_\mu u^\mu + 1)
} ) + \frac{1}{A_5} (
	- \delta A_\mu u^\mu - A_\mu \delta u^\mu 
	\pm \frac{
		A_\mu u^\mu (\delta A_\mu u^\mu + A_\mu \delta u^\mu)
		+ {\phi_K}^{-3} \delta \phi_K (u_\mu u^\mu + 1)
		- {\phi_K}^{-2} u_\mu \delta u^\mu
	}{\sqrt{
		(A_\mu u^\mu)^2 - {\phi_K}^{-2} (u_\mu u^\mu + 1)
	}}
)
$<br>

...and as for $\delta u^5$ wrt $\delta (u_\mu u^\mu)$ in specific...<br>
$ \frac{\delta u^5}{\delta (u_\mu u^\mu)} = 
\mp \frac{
	1
}{2 A_5 {\phi_K}^2 \sqrt{
	(A_\mu u^\mu)^2 - {\phi_K}^{-2} (u_\mu u^\mu + 1)
}}
$<br>
...and if $A_5 = 2 (\phi_K)^{-1}$...<br>
$ \frac{\delta u^5}{\delta (u_\mu u^\mu)} = 
\mp \frac{
	1
}{4 \sqrt{
	4 (\frac{1}{A_5} A_\mu u^\mu)^2 - u_\mu u^\mu + 1
}}
$<br>

<br>
<hr>
]]
printbr()

printbr[[What is $u_5$ in terms of $u^5$?]]

--[[
u^5 = whatever
so what is u_5?
u_5 = g_5a u^a = g_5u u^u + g_55 u^5
u_5 = phi_K^2 A_5 A_a u^a + phi_K^2 A_5^2 u^5
u^5 = (u_5 - phi_K^2 A_5 A_a u^a) / (phi_K^2 A_5^2)
u^5 = phi_K^-2 A_5^-2 u_5 - A_5^-1 A_a u^a
--]]
local u5_l_def = u'_5':eq(g5'_5a' * u'^a')
printbr(u5_l_def)
-- split
local u5_l_def = u'_5':eq(g5' _5 _\\beta' * u' ^\\beta' + g5'_55' * u'^5')
printbr(u5_l_def)
printbr('substitute definition of '..g5'_ab')
local u5_l_def = u'_5':eq(g5_def[2][1] * u' ^\\beta' + g5_def[2][2] * u'^5')
printbr(u5_l_def)

printbr()
printbr'<hr>'


printbr(g5'^uv', '= 5D metric inverse')
--[[
local g5U_def = Tensor('^ab',
	{g'^\\alpha ^\\beta', -g'^\\alpha ^\\mu' * A' _\\mu'},
	{-g'^\\beta ^\\mu' * A' _\\mu', g'^\\mu ^\\nu' * A' _\\mu' * A' _\\nu' + 1/phi_K^2}
)
printbr(g5'^ab':eq(g5U_def))
--]]
printbr'Notice, if you see a raised 4-index, it is being raised by the 4-metric and not the 5-metric.'

local g5U_def = Tensor('^ab',
	{g'^\\alpha ^\\beta', -A' ^\\alpha' / A'_5'},
	{-A' ^\\beta' / A'_5', (A' _\\mu' * A' ^\\mu' + phi_K^-2)  * (A'_5')^-2}
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
printbr(phi_K'_,5':eq(0))
printbr(A' _\\mu _,5':eq(0))
printbr(g' _\\alpha _\\beta _,5':eq(0))
printbr()


if constantScalarField then
	printbr"For now I'll use a constant scalar as well"
	printbr(phi_K'_,a':eq(0))
	printbr()
end

printbr'metric partial:'
local dg5_2x2_def = Tensor('_ab', function(a,b)
	local x = g5_def[a][b]'_,c'()
	if constantScalarField then
		x = x:replace(phi_K'_,c', 0)()
	end
	return x
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
conn5U_def = betterSimplify(conn5U_def)
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
if not constantScalarField then
	conn5U_def = conn5U_def:replace(
		phi_K' _,\\mu' * g' ^\\alpha ^\\mu',
		phi_K' ^,\\alpha'
	)()
end
conn5U_def = betterSimplify(conn5U_def)
printbr(conn5'^a_bc':eq(conn5U_def))
printbr()


printbr'<hr>'



local du_ds = var'\\dot{u}'

printbr()
printbr'geodesic:'
local geodesic5_def = du_ds'^a':eq( - conn5'^a_bc' * u'^b' * u'^c')
printbr(geodesic5_def)
printbr()

printbr'only look at spacetime components:'
local spacetimeGeodesic_def
--spacetimeGeodesic_def = geodesic5_def:reindex{a = ' \\alpha'}
--spacetimeGeodesic_def = splitIndexes(spacetimeGeodesic_def, {b = {0, ' \\beta'}, c = {0, ' \\gamma'}})
spacetimeGeodesic_def = betterSimplify(du_ds' ^\\alpha':eq(
	- conn5' ^\\alpha _\\beta _\\gamma' * u' ^\\beta' * u' ^\\gamma'
	- 2 * conn5' ^\\alpha _\\beta _5' * u' ^\\beta' * u'^5'
	- conn5' ^\\alpha _5 _5' * u'^5' * u'^5'
))
printbr(spacetimeGeodesic_def)

spacetimeGeodesic_def = betterSimplify(spacetimeGeodesic_def:replace(
	conn5' ^\\alpha _\\beta _\\gamma',
	conn5U_def[1][1][1]
))
spacetimeGeodesic_def = betterSimplify(spacetimeGeodesic_def:replace(
	conn5' ^\\alpha _\\beta _5',
	conn5U_def[1][1][2]
))
spacetimeGeodesic_def = betterSimplify(spacetimeGeodesic_def:replace(
	conn5' ^\\alpha _5 _\\gamma',
	conn5U_def[1][2][1]
))
spacetimeGeodesic_def = betterSimplify(spacetimeGeodesic_def:replace(
	conn5' ^\\alpha _5 _5',
	conn5U_def[1][2][2]
))
spacetimeGeodesic_def = betterSimplify(spacetimeGeodesic_def:replace(
	(phi_K^2 * A' _\\gamma' * u' ^\\beta' * u' ^\\gamma' * F' _\\beta ^\\alpha')(),
	phi_K^2 * A' _\\beta' * u' ^\\beta' * u' ^\\gamma' * F' _\\gamma ^\\alpha'
))
printbr(spacetimeGeodesic_def)

spacetimeGeodesic_def = betterSimplify(spacetimeGeodesic_def:replace(
	phi_K' _,\\mu' * g' ^\\alpha ^\\mu',
	phi_K' ^,\\alpha'
))
printbr(spacetimeGeodesic_def)

local mass = var'M'
local q = var'q'

local u5U_def = u'^5':eq( frac(1,4) * frac(q, m) * sqrt(frac(k_e, G)) )
local A5_def = A'_5':eq(c * sqrt(frac(k_e, G)))
local phi_K_def = phi_K:eq( 
	2 / c * sqrt(frac(G, k_e))
)

local substitutions = table{u5U_def, A5_def}
if constantScalarField then
	substitutions:insert(phi_K_def)
end
printbr('Substitute', substitutions:mapi(tostring):concat', ')

spacetimeGeodesic_def = betterSimplify(spacetimeGeodesic_def:subst(substitutions:unpack()))
printbr(spacetimeGeodesic_def)
printbr()
printbr'There you have gravitational force, Lorentz force, and an extra term.'
printbr()



printbr'separate space and time, substitute spacetime geodesic with Newtonian gravity, etc:'
printbr()

printbr'spatial evolution:'
local spatialGeodesic_def = spacetimeGeodesic_def:reindex{[' \\alpha']='i'}
printbr(spatialGeodesic_def)
printbr'splitting spacetime indexes into space+time'
spatialGeodesic_def = splitIndexes(spatialGeodesic_def, {['\\beta'] = {0, 'j'}, ['\\gamma'] = {0, 'k'}})
spatialGeodesic_def = betterSimplify(spatialGeodesic_def * c^2)
printbr(spatialGeodesic_def)

-- TODO just use a Lorentz factor and don't approximate anything
-- same with the Faraday tensor substitutions ... just use an ADM metric breakdown
printbr('low-velocity approximation:', u'^0':eq(1))
spatialGeodesic_def = betterSimplify(spatialGeodesic_def:replace(u'^0', 1))
printbr(spatialGeodesic_def)

printbr('Assume spacetime connection is only', conn4'^i_00')
spatialGeodesic_def = spatialGeodesic_def
	:replace(conn4'^i_j0', 0)
	:replace(conn4'^i_0k', 0)
	:replace(conn4'^i_jk', 0)

local E = var'E'
local epsilon = var'\\epsilon'
local B = var'B'

printbr('Assume', F'_0^i':eq(-frac(1,c) * E'^i'))
printbr('Assume', F'_i^j':eq(epsilon'_i^jk' * B'_k'))
spatialGeodesic_def = spatialGeodesic_def
	:replace(F'_0^i', -frac(1,c) * E'^i')
	:replace(F'_j^i', epsilon'^i_jl' * B'^l')
	:replace(F'_k^i', epsilon'^i_kl' * B'^l')

spatialGeodesic_def = betterSimplify(spatialGeodesic_def)
printbr(spatialGeodesic_def)

local phi_q = var('\\phi_q')
printbr('Substitute', A'_0':eq(frac(1,c) * phi_q), 'is the electric field potential')
spatialGeodesic_def = betterSimplify(spatialGeodesic_def:replace(A'_0', frac(1,c) * phi_q))
printbr(spatialGeodesic_def)
local r = var'r'
local mass2 = var'M_2'
printbr('Assume', conn4'^i_00':eq( frac(G * mass2 * var'x''^i', c^2 * r^3 )))
spatialGeodesic_def = betterSimplify(spatialGeodesic_def
	:replace(conn4'^i_00', frac(G * mass2 * var'x''^i', c^2 * r^3 ))
)
printbr(spatialGeodesic_def)
printbr()


printbr'Time evolution:'
local timeGeodesic_def = spacetimeGeodesic_def:reindex{[' \\alpha']=0}
printbr(timeGeodesic_def)
timeGeodesic_def = splitIndexes(timeGeodesic_def, {['\\beta'] = {0, 'j'}, ['\\gamma'] = {0, 'k'}})
printbr(timeGeodesic_def)

printbr('Low-velocity approximation:', u'^0':eq(1))
timeGeodesic_def = timeGeodesic_def:replace(u'^0', 1)():factorDivision()
printbr(timeGeodesic_def)

printbr('Assume spacetime connection is only', conn4'^i_00')
timeGeodesic_def = timeGeodesic_def
	:replaceIndex(conn4'^0_jk', 0)

printbr('Assume', F'_0^i':eq(-frac(1,c) * E'^i'))
printbr('Assume', F'_i^j':eq(epsilon'_i^jk' * B'_k'))
timeGeodesic_def = timeGeodesic_def
	:replace(F'_0^0', 0)
	:replace(F'_j^0', -frac(1,c) * E'_j')
	:replace(F'_k^0', -frac(1,c) * E'_k')

printbr('Substitute', A'_0':eq(frac(1,c) * phi_q), 'is the electric field potential')
spatialGeodesic_def = betterSimplify(spatialGeodesic_def:replace(A'_0', frac(1,c) * phi_q))

timeGeodesic_def = betterSimplify(timeGeodesic_def)
printbr(timeGeodesic_def)
printbr()


printbr'Look at the 5th dimension evolution:'
--local _5thGeodesic_def = geodesic5_def:reindex{a=5}
-- hmm, does :map have trouble with Equation?
--_5thGeodesic_def = splitIndexes(_5thGeodesic_def, {b = {' \\beta', 5}, c = {' \\gamma', 5}})
local _5thGeodesic_def = du_ds'^5':eq(-conn5'^5_bc' * u'^b' * u'^c')
printbr(_5thGeodesic_def)
_5thGeodesic_def = du_ds'^5':eq(
	-conn5' ^5 _\\beta _\\gamma' * u' ^\\beta' * u' ^\\gamma'
	-2 * conn5' ^5 _5 _\\beta' * u'^5' * u' ^\\beta'
	-conn5'^5_55' * (u'^5')^2
)
printbr(_5thGeodesic_def)
_5thGeodesic_def = betterSimplify(_5thGeodesic_def
	:replace(conn5' ^5 _\\beta _\\gamma', conn5U_def[2][1][1])
	:replace(conn5' ^5 _5 _\\beta', conn5U_def[2][1][2])
	:replace(conn5' ^5 _5 _5', conn5U_def[2][2][2])
)
printbr(_5thGeodesic_def)
printbr('Substitute', A5_def)
_5thGeodesic_def = _5thGeodesic_def:subst(A5_def)
printbr(_5thGeodesic_def)
if constantScalarField then
	printbr('Substitute', phi_K_def)
	_5thGeodesic_def = _5thGeodesic_def:subst(phi_K_def)
	printbr(_5thGeodesic_def)
end
_5thGeodesic_def = betterSimplify(_5thGeodesic_def)
printbr(_5thGeodesic_def)

_5thGeodesic_def = betterSimplify(_5thGeodesic_def:subst(A5_def))
printbr(_5thGeodesic_def)
printbr()



printbr('$u^5$ for an electron,', units.m_e_in_kg, ',', units.e_in_C)
symmath.simplifyConstantPowers = true	-- TODO like maxima? :simplify{scopeVars}
local elec_q_sqrt_ke_over_m_sqrt_G = u5U_def:rhs():subst(
	q:eq(units.e_in_C:rhs()), 
	m:eq(units.m_e_in_kg:rhs()), 
	units.k_e_in_SI_and_C,
	units.G_in_SI,
	kg_in_C
)()
printbr('So', u5U_def:rhs():eq( elec_q_sqrt_ke_over_m_sqrt_G ):eq( betterSimplify(elec_q_sqrt_ke_over_m_sqrt_G * units.c_in_m_s:rhs()) ) )
symmath.simplifyConstantPowers = false
printbr()


printbr'<hr>'


printbr'connection partial:'
local dconn5_2x2x2_def = Tensor('^a_bc', function(a,b,c)
	local x = conn5U_def[a][b][c]',d'()
	if constantScalarField then	
		x = x:replace(phi_K'_,d', 0)()
	end
	x = x:map(function(x)
		if TensorRef.is(x) and x[1] == A and x[2].symbol == 5 and x[3] and x[3].derivative then return 0 end
	end)
	return betterSimplify(x)
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
if not constantScalarField then
	-- this is to cancel a pair of terms in conn5USq^5_555
	conn5USq_def = conn5USq_def:replaceIndex(A' _\\epsilon' * phi_K' ^,\\epsilon', A' ^\\nu' * phi_K' _,\\nu')()
end
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

Ricci5_def = betterSimplify(Ricci5_def:symmetrizeIndexes(conn4, {2,3}))
Ricci5_def = Ricci5_def:symmetrizeIndexes(g, {1,2})()
Ricci5_def = betterSimplify(Ricci5_def:tidyIndexes{fixed=' \\alpha \\beta'})
Ricci5_def = Ricci5_def
	:replace(F' _\\gamma _\\beta' * F' _\\alpha ^\\gamma', -F' _\\beta _\\gamma' * F'_\\alpha ^\\gamma')
	:replace(F' _\\gamma _\\alpha' * F' _\\beta ^\\gamma', -F' _\\alpha ^\\gamma' * F'_\\beta _\\gamma')
	:simplify()

printbr(R5'_ab':eq(R5'^c_acb'))
printbr()
printbr(R5'_ab':eq(Ricci5_def))
printbr()


printbr'Gaussian curvature:'

local Gaussian5_def = (Ricci5_def'_ab' * g5U_def'^ab')()
Gaussian5_def = Gaussian5_def:replace(R' _\\alpha _\\beta' * g' ^\\alpha ^\\beta', R)()
Gaussian5_def = betterSimplify(Gaussian5_def:tidyIndexes())

Gaussian5_def = Gaussian5_def:replace( (A' _\\zeta' * g' ^\\zeta ^\\epsilon')(), A' ^\\epsilon' )()
Gaussian5_def = Gaussian5_def:replace( (A' _\\epsilon' * g' ^\\zeta ^\\epsilon')(), A' ^\\zeta' )()
Gaussian5_def = Gaussian5_def:replace( (A' _\\epsilon' * g' ^\\epsilon ^\\zeta')(), A' ^\\zeta' )()
Gaussian5_def = Gaussian5_def:replace( (F' _\\zeta _\\eta' * g' ^\\eta ^\\epsilon')(), F' _\\zeta ^\\epsilon' )()
Gaussian5_def = Gaussian5_def:replace( (F' _\\zeta _\\epsilon' * g' ^\\eta ^\\epsilon')(), F' _\\zeta ^\\eta' )()
Gaussian5_def = Gaussian5_def:tidyIndexes()()
Gaussian5_def = Gaussian5_def:reindex{[' \\alpha \\beta'] = ' \\mu \\nu'}	-- don't use alpha beta gamma delta, or anything already used in Ricci5_def ... in fact, add in an extra property for fixed indexes
Gaussian5_def = Gaussian5_def:replace( F' _\\gamma _\\nu' * g' ^\\mu ^\\gamma', -F' _\\nu ^\\mu' )()

printbr(R5:eq(Gaussian5_def))
printbr()


printbr'Einstein curvature:'
local G5 = var'\\tilde{G}'
local Einstein5_def = (Ricci5_def'_ab' - frac(1,2) * Gaussian5_def * g5_def'_ab')()
Einstein5_def = Einstein5_def:tidyIndexes{fixed=' \\alpha \\beta'}()
Einstein5_def = betterSimplify(Einstein5_def
	:replace( F' _\\beta ^\\epsilon' * F' _\\epsilon _\\alpha',  -F' _\\beta _\\epsilon' * F' _\\alpha ^\\epsilon' )
	:replace( F' _\\epsilon _\\beta', -F' _\\beta _\\epsilon')
)
printbr(G5'_ab':eq(Einstein5_def))
printbr()


printbr'<hr>'


-- TODO check units here
-- TODO build this better?  or just rho/c^2 u_a u_b + P g5_ab ?
printbr'stress-energy tensor:'

local T5 = var'\\tilde{T}'
local T5_def = Tensor('_ab', 
	{T5'_\\alpha _\\beta', T5'_\\alpha _5'},
	{T5'_5 _\\beta', T5'_55'}
)

printbr[[$\tilde{G}_{ab} = \frac{8 \pi G}{c^4} T_{ab}$]]
local EFE5_def = betterSimplify(Einstein5_def:eq(frac(8 * pi * G, c^4) * T5_def))
printbr(EFE5_def)
printbr()


printbr()
printbr'Looking at the $\\tilde{G}_{55}$ components:'
local EFE5_55_def = EFE5_def:lhs()[2][2]:eq( EFE5_def:rhs()[2][2] )
printbr(EFE5_55_def)
local substitutions = table{A5_def}
if constantScalarField then
	substitutions:insert(phi_K_def)
end
printbr('Substitute', substitutions:mapi(tostring):concat', ')
EFE5_55_def = betterSimplify(EFE5_55_def:subst(substitutions:unpack()))
printbr(EFE5_55_def)
printbr'Isolating the scalar curvature:'
EFE5_55_def = betterSimplify(EFE5_55_def:solve(R))
--EFE5_55_def = betterSimplify( -2 * (EFE5_55_def - EFE5_55_def[1]) + R)
printbr(EFE5_55_def)
printbr[[It looks like $\tilde{T}_{55}$ provides the scalar curvature information ... with the exception of that extra term]]
printbr'What is the magnitude of that extra term?'
local lastCoeff = frac(3,4) * frac(G, k_e * c^2)
symmath.simplifyConstantPowers = true
printbr(lastCoeff:eq(
	betterSimplify(lastCoeff:subst(units.k_e_in_SI_and_C, units.G_in_SI, units.c_in_m_s))
))
symmath.simplifyConstantPowers = false
printbr()


printbr()
printbr'Looking at the $\\tilde{G}_{5\\mu}$ components:'
local EFE5_5_mu_def = EFE5_def:lhs()[1][2]:eq( EFE5_def:rhs()[1][2] )
printbr(EFE5_5_mu_def)
printbr'Isolating the Faraday tensor divergence:'
EFE5_5_mu_def = betterSimplify((EFE5_5_mu_def - EFE5_5_mu_def[1]) / (A'_5' * phi_K^2 / 2) + F' _\\alpha ^\\epsilon _;\\epsilon ')
printbr(EFE5_5_mu_def)
local rho = var'\\rho'
local T5mu_def = T5' _\\alpha _5':eq( c^2 * rho * u'_5' * u' _\\alpha' )
printbr('Assume', T5mu_def)
EFE5_5_mu_def = betterSimplify(EFE5_5_mu_def:subst(T5mu_def))
printbr(EFE5_5_mu_def)
printbr('Substitute ', u5_l_def)
EFE5_5_mu_def = betterSimplify(EFE5_5_mu_def:subst(u5_l_def))
printbr(EFE5_5_mu_def)
printbr('Substitute', u5U_def)
EFE5_5_mu_def = betterSimplify(EFE5_5_mu_def:subst(u5U_def))
printbr(EFE5_5_mu_def)
printbr('Substitute', A5_def)
EFE5_5_mu_def = betterSimplify(EFE5_5_mu_def:subst(A5_def))
printbr(EFE5_5_mu_def)
if constantScalarField then
	printbr('Substitute', phi_K_def)
	EFE5_5_mu_def = betterSimplify(EFE5_5_mu_def:subst(phi_K_def))
	printbr(EFE5_5_mu_def)
end
printbr('Substitute', 
	k_e:eq(frac(1, 4 * pi * epsilon_0)), ',',
	(mu_0 * epsilon_0):eq(frac(1, c^2)), ',',
	'so ', k_e:eq(frac(mu_0 * c^2, 4 * pi))
)
EFE5_5_mu_def = betterSimplify(EFE5_5_mu_def:replace(k_e, frac(mu_0 * c^2, 4 * pi)))
printbr(EFE5_5_mu_def)
local J = var'J'
local fourCurrentDef = J' _\\alpha':eq( c * frac(q,m) * rho * u' _\\alpha' )
printbr('Let '..fourCurrentDef)
EFE5_5_mu_def[2] = betterSimplify(EFE5_5_mu_def[2] - mu_0 * fourCurrentDef:rhs() + mu_0 * fourCurrentDef:lhs())
printbr(EFE5_5_mu_def)
printbr'Move all but current to the left side:'
-- move all except mu_0 J to the other side
EFE5_5_mu_def = betterSimplify( -EFE5_5_mu_def + EFE5_5_mu_def:lhs() + mu_0 * J' _\\alpha' ):switch()
printbr(EFE5_5_mu_def)
printbr'Rewriting the right hand side as an operator'

-- TODO make sure this is up to date manually, or use some operators here
printbr[[
$
	(	
		12 \pi G \frac{1}{c^4 \mu_0} F^{\mu\nu} A_\alpha 
		+ \delta^\mu_\alpha \nabla^\nu
	) F_{\mu\nu} 
	- (
		16 \frac{1}{c^2} \pi G \rho u_\alpha u^\beta 
		+ R \delta^\beta_\alpha 
	) A_\beta 
	= \mu_0 J_\alpha
$<br>

In matter at macroscopic levels this becomes...<br>
$\mu_0 \nabla_\beta ( {Z_{\alpha\beta}}^{\mu\nu} F_{\mu\nu} ) = \mu_0 J_\alpha$<br>

...for some sort of operator $\nabla (Z \cdot ...)$...
]]


printbr()
printbr'Looking at the $\\tilde{G}_{\\mu\\nu}$ components:'
printbr[[$ \tilde{G}_{\alpha\beta} = 8 \pi \frac{G}{c^4} \tilde{T}_{\alpha\beta}$]]
local EFE5_mu_mu_def = EFE5_def:lhs()[1][1]:eq( EFE5_def:rhs()[1][1] )
printbr(EFE5_mu_mu_def)
printbr'Isolating the spacetime Einstein tensor.'
EFE5_mu_mu_def = betterSimplify(EFE5_mu_mu_def - EFE5_mu_mu_def[1] + R' _\\alpha _\\beta' - frac(1,2) * R * g' _\\alpha _\\beta')
printbr(EFE5_mu_mu_def)
if constantScalarField then
	printbr('Substitute', phi_K_def)
	EFE5_mu_mu_def = betterSimplify(EFE5_mu_mu_def:subst(phi_K_def))
	printbr(EFE5_mu_mu_def)

	printbr('Substitute', 
		k_e:eq(frac(1, 4 * pi * epsilon_0)), ',',
		(mu_0 * epsilon_0):eq(frac(1, c^2)), ',',
		'so ', k_e:eq(frac(mu_0 * c^2, 4 * pi))
	)
	EFE5_mu_mu_def = betterSimplify(EFE5_mu_mu_def:replace(k_e, frac(mu_0 * c^2, 4 * pi)))
	printbr(EFE5_mu_mu_def)
end

local T_EM = var'T_{EM}'
printbr('Let ', T_EM' _\\alpha _\\beta':eq(frac(1, mu_0) * (F' _\\alpha _\\mu' * F' _\\beta ^\\mu' - frac(1,4) * g' _\\alpha _\\beta' * F' _\\mu _\\nu' * F' ^\\mu ^\\nu')))
-- T_EM_ab = 1/mu0 (F_au F_b^u - 1/4 g_ab F_uv F^uv)
-- so F_ae F_b^e = mu0 T_EM_ab + 1/4 g_ab F_uv F^uv 
EFE5_mu_mu_def = betterSimplify(EFE5_mu_mu_def:replace(
	F' _\\beta _\\epsilon' * F' _\\alpha ^\\epsilon',
	mu_0 * T_EM' _\\alpha _\\beta' - frac(1,4) * g' _\\alpha _\\beta' * F' _\\epsilon ^\\zeta' * F' _\\zeta ^\\epsilon'
))
printbr(EFE5_mu_mu_def)
printbr()


printbr()
printbr[[using a specific stress-energy tensor:]]
printbr[[$\tilde{T}_{ab} = c^2 \rho u_a u_b + P (\tilde{g}_{ab} + u_a u_b)$]]
printbr()
local P = var'P'
local T5_def = Tensor('_ab', 
	{
		(c^2 * rho + P) * u' _\\alpha' * u' _\\beta' + P * g5' _\\alpha _\\beta',
		(c^2 * rho + P) * u' _\\alpha' * u'_5' + P * g5' _\\alpha _5',
	},
	{
		(c^2 * rho + P) * u' _\\beta' * u'_5' + P * g5' _\\beta _5',
		(c^2 * rho + P) * (u'_5')^2 + P * g5'_55'
	}
)
printbr(T5'_ab':eq(c^2 * rho * u'_a' * u'_b' + P*g5'_ab'))
printbr(T5'_ab':eq(T5_def))


printbr'substituting definitions for $\\tilde{g}_{ab}, A_5, u^a$...'

T5_def = betterSimplify(
	T5_def
		:replace(g5' _\\alpha _\\beta', g5_def[1][1])
		:replace(g5' _\\alpha _5', g5_def[1][2])
		:replace(g5' _\\beta _5', g5_def[2][1])
		:replace(g5'_55', g5_def[2][2])
		--:subst(u5U_def)	-- but we were looking at x'_5, not x'^5 ...
)
printbr(T5'_ab':eq(T5_def))
printbr()


--[[
What is the four-current in relation to the spacetime x 5th stress-energy?

T5_5α = c^2 ρ u_5 u_α
let u_5 = g_5a u^a = g_5_β u^β + g_55 u^5 = φ_K^2 A_5 (A_β u^β + A_5 u^5)
so T5_5α = c^2 ρ u_α φ_K^2 A_5 (A_β u^β + A_5 u^5)
let u^5 = q/m sqrt(k_e/G)	<- needed for Lorentz force law to emerge in geodesic
so T5_5α = c^2 ρ u_α φ_K^2 A_5 (A_β u^β + A_5 q/m sqrt(k_e/G))
let φ_K = 1/A_5
so T5_5α = c^2 ρ u_α (φ_K A_β u^β + q/m sqrt(k_e/G))
let A_5 = 1/φ_K = 1 in natural units = c sqrt(k_e/G)
so T5_5α = c ρ u_α sqrt(G/k_e) A_β u^β + c^2 q/m ρ u_α 
J_α = c q/m ρ u_α
so T5_5α = c J_α + c ρ u_α sqrt(G/k_e) A_β u^β
or T5_5α = c J_α + c^2 ρ u_α u^β A_β / A_5
well either way, T5_5α = something J_α plus something else

but this makes F_αβ^;β = 4 μ_0 J_α + extra ... off by a factor of 4 ...
so maybe T5__5α = 1/4 c J_α + something ...
then maybe T5_5α = c^2 ρ u_α (u_5 / 4)
and then the Gauss-Ampere laws come out of the G5_5α = 8 π T5_5α

but we also have G_αβ = 8 π G/c^4 (T_αβ + 1/4 T_EM_αβ) + extra
...and there is no way T_αβ can directly influence T_EM_αβ ... unless we include a proportion of T_EM_αβ inside T_αβ 
if we say F_αβ -> 2 F_αβ then we can get: G_αβ = 8 π G/c^4 (T_αβ + T_EM_αβ) + extra
but this really means A_α -> 2 A_α ... and all this will influence lots of things ...

and doing F_αβ -> 2 F_αβ only will leave F_αβ^;β = 2 μ_0 J_α, so you need to modify T5_ab as well

in the metric this is equivalent to just changing φ_K ...
φ_K -> 2 φ_K means 
... G_αβ = 8 π G/c^4 (T_αβ + T_EM_αβ) + extra
... F_αβ^;β = μ_0 J_α + extra
so it looks like a winner
but sure enough, it is going to haunt the Lorentz force law in the geodesic equation
how about if we say A_5 -> 4 A_5 to counter the effects in the Lorentz force law?  
won't help Gauss-Ampere, (though changing T5 would)
it would help the EFE spacetime stress-energy

so φ_K -> 2 φ_K fixes the EFE spacetime stress-energy but hurts Lorentz force and Gauss-Amepre
then A_5 -> 1/4 A_5 fixes Lorentz force but further maybe hurts Gauss-Ampere
then T5_5α -> 1/4 T5_5α to fix Gauss-Ampere
--]]



printbr()
printbr()
print(export.MathJax.footer)
