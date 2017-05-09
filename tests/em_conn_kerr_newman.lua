#! /usr/bin/env luajit

-- kerr-newman metric applied to a single electron
-- look at the C^j_tt connection
-- what sort of gravitational force is it giving off?

require 'ext'
require 'symmath'.setup{implicitVars=true, simplifyConstantPowers=true}
require 'symmath.tostring.MathJax'.setup{usePartialLHSForDerivative=true}

local t,r,theta,phi = vars('t','r','\\theta','\\phi')

Tensor.coords{
	{variables={t,r,theta,phi}},
}

local a_def = a:eq(J / M)
printbr(a_def)

local rho_def = rho:eq(sqrt(r^2 + a^2 * cos(theta)^2))
printbr(rho_def)

local Delta_def = Delta:eq(r^2 + a^2 + Q^2 - 2 * M * r)
printbr(Delta_def)

-- invert then substitute, to avoid polynomial division
local g = Tensor'_ab'
g[1][1] = g_11
g[1][4] = g_14
g[4][1] = g_14
g[2][2] = g_22
g[3][3] = g_33
g[4][4] = g_44

local basis = Tensor.metric(g)
local gU = basis.metricInverse

for _,name in ipairs{'g', 'gU'} do
	local t = ({g=g, gU=gU})[name]
	t = t:replace(g_11, -(Delta - a^2 * sin(theta)^2) / rho^2)
		:replace(g_14, (Delta - (r^2 + a^2)) * a * sin(theta)^2 / rho^2)
		:replace(g_22, rho^2 / Delta)
		:replace(g_33, rho^2)
		:replace(g_44, ((r^2 + a^2)^2 - a^2 * Delta * sin(theta)^2) * sin(theta)^2 / rho^2)
		:simplify()
	if name=='g' then 
		g=t
	elseif name=='gU' then
		gU=t
	else
		error'here'
	end
end

Tensor.metric(g, gU)
g:print'g'
printbr()
gU:print'g'
printbr()

local Conn = Tensor'_abc'
Conn['_abc'] = (frac(1,2) * (g'_ab,c' + g'_ac,b' - g'_bc,a'))()
Conn = Conn'^a_bc'()
local accel = Conn'^i_tt'()
printbr'gravitational acceleration:'
accel:print'accel'
printbr()

accel = accel:subst(Delta_def, rho_def, a_def)()
printbr'...substitute variable definitions...'
accel:print'accel'
printbr()

local units = require 'symmath.natural_units'()
accel = accel:replace(Q, units.e_in_m:rhs())
			:replace(M, units.me_in_m:rhs())
			:simplify()
printbr'...substitute electron definitions...'
accel:print'accel'
printbr()
