#!/usr/bin/env luajit
require 'ext'
require 'symmath'.setup{implicitVars=true, MathJax={title='hydrodynamics', usePartialLHSForDerivative=true}}

function section(name)
	print('<h2>'..name..'</h2>')
end

function subsection(name)
	print('<h3>'..name..'</h3>')
end

-- markup syntax
function markup(str)
	str = str:gsub('%$([^%$]*)%$', function(code)
		print(code)
		return tostring(assert(load(code))())
	end)
	print(str)
end

-- TODO environments
dOmega = var'\\partial\\Omega'

section'Hydrodynamics'
subsection'Mass'

printbr'Total mass in volume:'
printbr(m:eq(Integral(rho, x'_i', Omega)))
--[[
$m$ = mass
$rho$ = density
$Omega$ = domain


'Rate-of-change of mass:',
m:diff(t):eq(Integral(rho:diff(t), x'_i', Omega)),
'',
'Rate-of-change considering boundary:',
m:diff(t):eq(Integral(rho*v'_j', S'_j', dOmega)),
'',
"Apply Green's theorem to rate-of-change of boundary:",
m:diff(t):eq(-Integral((rho*v'_j'):diff(x'_j'), x'_i', Omega))
'',
"Consider rate-of-change at any point:",
-- can't have diff an indexed expression at the moment ...
( rho:diff(t) + (rho * v'_j'):diff(x'_j') ):eq( 0 )
]]
