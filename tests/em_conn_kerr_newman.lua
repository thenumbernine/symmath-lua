#! /usr/bin/env luajit

-- kerr-newman metric applied to a single electron
-- look at the C^j_tt connection
-- what sort of gravitational force is it giving off?

require 'ext'
require 'symmath'.setup{implicitVars=true, simplifyConstantPowers=true}
require 'symmath.tostring.MathJax'.setup{usePartialLHSForDerivative=true}

local units = require 'symmath.natural_units'{
	--valuesAsVars=true,
}
local pi, c, G, epsilon_0 = units.pi, units.c, units.G, units.epsilon_0
local e = units.e
local m_e = units.m_e

Tensor.coords{
	{variables={t,r,theta,phi}},
}

local a_def = a:eq(J / (M * c))
printbr(a_def)

local rho_def = rho:eq(sqrt(r^2 + a^2 * cos(theta)^2))
printbr(rho_def)

local Delta_def = Delta:eq(r^2 + a^2 + r_Q^2 - 2 * r_s * r)
printbr(Delta_def)

local r_s_def = r_s:eq(2 * G * M / c^2)
printbr(r_s_def)

local r_Q_def = r_Q:eq((Q^2 * G) / (4 * pi * epsilon_0 * c^4))
printbr(r_Q_def) 

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
local accel = (-Conn'^i_tt')()
printbr'gravitational acceleration:'
accel:print'accel'
printbr()

printbr'...at azimuthal plane...'
local azimuth_defs = table{cos(theta):eq(0), sin(theta):eq(1)}
accel = accel:subst(azimuth_defs:unpack())()
printbr(azimuth_defs:map(tostring):concat';')
accel:print'accel'
printbr()

accel = accel:subst(Delta_def, rho_def, a_def, r_Q_def, r_s_def, azimuth_defs:unpack())()
printbr'...substitute variable definitions...'
accel:print'accel'
printbr()

accel = accel
			:subst(units.G_eq_1, units.c_eq_1)()
			:replace(pi, math.pi)
			:subst(r_Q_def)
			:replace(Q, units.e_in_m:rhs())
			:replace(M, units.m_e_in_m:rhs())
			:replace(J, units.hBar_in_m:rhs()/2)
			:simplify()
printbr'...substitute electron definitions...'
printbr(r_Q_def)
printbr(Q:eq(units.e_in_m:rhs()))
printbr(M:eq(units.m_e_in_m:rhs()))
printbr(J:eq(units.hBar_in_m:rhs()/2))
accel:print'accel'
printbr()

printbr'...at distance of the classical electron radius...'
local r_e = (units.e_in_m:rhs()^2 / units.m_e_in_m:rhs())()
accel = accel:replace(r, r_e)()
accel:print'accel'
printbr"Looks like there's a factor of m^2 that I've accidentally added..."
printbr()

printbr'electric field around a uniformly charged sphere:'
local E_sphere_def = E:eq(Q / (4 * pi * epsilon_0 * r^2))
printbr(E_sphere_def)
printbr'...for an electron...'
E_sphere_def = E_sphere_def
	:replace(Q, units.e_in_m:rhs())
	:subst(units.epsilon_0_in_m)
	:replace(pi, math.pi)
	:simplify()
printbr(E_sphere_def)
printbr'...at a distnace of $m_e$...'
E_sphere_def = E_sphere_def:replace(r, r_e)()
printbr(E_sphere_def)
