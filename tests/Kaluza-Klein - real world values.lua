#!/usr/bin/env luajit
require 'ext'
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath'.setup{env=env}
local MathJax = symmath.export.MathJax
symmath.tostring = MathJax 
local printbr = MathJax.print
MathJax.header.title = 'Kaluza-Klein - real world values'
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
		if symmath.op.add:isa(term) then
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

local chart = Tensor.Chart{coords={'txyz','5'}}


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


symmath.simplifyConstantPowers = true
printbr(
	'$A_5$ is constant in natural units, but to cancel the units of $\\phi_K$ it is in units of', (kg*m)/(C*s),
	'so $A_5$ is proportional to $c \\sqrt{\\frac{k_e}{G}} = $', (units.c_in_m_s:rhs() * sqrt(units.k_e_in_SI_and_C:rhs() / units.G_in_SI:rhs()))():factorDivision()
)
symmath.simplifyConstantPowers = false
printbr()

printbr(phi_K, '= scalar field, proportional to $\\frac{1}{A_5}$, in units', (C*s)/(kg*m))
printbr()


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

local origUnitVelEqn = (g5'_ab' * u'^a' * u'^b'):eq(-1)()
printbr(origUnitVelEqn)
local unitVelEqn = origUnitVelEqn:clone()

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

unitVelEqn = (unitVelEqn + 1)():replace(g' _\\alpha _\\beta' * u' ^\\alpha' * u' ^\\beta', u' _\\mu' * u' ^\\mu')
printbr(unitVelEqn)

local solns = table{unitVelEqn:solve(u'^5')}:mapi(function(soln)
	return (soln:replace(A' _\\alpha'^2 * u' ^\\alpha'^2, A' _\\alpha' * u' ^\\alpha' * A' _\\beta' * u' ^\\beta'))():reindex{[' \\alpha'] = ' \\mu'}
end)
printbr(solns:mapi(tostring):concat',')

--printbr('Assume', ( g' _\\alpha _\\beta' * u' ^\\alpha' * u' ^\\beta' ):eq(-1))
--unitVelEqn = unitVelEqn:replace( (g' _\\alpha _\\beta' * u' ^\\alpha' * u' ^\\beta')(), -1)()
--printbr(unitVelEqn)

printbr('Solve quadratic for', u'^5', ':')
local plusminus = class(require 'symmath.op.sub', {name='\\pm'})
plusminus.rules = nil
local u5_for_A5_def = u'^5':eq(
	frac(1,A'_5') * (
		plusminus(
			-A' _\\mu' * u' ^\\mu',
			sqrt(
				-phi_K^-2 * (u' _\\mu' * u' ^\\mu' + 1)
			)
		)
	)
)
printbr(u5_for_A5_def)
-- TODO I'm redefining this because :simplifyAddMulDiv()ing sqrts seems to make ^(1/2)'s pop up everywhere
local u5_for_A5_when_u4norm_is_unit = u'^5':eq( -frac(1,A'_5') * A' _\\mu' * u' ^\\mu' )
printbr([[Notice that if we assume $u_\mu u^\mu = -1$ then this simplifies to]], u5_for_A5_when_u4norm_is_unit)
printbr([[However since]], origUnitVelEqn, [[, it might instead be that $u_\mu u^\mu \approx -1$]])
printbr()

printbr'If we substitute our definition for $u^5$ then the solution of the quadratic looks like:'
u5_for_A5_def = u5_for_A5_def:subst(u5U_def)
printbr(u5_for_A5_def)
u5_for_A5_def = (u5_for_A5_def * 4 * sqrt(frac(G, k_e))):simplifyAddMulDiv():replace(A' _\\mu'^2 * u' ^\\mu'^2, (A' _\\mu' * u' ^\\mu')^2)
printbr(u5_for_A5_def)
printbr()

--[[
is E ~ u?
but ...
J = rho/k u ... by charge conservation and charge current conservation?
using: J = sigma E
so u = sigma k / rho E
so u ~ E
in that case, E ~ rho/k u


J = -eps0/mu0 d/dt E ... by Maxwell / Ampere's law, with the approx that curl B = 0
--]]
printbr[[Now if $J^\mu = \sigma E^\mu$, and $c \frac{q}{M} \rho u^\mu = J^\mu$, then $u^\mu = \frac{\sigma M}{c \rho q} E^\mu$.]]
printbr[[And $E_\mu = (A_{\nu,\mu} - A_{\mu,\nu}) n^\nu$.]]
printbr[[In Minkowski metric, $E_\mu = A_{0,\mu} - A_{\mu,0}$, so for $|A_{0,i}| << |A_{i,0}|$ we see that $E_i \approx -\dot{A}_i$.]]
printbr[[So if $\dot{A}_\mu \approx -E_\mu \approx k u_\mu$ and $\dot{x}_\mu = u_\mu$ then $A_\mu \approx x_\mu$.]]
printbr[[Also, since $u_\mu u^\mu \approx -1$, we know motion in relativity is constrained by $u_\mu x^\mu = 0$.]]
printbr[[Therefore $A_\mu u^\mu \approx 0$.]]
printbr('So what does it look like if we invoke the gauge that', (A' _\\mu' * u' ^\\mu'):eq(0), '?')
local tmp = u5_for_A5_def:replaceIndex(A' _\\mu' * u' ^\\mu', 0):simplifyAddMulDiv()
printbr(tmp)
printbr[[Now without approximations:]]
printbr[[$J^\mu = \sigma_{\mu\nu} E^\nu$]]
printbr[[$c \frac{q}{M} \rho u^\mu = J^\mu$]]
printbr[[$u^\mu = \frac{M}{c \rho q} \sigma_{\mu\nu} E^\nu$]]
printbr[[$u^\mu = 2 \frac{M}{c \rho q} \sigma^{\mu\nu} A_{[\nu,\rho]} n^\rho$]]
printbr[[$x_\mu u^\mu = 0$ ... is it?]]
printbr[[Therefore $x_\mu \sigma^{\mu\nu} A_{[\nu,\rho]} n^\rho = 0$]]
printbr()

printbr('For another detour, what if we substitute', A5_def, ',', phi_K_def, '?')
local tmp = u5_for_A5_def:subst(A5_def, phi_K_def):simplifyAddMulDiv():replace(A' _\\mu'^2 * u' ^\\mu'^2, (A' _\\mu' * u' ^\\mu')^2)
printbr(tmp)
printbr()

printbr[[<hr>]]

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
printbr[[$u^5 = -\frac{1}{A_5} A_\mu u^\mu = $ {=={ -A_dot_u_over_A5L }==} $ - \frac{1}{c A_5} \gamma \phi''_q$]]
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
-\frac{1}{(A_5)^2} \delta A_5 ( -A_\mu u^\mu \pm {\phi_K}^{-1} \sqrt{
	-u_\mu u^\mu - 1
} ) + \frac{1}{A_5} (
	- \delta A_\mu u^\mu - A_\mu \delta u^\mu 
	\pm \frac{
		{\phi_K}^{-3} \delta \phi_K (u_\mu u^\mu + 1)
		- {\phi_K}^{-2} u_\mu \delta u^\mu
	}{
		{\phi_K}^{-1} \sqrt{
			-(u_\mu u^\mu + 1)
		}
	}
)
$<br>

...and as for $\delta u^5$ wrt $\delta (u_\mu u^\mu)$ in specific...<br>
$ \frac{\delta u^5}{\delta (u_\mu u^\mu)} = 
\mp \frac{
	1
}{2 A_5 {\phi_K}^2 \sqrt{
	-{\phi_K}^{-2} (u_\mu u^\mu + 1)
}}
$<br>
...and if $A_5 = 2 (\phi_K)^{-1}$...<br>
$ \frac{\delta u^5}{\delta (u_\mu u^\mu)} = 
\mp \frac{
	1
}{4 \sqrt{
	- u_\mu u^\mu + 1
}}
$<br>

<br>
<br>
]]
