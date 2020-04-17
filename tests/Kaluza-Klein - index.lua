#!/usr/bin/env luajit
require 'ext'
require 'symmath'.setup()
local MathJax = symmath.export.MathJax
symmath.tostring = MathJax 
local printbr = MathJax.print
MathJax.header.title = 'Kaluza-Klein - index notation'
print(
	(tostring(MathJax.header):gsub(
		'</head>',
		[[<script type='text/javascript' src='template.js'/></script>
		<script type='text/javascript'>
Template.prototype.openstring = '{=={';		
Template.prototype.closestring = '}==}';		
		</script>
	</head>
]]):gsub('<body ', '<body templated ')
))


-- cmdline:

local constantScalarField = true
if arg[1] == 'varyingScalarField' then
	constantScalarField = false
end
--local constantScalarField = false	-- with implicitVars=true, you have to manually define your nil/false flags


-- this sets simplifyConstantPowers 
local units = require 'symmath.physics.units'()	--{valuesAsVars=true}


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

printbr[[coordinate convention: $dx^0 = c dt, \partial_0 = \frac{1}{c} \partial_t$]]
printbr()

printbr([[$c = $<input name='speed_of_light_in_m_per_s' value=']]..units.c_value_in_m_per_s..[['/> $\cdot \frac{m}{s} = 1 = $ the speed of light.]])
printbr([[$G = $<input name='gravitational_constant_in_m3_per_kg_s2' value=']]..units.G_value_in_m3_per_kg_s2..[['/> $\cdot \frac{m^3}{kg \cdot s^2} = 1 = $ gravitational constant.]])
printbr([[$k_e = $<input name='Coulomb_constant_in_kg_m3_per_C2_s2' value=']]..units.k_e_value_in_kg_m3_per_C2_s2..[['/> $\cdot \frac{kg \cdot m^3}{C^2 \cdot s^2}$ = Coulomb's constant (typically $\frac{1}{4 \pi \epsilon_0}$).]])

-- TODO compile symmath to JavaScript.  
-- That might mean using units{valuesAsVars=true} and then compiling them to have names matching the JavaScript variable names.
-- That also means separating the units.k_e_value, units.G_value from the units themselve (kg / C)
printbr(sqrt(k_e / G), [[ = {=={ sqrt_Coulomb_constant_over_gravitational_constant_in_kg_per_C = Math.sqrt(Coulomb_constant_in_kg_m3_per_C2_s2 / gravitational_constant_in_m3_per_kg_s2) }==} $ \cdot \frac{kg}{C} = 1 =$ conversion from kg to C]])

--[[ what I should compile to JavaScript
local kg_C_eq_1 = sqrt( units.k_e_in_SI_and_C:rhs() / units.G_in_SI:rhs() )():eq(1)
local kg_in_C = kg_C_eq_1:solve(kg)
printbr(kg_in_C)
--]]
-- [[ manually inlining the constants
printbr([[$kg = $ {=={ 1 / sqrt_Coulomb_constant_over_gravitational_constant_in_kg_per_C }==} $C$. ]])
--]]

Tensor.coords{{variables={'txyz','5'}}}


local greekSymbols = require 'symmath.tensor.symbols'.greekSymbolNames
	-- :sort(function(a,b) return a < b end)
	:filter(function(s) return s:match'^[a-z]' end)		-- lowercase
	:mapi(function(s) return '\\'..s end)				-- append \ to the beginning for LaTeX

Tensor.defaultSymbols = greekSymbols



local mass = var'M'
local q = var'q'

local u = var'u'

local A = var'A'
local A5_def = A'_5':eq(c * sqrt(frac(k_e, G)))

local phi_K = var'\\phi_K'
local phi_K_def = phi_K:eq( 2 / c * sqrt(frac(G, k_e)) )



printbr()
printbr(A'_u', '= electromagnetic four-potential, in units', (kg*m)/(C*s))
printbr(
	'$A_5$ is constant in natural units, but to cancel the units of $\\phi_K$ it is in units of', (kg*m)/(C*s),
	'so $A_5$ is proportional to $c \\sqrt{\\frac{k_e}{G}} = $', (units.c_in_m_s:rhs() * sqrt(units.k_e_in_SI_and_C:rhs() / units.G_in_SI:rhs()))():factorDivision()
)
printbr()

printbr(phi_K, '= scalar field, proportional to $\\frac{1}{A_5}$, in units', (C*s)/(kg*m))
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

printbr[[What is $u_5$ in terms of $u^5$?]]

--[[
u^5 = whatever
so what is u_5?
u_5 = g_5a u^a = g_5u u^u + g_55 u^5
u_5 = phi_K^2 A_5 A_a u^a + phi_K^2 A_5^2 u^5
u^5 = (u_5 - phi_K^2 A_5 A_a u^a) / (phi_K^2 A_5^2)
u^5 = phi_K^-2 A_5^-2 u_5 - A_5^-1 A_a u^a
--]]
local u5L_def = u'_5':eq(g5'_5a' * u'^a')
printbr(u5L_def)
-- split
local u5L_def = u'_5':eq(g5' _5 _\\beta' * u' ^\\beta' + g5'_55' * u'^5')
printbr(u5L_def)
printbr('substitute definition of '..g5'_ab')
local u5L_def = u'_5':eq(g5_def[2][1] * u' ^\\beta' + g5_def[2][2] * u'^5')
printbr(u5L_def)

printbr()
printbr'<hr>'


local u5U_def = u'^5':eq( frac(1,4) * frac(q, mass) * sqrt(frac(k_e, G)) )
local subs = table{u5U_def}
if constantScalarField then
	subs:append{A5_def, phi_K_def}
end
printbr'On a side note, later for the Lorentz force to arise we are going to set:'
printbr(subs:mapi(tostring):concat', ')
printbr()

if constantScalarField then
	printbr(A5_def, [[= {=={ A5L = speed_of_light_in_m_per_s * Math.sqrt(Coulomb_constant_in_kg_m3_per_C2_s2 / gravitational_constant_in_m3_per_kg_s2) }==} $\frac{kg \cdot m}{C \cdot s} =$ fifth component of electromagnetic potential.]])
	printbr(phi_K_def, [[= {=={ phiK = 2 / A5L }==} $\frac{C \cdot s}{kg \cdot m} =$ Kaluza-Klein 5th dimension scalar cylinder radius.]])
	printbr()
end

printbr[[For an electron this comes out to be...]]
printbr[[$e =$ <input name='electron_charge_in_C' value='1.602176620898e-19'/> $\cdot C$ = electron charge]]
printbr[[$m_e =$ <input name='electron_mass_in_kg' value='9.10938188e-31'/> $\cdot kg$ = electron mass]]
printbr[[$u^5 = \frac{1}{4} \frac{q}{M} \sqrt{\frac{k_e}{G}} =$ {=={ u5U = .25 * electron_charge_in_C / electron_mass_in_kg * Math.sqrt(Coulomb_constant_in_kg_m3_per_C2_s2 / gravitational_constant_in_m3_per_kg_s2) }==} = {=={ u5U * speed_of_light_in_m_per_s }==} $\frac{m}{s}$.]]
printbr()
printbr'<hr>'




-- I should put this in its own worksheet ...
printbr'What if we require a unit 5-velocity?'

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

printbr('Solve quadratic for', A'_5' * u'^5', '...')
local plusminus = class(require 'symmath.op.sub', {name='\\pm'})
plusminus.rules = nil
local u5_for_A5_def = u'^5':eq(
	frac(1,A'_5') * (
		plusminus(
			-A' _\\mu' * u' ^\\mu',
			sqrt(
				(A' _\\mu' * u' ^\\mu')^2 - phi_K^-2 * (u' _\\mu' * u' ^\\mu' + 1)
			)
		)
	)
)
printbr(u5_for_A5_def)
-- TODO I'm redefining this because betterSimplify()ing sqrts seems to make ^(1/2)'s pop up everywhere
local u5_for_A5_when_u4norm_is_unit = u'^5':eq( -2 * frac(1,A'_5') * A' _\\mu' * u' ^\\mu' )
printbr([[Notice that if we assume $u_\mu u^\mu = -1$ then this simplifies to]], u5_for_A5_when_u4norm_is_unit, [[, however in reality things might instead be $u_\mu u^\mu \approx -1$]])
printbr()

printbr'If we substitute our definition for $u^5$ then the solution of the quadratic looks like:'
u5_for_A5_def = u5_for_A5_def:subst(u5U_def)
printbr(u5_for_A5_def)
u5_for_A5_def = betterSimplify(u5_for_A5_def * 4 * sqrt(frac(G, k_e)))
printbr(u5_for_A5_def)

printbr[[Let's look at the magnitude of this for some real-world values.]]
printbr[[Electrons in a copper wire (from my 'magnetic field from a boosted charge' worksheet).]]
printbr[[$N_A = $<input name='Avogadro_constant_in_1_per_mol' value='6.02214085774e+23'/> $\cdot \frac{1}{mol}$ = Avogadro's constant.]]
printbr[[$m_a =$ <input name='atomic_mass_in_g' value='63.54'/> $\frac{g}{mol} =$ {=={atomic_mass_in_kg = 1e-3 * atomic_mass_in_g}==} $ \cdot \frac{kg}{mol} = $ atomic mass.]]
printbr[[$n_v =$ <input name='material_nominal_valency' value='1'/> nominal valency.]]
printbr[[$\rho =$ <input name='material_density_in_g_per_cm3' value='8.95'/> $\frac{g}{cm^3} =$ {=={material_density_in_kg_per_m3 = material_density_in_g_per_cm3 * 1e+3}==} $\frac{kg}{m^3} = $ matter density.]]
printbr[[$n_e = \frac{N_A \cdot n_v}{m_a} = $ {=={free_electrons_per_kg = Avogadro_constant_in_1_per_mol * material_nominal_valency / atomic_mass_in_kg}==} $\frac{e}{kg} = $ free electrons per kg.]]
printbr[[$\rho_{charge} = n_e \cdot \rho = $ {=={electron_density_in_e_per_m3 = free_electrons_per_kg * material_density_in_kg_per_m3}==} $\frac{e}{m^3}$ = electron density.]]
printbr[[$R =$ <input name='wire_radius_in_mm' value='1.3'/> $mm =$ {=={wire_radius_in_m = wire_radius_in_mm * 1e-3}==} $m =$ wire radius.]]
printbr[[$r = \sqrt{y^2 + z^2} =$ <input name='field_measure_distance_in_m' value='.1'/> $m = $ distance of measurement from the wire along the x-axis.]]
printbr[[$A = \pi R^2 =$ {=={wire_cross_section_area_in_m2 = Math.PI * wire_radius_in_m * wire_radius_in_m}==} $m^2 =$ wire cross-section area]]
printbr[[$I =$ <input name='current_in_A' value='1.89'/> $A =$ current in wire.]]
printbr[[$q = \rho_{charge} \cdot e =$ {=={charge_density_in_C_per_m3 = electron_density_in_e_per_m3 * electron_charge_in_C}==} $\frac{C}{m^3} = $ charge density.]]
printbr[[$\lambda = A q = \pi R^2 \rho_{charge} e =$ {=={charge_per_unit_length_in_C_per_m = charge_density_in_C_per_m3 * wire_cross_section_area_in_m2}==} $\frac{C}{m}$ = charge density per unit meter along wire]]
printbr[[$v = \frac{I}{\lambda} =$ {=={mean_electron_velocity_in_m_per_s = current_in_A / (wire_cross_section_area_in_m2 * charge_density_in_C_per_m3)}==} $\frac{C}{m} =$ charge density per unit meter along wire.]]
printbr[[$\beta = \frac{v}{c} =$ {=={Lorentz_beta = mean_electron_velocity_in_m_per_s / speed_of_light_in_m_per_s}==} = unitless, spatial component of 4-velocity.]]
printbr[[$\gamma = 1 / \sqrt{1 - \beta^2} \approx 1 + \frac{v^2}{2 c^2} \approx $ 1 + {=={Lorentz_gamma_minus_one = .5 * Lorentz_beta * Lorentz_beta}==} $\approx$ {=={Lorentz_gamma = 1 + Lorentz_gamma_minus_one}==} = Lorentz factor.]]
printbr[[$E = 2 \lambda k_e \frac{1}{r} \frac{v^2}{c^2} = \frac{\lambda}{2 \pi \epsilon_0 r} \frac{v^2}{c^2} = 2 \pi R^2 \rho_{charge} e k_e \frac{1}{r} =$ {=={electric_field_in_kg_m2_per_C_s2 = charge_per_unit_length_in_C_per_m * 2 * Coulomb_constant_in_kg_m3_per_C2_s2 / field_measure_distance_in_m * (mean_electron_velocity_in_m_per_s * mean_electron_velocity_in_m_per_s) / (speed_of_light_in_m_per_s * speed_of_light_in_m_per_s)}==} $\cdot \frac{kg \cdot m}{C \cdot s^2}$ = electric field magnitude.]]
printbr[[$B = \frac{1}{c} \beta \gamma E = $ {=={magnetic_field_in_kg_m_per_C_s = Lorentz_beta * Lorentz_gamma * (electric_field_in_kg_m2_per_C_s2 / speed_of_light_in_m_per_s) }==} $\frac{kg}{C \cdot s} =$ magnetic field magnitude.]]
printbr[[$u^0 = \gamma, u^1 = \beta \gamma, u^2 = u^3 = 0$ = our 4-velocity components, such that $\eta_{\mu\nu} u^\mu u^\nu = -1$.]]
printbr[[$\phi_q = \frac{1}{2} \lambda k_e ln ( \frac{r}{r_0} ) =$ electric potential.]]
printbr[[... but what is $r_0$?  The EM potential has a constant which does not influence 4D or 3D EM, but will influence 5D EM.]]
printbr()
printbr[[Let's look at the potential with and without the constant: $\phi_q = \phi'_q + \phi''_q$.]]
printbr[[$\phi'_q = \frac{1}{2} \lambda k_e ln(r) =$ {=={ electric_potential_in_kg_m2_per_C_s2 = .5 * charge_density_in_C_per_m3 * Coulomb_constant_in_kg_m3_per_C2_s2 * Math.log(field_measure_distance_in_m) }==} $\frac{kg \cdot m^2}{C \cdot s^2}$.]]
printbr[[$\phi''_q = \frac{1}{2} \lambda k_e ln(r_0) = $ arbitrary.]]
printbr[[$A_i = 0 = $ magnetic vector potential.]]
printbr[[So $A_\mu u^\mu = A_0 u^0 = \frac{1}{c} \phi_q \gamma = $ {=={ A_dot_u = electric_potential_in_kg_m2_per_C_s2 / speed_of_light_in_m_per_s * Lorentz_gamma }==} $ \frac{kg \cdot m}{C \cdot s} + \frac{1}{c} \phi''_q \gamma$.]]
printbr[[And $\frac{1}{A_5} A_\mu u^\mu = $ {=={ A_dot_u_over_A5L = A_dot_u / A5L }==} $ + \frac{1}{c A_5} \phi''_q \gamma$]]
printbr()
printbr[[Assume $u_\mu u^\mu = -1$.]]
printbr[[$u^5 = -2 \frac{1}{A_5} A_\mu u^\mu = $ {=={ -2 * A_dot_u_over_A5L }==} $ - \frac{1}{c A_5} \gamma \phi''_q$]]
printbr()
printbr[[Let's insert this into the $u^5$ equation above and solve to find what $\phi''_q$ would be:]]
-- TODO keep converting
printbr[[
$\frac{1}{c A_5} \gamma \phi''_q = \frac{1}{4} \frac{q}{M} \sqrt{\frac{k_e}{G}}$<br>
$\phi''_q = \frac{1}{4} c^2 \frac{q}{\gamma m} \frac{k_e}{G} = \frac{1}{4} c^2 \frac{q}{M} \frac{k_e}{G} \sqrt{1 - \beta^2}$<br>
Using our electron charge-to-mass ratio this gives us:
$\phi''_q =$ {=={ u5U * speed_of_light_in_m_per_s * A5L / Lorentz_gamma }==} $\frac{kg \cdot m^2}{C \cdot s^2}$<br>
...which is a few orders of magnitude higher than what contributes to the EM field.<br>
<br>

So, assuming we want our 5-velocity to be normalized with the 5-metric, and assuming our 4-velocity is normalized with the 4-metric,
then it looks like the 5th velocity is made up of two parts:<br>
1) the EM potential, dot the negligible 4-vel, which is on the order of $10^{-12}$ for our current through a copper wire.<br>
2) the the arbitrary constant, which must relate to the charge-mass ratio, which is on the order of $10^{21}$.<br>
Also notice that this shows then the charge-mass ratio in the Lorentz force law will be influenced by the 3-velocity.<br>
<br>

Of course you can avoid the constraint that that charge-mass ratio is dependent on the 3-velocity if you just relax the constraint of $u_\mu u^\mu = -1$.<br>
Then, for constaint $u^5 = \frac{1}{4} \frac{q}{M} \sqrt{\frac{k_e}{G}}$, 
any deviations in the electric potential $A_t$ could relate to deviations in the 4-vel-norm (or in deviations in the Kaluza field, which I am keeping constant in this worksheet).<br> 
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
printbr'geodesic equation:'
local geodesic5_def = du_ds'^a':eq( - conn5'^a_bc' * u'^b' * u'^c')
printbr(geodesic5_def)
printbr[[(Notice I am unifortunately denoting $\dot{u}^a = \partial_0 u^a = \frac{1}{c} \partial_t u^a$)]]
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
spatialGeodesic_def = betterSimplify(spatialGeodesic_def * c^2)	-- multiply by c^2 <=> convert units of rhs to m/s^2 
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
local epsilon = var'\\epsilon'	-- Levi-Civita
local B = var'B'

local F00LU_def = F'_0^0':eq(0)
local EL_from_F = F'_i^0':eq(-frac(1,c) * E'_i')
local EU_from_F = F'_0^i':eq(-frac(1,c) * E'^i')
local B_from_F = F'_i^j':eq(epsilon'_i^jk' * B'_k')

printbr'Low-velocity Faraday tensor:'
printbr('Assume', EU_from_F, ',', B_from_F)
spatialGeodesic_def = spatialGeodesic_def:subst(
	EU_from_F,
	B_from_F:reindex{ijk='jil'}, 
	B_from_F:reindex{ijk='kil'}, 
	(B'_l' * epsilon'_k^il'):eq(-B'^l' * epsilon'^i_kl'),
	(B'_l' * epsilon'_j^il'):eq(-B'^k' * epsilon'^i_jk')
)

spatialGeodesic_def = betterSimplify(spatialGeodesic_def)
printbr(spatialGeodesic_def)

local phi_q = var('\\phi_q')
printbr('Substitute', A'_0':eq(frac(1,c) * phi_q), 'is the electric field potential')
spatialGeodesic_def = betterSimplify(spatialGeodesic_def:replace(A'_0', frac(1,c) * phi_q))
printbr(spatialGeodesic_def)
local r = var'r'
local mass2 = var'M_2'
local Newton_gravity_conn_def = conn4'^i_00':eq( frac(G * mass2 * var'x''^i', c^2 * r^3 ))
printbr('Assume', Newton_gravity_conn_def)
spatialGeodesic_def = betterSimplify(spatialGeodesic_def:subst(Newton_gravity_conn_def))
printbr(spatialGeodesic_def)
-- u = v/c <-> v = c u
-- du/ds = 1/c^2 dv/dt <-> dv/dt = c^2 du/ds
local t = var't'
local v = var('v', {t})
local u_from_v = u'^i':eq(frac(1,c) * v'^i')
local du_ds_from_dv_dt = du_ds'^i':eq(frac(1,c^2) * diff(v'^i', t))
printbr('Let', u_from_v, ',', du_ds_from_dv_dt)
spatialGeodesic_def = betterSimplify(spatialGeodesic_def:subst(
	u_from_v,
	u_from_v:reindex{i='j'},
	u_from_v:reindex{i='k'},
	du_ds_from_dv_dt
))
printbr(spatialGeodesic_def)
-- TODO real-world values ... 
-- *) what is the force produced on an electron in the magnetic field around the wire given above?
-- *) what is the force produced on an electron from the gravitational field of the Earth?
-- *) how about the other terms...
local earthradius = 6.371e+6 * m
local earthmass = 5.972e+24 * kg
local substitutions = table{
	-- physical constants
	units.G_in_SI,
	units.k_e_in_SI_and_C,
	-- what is acting upon our particle 
	mass2:eq(earthmass),
	r:eq(earthradius),
	-- our moving particle
	q:eq(units.e_in_C:rhs()),
	mass:eq(units.m_e_in_kg:rhs()),
	var'x''^i':eq(var'\\hat{r}''^i' * earthradius), -- in m
	-- TODO electric and magnetic fields ..
	-- and TODO the four-potential from above with the u-5-normalized constraint above
	var'E''^i':eq(3.2425382804712735e+15 * var'\\hat{E}''^i' * frac(kg * m, C * s^2)),
	var'B''^i':eq(9.450002793287516e-7 * var'\\hat{B}''^i' * frac(kg, C * s)),
}
printbr([[Using real-world values:]], substitutions:mapi(tostring):concat', ')
symmath.simplifyConstantPowers = true
if symmath.op.add.is(spatialGeodesic_def:rhs()) then
	printbr[[...and looking at each term:]]
	for _,term in ipairs(spatialGeodesic_def:rhs()) do
		local realWorldValue = betterSimplify(term:subst(substitutions:unpack()))
		printbr(term:eq(realWorldValue))
	end
end
symmath.simplifyConstantPowers = false
printbr()


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
timeGeodesic_def = timeGeodesic_def:replaceIndex(conn4'^0_jk', 0)

printbr('Assume', EL_from_F, ',', F00LU_def)
timeGeodesic_def = timeGeodesic_def
	:subst(F00LU_def)
	:subst(EL_from_F:reindex{i='j'})
	:subst(EL_from_F:reindex{i='k'})

printbr('Substitute', A'_0':eq(frac(1,c) * phi_q), 'is the electric field potential')
timeGeodesic_def = betterSimplify(timeGeodesic_def:replace(A'_0', frac(1,c) * phi_q))
printbr(timeGeodesic_def)
printbr()


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


--[[ A_5 doesn't seem to appear anywhere
_5thGeodesic_def = betterSimplify(_5thGeodesic_def:subst(A5_def))
printbr(_5thGeodesic_def)
--]]

--[[
_5thGeodesic_def = betterSimplify(_5thGeodesic_def
	:replace(
		u' ^\\beta' * A' _\\beta' * u' ^\\gamma' * F' _\\gamma ^\\mu' * A' _\\mu',
		u' ^\\gamma' * A' _\\gamma' * u' ^\\beta' * F' _\\beta^\\mu' * A' _\\mu'
	)
	:replace(
		u' ^\\beta' * F' _\\beta ^\\mu' * A' _\\mu',
		u' ^\\beta' * A' ^\\gamma' * (A' _\\gamma _,\\beta' - A' _\\beta _,\\gamma')
	)
)
--]]
-- [[
_5thGeodesic_def[2] = betterSimplify(_5thGeodesic_def[2]
	- 2 * (G/(k_e*c^2))^frac(3,2) * u' ^\\beta' * A' _\\mu' * A' _\\beta' * u' ^\\gamma' * F' _\\gamma ^\\mu'
	+ 2 * (G/(k_e*c^2))^frac(3,2) * u' ^\\mu' * A' _\\mu' * u' ^\\beta' * A' ^\\gamma' * (A' _\\gamma _,\\beta' - A' _\\beta _,\\gamma')

	- 2 * (G/(k_e*c^2))^frac(3,2) * u' ^\\beta' * A' _\\mu' * A' _\\gamma' * u' ^\\gamma' * F' _\\beta ^\\mu'
	+ 2 * (G/(k_e*c^2))^frac(3,2) * u' ^\\mu' * A' _\\mu' * u' ^\\beta' * A' ^\\gamma' * (A' _\\gamma _,\\beta' - A' _\\beta _,\\gamma')

	- 4 * (G/(k_e*c^2)) * u' ^\\beta' * u'^5' * A' _\\mu' * F' _\\beta ^\\mu'
	+ 4 * (G/(k_e*c^2)) * u' ^\\beta' * u'^5' * A' ^\\gamma' * (A' _\\gamma _,\\beta' - A' _\\beta _,\\gamma')
)
--]]
printbr(_5thGeodesic_def)

_5thGeodesic_def = betterSimplify(_5thGeodesic_def:subst(u5U_def))
printbr(_5thGeodesic_def)

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

if not constantScalarField then
	Riemann5_def = Riemann5_def:replace(phi_K' _,\\delta _,\\gamma', phi_K' _,\\gamma _,\\delta')()
end

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
Ricci5_def = betterSimplify(Ricci5_def)
if not constantScalarField then
	Ricci5_def = Ricci5_def
		:replace(phi_K' ^,\\gamma _,\\gamma', phi_K' _;\\gamma ^;\\gamma' - phi_K' ^,\\gamma' * conn4' ^\\delta _\\delta _\\gamma')
		:replace(phi_K' ^,\\gamma' * F' _\\gamma _\\beta', -phi_K' _,\\gamma' * F' _\\beta ^\\gamma')
		:replace(phi_K' ^,\\gamma' * F' _\\gamma _\\alpha', -phi_K' _,\\gamma' * F' _\\alpha ^\\gamma')
		:replace(phi_K' _,\\gamma _,\\beta' * A' ^\\gamma', A' _\\gamma' * phi_K' ^,\\gamma _,\\beta' + phi_K' ^,\\gamma' * A' _\\gamma _,\\beta' - phi_K' _,\\gamma' * A' ^\\gamma _,\\beta')
	
	Ricci5_def[1][1] = Ricci5_def[1][1]
		:replace(phi_K' _,\\alpha _,\\beta', phi_K' _;\\alpha _;\\beta' + phi_K' _,\\gamma' * conn4' ^\\gamma _\\alpha _\\beta')
		:replace(A' _\\gamma' * phi_K' ^,\\gamma', A' ^\\gamma' * phi_K' _,\\gamma')
	
	Ricci5_def = betterSimplify(Ricci5_def)
end

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
Gaussian5_def = betterSimplify(Gaussian5_def)

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
if not constantScalarField then
	Einstein5_def = Einstein5_def:replace(g' ^\\epsilon ^\\zeta' * phi_K' _;\\epsilon _;\\zeta', phi_K' _;\\epsilon ^;\\epsilon')
	Einstein5_def = Einstein5_def:replace(A' _\\epsilon' * g' ^\\epsilon ^\\eta', A' ^\\eta')
	Einstein5_def = betterSimplify(Einstein5_def)
	Einstein5_def = Einstein5_def:tidyIndexes{fixed=' \\alpha \\beta'}()
	Einstein5_def = betterSimplify(Einstein5_def)
	Einstein5_def = Einstein5_def:replace(A' _\\gamma' * g' ^\\theta ^\\gamma', A' ^\\theta')
	Einstein5_def = betterSimplify(Einstein5_def)
	Einstein5_def = Einstein5_def:tidyIndexes{fixed=' \\alpha \\beta'}()
	Einstein5_def = betterSimplify(Einstein5_def)
end
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


local k_e_in_mu_0 = k_e:eq(frac(mu_0 * c^2, 4 * pi))

printbr()
printbr'Looking at the $\\tilde{G}_{55}$ components:'
local EFE5_55_def = EFE5_def:lhs()[2][2]:eq( EFE5_def:rhs()[2][2] )
printbr(EFE5_55_def)
printbr'Isolating the $\\tilde{T}_{55}$ stress-energy term:'
local T5_55_def_from_EFE5_55 = betterSimplify(EFE5_55_def:solve(T5'_55'))
printbr(T5_55_def_from_EFE5_55)
printbr'Isolating the spacetime scalar curvature R:'
local R_from_EFE5 = betterSimplify(EFE5_55_def:solve(R))
printbr(R_from_EFE5)

printbr[[Look at it with our substituted values:]]
local substitutions = table{A5_def}
if constantScalarField then
	substitutions:insert(phi_K_def)
end
substitutions:insert(k_e_in_mu_0)
printbr('Substitute', substitutions:mapi(tostring):concat', ')
local R_from_EFE5_wrt_mu0 = betterSimplify(R_from_EFE5:subst(substitutions:unpack()))
printbr(R_from_EFE5_wrt_mu0)
printbr[[It looks like $\tilde{T}_{55}$ provides the scalar curvature information ... with the exception of that extra term]]
printbr'What is the magnitude of that extra term?'
-- F_α^β F_β^α = F_0^0 F_0^0 + F_0^i F_i^0 + F_i^0 F_0^i + F_i^j F_j^i
-- = 2 (E_k E^k / c^2 - B_k B^k)
-- so 1/μ_0 (F_α^β F_β^α) = 2 (1/ε_0 E^2 - 1/μ_0 B^2)
--[[
local lastCoeff = frac(3,4) * frac(G, k_e * c^2)
symmath.simplifyConstantPowers = true
printbr(lastCoeff:eq(
	betterSimplify(lastCoeff:subst(units.k_e_in_SI_and_C, units.G_in_SI, units.c_in_m_s))
))
symmath.simplifyConstantPowers = false
--]]
printbr()


printbr()
printbr'Looking at the $\\tilde{G}_{5\\mu}$ components:'
local EFE5_5_mu_def = EFE5_def:lhs()[1][2]:eq( EFE5_def:rhs()[1][2] )
printbr(EFE5_5_mu_def)
printbr'Isolating the Faraday tensor divergence:'
local divF_from_EFE5_5_mu = betterSimplify(EFE5_5_mu_def:solve(F' _\\alpha ^\\epsilon _;\\epsilon '))
printbr(divF_from_EFE5_5_mu)
printbr('Substitute', R_from_EFE5)
divF_from_EFE5_5_mu = betterSimplify(divF_from_EFE5_5_mu:subst(R_from_EFE5)) 
printbr(divF_from_EFE5_5_mu)
printbr[[And that conveniently cancelled a term.  Now let's substitute the definition of $\tilde{T}_{55}$]]
local rho = var'\\rho'

local T5mu_def = T5' _\\alpha _5':eq( c^2 * rho * u'_5' * u' _\\alpha' )
local substitutions = table{
	T5_55_def_from_EFE5_55,
	T5mu_def,
	u5L_def:reindex{[' \\beta'] = ' \\epsilon'},
	u5U_def,
	A5_def,
}
if constantScalarField then
	substitutions:insert(phi_K_def)
end
substitutions:insert(k_e_in_mu_0)
printbr()
printbr'Now to take a detour and write the stress-energy in terms of the four-current to see the Gauss-Ampere laws emerge:'
printbr'Bring back the scalar curvature term R from $\\tilde{T}_{55}$ and rewrite $\\tilde{T}_{5\\alpha}$ in terms of five-momentum:'
printbr('Substitute', substitutions:mapi(tostring):concat', ')
local divF_from_EFE5_5_mu_J = betterSimplify(divF_from_EFE5_5_mu:subst(substitutions:unpack()))
printbr(divF_from_EFE5_5_mu_J)
local J = var'J'
local fourCurrentDef = J' _\\alpha':eq( c * frac(q,mass) * rho * u' _\\alpha' )
printbr('Define our four-current as', fourCurrentDef)
divF_from_EFE5_5_mu_J = betterSimplify(divF_from_EFE5_5_mu_J:lhs():eq(divF_from_EFE5_5_mu_J:rhs() - mu_0 * fourCurrentDef:rhs() + mu_0 * fourCurrentDef:lhs()))
printbr(divF_from_EFE5_5_mu_J)
printbr'Move all but current to the left side:'
-- move all except mu_0 J to the other side
divF_from_EFE5_5_mu_J = betterSimplify( -divF_from_EFE5_5_mu_J + divF_from_EFE5_5_mu_J:lhs() + mu_0 * J' _\\alpha' ):switch()
printbr(divF_from_EFE5_5_mu_J)
if constantScalarField then
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
end
printbr()


printbr()
printbr'Looking at the $\\tilde{G}_{\\mu\\nu}$ components:'
printbr[[$ \tilde{G}_{\alpha\beta} = 8 \pi \frac{G}{c^4} \tilde{T}_{\alpha\beta}$]]
local EFE5_mu_nu_def = EFE5_def:lhs()[1][1]:eq( EFE5_def:rhs()[1][1] )
printbr(EFE5_mu_nu_def)
printbr'Isolating the spacetime Einstein tensor.'
EFE5_mu_nu_def = EFE5_mu_nu_def - EFE5_mu_nu_def[1] + R' _\\alpha _\\beta' - frac(1,2) * R * g' _\\alpha _\\beta'
EFE5_mu_nu_def = EFE5_mu_nu_def:replace(R' _\\alpha _\\beta', G' _\\alpha _\\beta' + frac(1,2) * R * g' _\\alpha _\\beta')
EFE5_mu_nu_def = betterSimplify(EFE5_mu_nu_def)
printbr(EFE5_mu_nu_def)
printbr('Substitute', R_from_EFE5, A5_def)
EFE5_mu_nu_def = betterSimplify(EFE5_mu_nu_def:subst(R_from_EFE5, A5_def))
printbr(EFE5_mu_nu_def)
printbr'Notice that substituting R conveniently cancelled another of the terms on the r.h.s,'
if constantScalarField then
	local substitutions = table{phi_K_def, k_e_in_mu_0}
	printbr('Substitute', substitutions:mapi(tostring):concat', ')
	EFE5_mu_nu_def = betterSimplify(EFE5_mu_nu_def:subst(substitutions:unpack()))
	printbr(EFE5_mu_nu_def)
end
local T_EM = var'T_{EM}'
printbr('Let ', T_EM' _\\alpha _\\beta':eq(frac(1, mu_0) * (F' _\\alpha _\\mu' * F' _\\beta ^\\mu' - frac(1,4) * g' _\\alpha _\\beta' * F' _\\mu _\\nu' * F' ^\\mu ^\\nu')))
-- T_EM_ab = 1/mu0 (F_au F_b^u - 1/4 g_ab F_uv F^uv)
-- so F_ae F_b^e = mu0 T_EM_ab + 1/4 g_ab F_uv F^uv 
EFE5_mu_nu_def = betterSimplify(EFE5_mu_nu_def:replace(
	F' _\\beta _\\epsilon' * F' _\\alpha ^\\epsilon',
	mu_0 * T_EM' _\\alpha _\\beta' - frac(1,4) * g' _\\alpha _\\beta' * F' _\\epsilon ^\\zeta' * F' _\\zeta ^\\epsilon'
))
printbr(EFE5_mu_nu_def)
-- can't just say "replace R" because it will substitute the indexed R's ... 
-- but I'll replace the R_αβ - 1/2 R g_αβ with G_αβ
printbr('Substitute', divF_from_EFE5_5_mu)
local EFE5_mu_nu_def_A = betterSimplify(EFE5_mu_nu_def:subst(
	divF_from_EFE5_5_mu,
	divF_from_EFE5_5_mu:reindex{[' \\alpha'] = ' \\beta'},
	A5_def,
	phi_K_def,
	k_e_in_mu_0
))
printbr(EFE5_mu_nu_def_A)
printbr'Substitute our specific stress-energy and four-current definitions:'
local EFE5_mu_nu_def_B = betterSimplify(EFE5_mu_nu_def:subst(
	divF_from_EFE5_5_mu_J,
	divF_from_EFE5_5_mu_J:reindex{[' \\alpha'] = ' \\beta'},
	A5_def,
	phi_K_def,
	k_e_in_mu_0
))
printbr(EFE5_mu_nu_def_B)
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


printbr'Substituting definitions for $\\tilde{g}_{ab}, u_5, u^5, A_5, \\phi_K$...'

T5_def = T5_def
	:replace(g5' _\\alpha _\\beta', g5_def[1][1])
	:replace(g5' _\\alpha _5', g5_def[1][2])
	:replace(g5' _\\beta _5', g5_def[2][1])
	:replace(g5'_55', g5_def[2][2])
	:subst(u5L_def, u5U_def, A5_def)
if constantScalarField then
	T5_def = T5_def:subst(phi_K_def)
end
T5_def = betterSimplify(T5_def)
printbr(T5'_ab':eq(T5_def))
printbr()


printbr()
printbr()
print(export.MathJax.footer)
