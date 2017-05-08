#! /usr/bin/env luajit
require 'ext'
local symmath = require 'symmath'
local MathJax = require 'symmath.tostring.MathJax'
symmath.tostring = MathJax
print(MathJax.header)
local printbr = MathJax.print
MathJax.usePartialLHSForDerivative = true

for k,v in pairs(symmath) do
	if k ~= 'tostring' then _G[k] = v end
end
--[[
are Ricci tensors really coordinate transform invariant?
for R_ab
and e^a_A
is R_AB = R_ab e^a_A e^b_B equal to R_AB = R^C_ACB = (R^c_adb) e^a_A e^b_B lambda_c^C e^d_C
same for transforming connections
...and then the same for G_ab and T_ab composition from F_ab by transformed E's and B's vs transformed A's
--]]
local frac = op.div

local R = var'R'
local T = var'T'
local F = var'F'
local A = var'A'
local e = var'e'
local g = var'g'
local delta = var'\\delta'
local pi = var'\\pi'

printbr('Let coordinate transforms be represented by', e'^a_A', ',', e'_a^A')
printbr('Let', (e'_a^A' * e'^a_B'):eq(delta'^A_B'))
local e_eInv_ab_def = (e'_a^A' * e'^b_A'):eq(delta'^a_b')
printbr('Let', e_eInv_ab_def)
printbr()

printbr('Let', R'_ab', 'be the Ricci curvature')
printbr('Let', R'^a_bcd', 'be the Riemann curvature')
local Ricci_def = R'_ab':eq(R'^c_acb')
printbr('Let', Ricci_def)

printbr'coordinate transforms:'
local Ricci_xform_def = R'_AB':eq(R'_ab' * e'^a_A' * e'^b_B')
printbr(Ricci_xform_def)
local Riemann_xform_def = R'^A_BCD':eq(R'^a_bcd' * e'_a^A' * e'^b_B' * e'^c_C' * e'^d_D')
printbr(Riemann_xform_def)
printbr()

printbr('is transformed Ricci equal to Ricci from transformed Riemann?')
printbr('is', R'^C_ACB':eq(R'_AB'),'?')

local soln
soln = R'^C_ACB'
printbr(soln)
-- TODO instead of reindex, soln:subst(Riemann_xform_def:rhs())
soln = soln:subst(Riemann_xform_def:reindex{CACB='ABCD'})
printbr('=', soln, 'using', Riemann_xform_def)
-- TODO cancel transforms and inverse transformes
soln = (soln / e'_a^C' / e'^c_C')():reindex{cab='abd'}
printbr('=', soln, 'using', e_eInv_ab_def)
-- TODO automatically reindex
soln = soln:subst( Ricci_def:switch() )
printbr('=', soln, 'using', Ricci_def)
-- hmm, notice the extra () for simplification?  turns out mul(mul(a,b),c) is not equal to mul(a,b,c)
-- maybe I should just have a flatten() function to be called on adds and muls before comparing?
soln = soln:subst( Ricci_xform_def:switch()() )
printbr('=', soln, 'using', Ricci_xform_def:switch() )
printbr'yup'

printbr"same question for connections => Riemann, using the jet bundle transformation"
printbr"I'm betting it is yes"
printbr()

printbr('Let', F'_ab', 'be the Faraday tensor')
printbr('Let', T'_ab', 'be the stress-energy tensor')
local T_def = T'_ab':eq(frac(1,4 * pi) * (F'_ac' * F'_b^c' - frac(1,4) * g'_ab' * F'_cd' * F'^cd'))
printbr(T_def)

printbr'coordinate transforms:'
local T_xform_def = T'_AB':eq(T'_ab' * e'^a_A' * e'^b_B')
printbr(T_xform_def)
local F_xform_def = F'_AB':eq(F'_ab' * e'^a_A' * e'^b_B')
printbr(F_xform_def)
printbr()

printbr'is transformed stress-energy equal to stress-energy from transformed Faraday?'
printbr'stress-energy of transformed Faraday, in transformed coordinate system:'
printbr(T_def:rhs():reindex{ABCD='abcd'})
-- hmm, how about a transform index function?
printbr('=',frac(1,4*pi)*(F'_ac' * e'^a_A' * e'^c_C' * F'_b^d' * e'^b_B' * e'_d^C' - frac(1,4) * g'_ab' * e'^a_A' * e'^b_B' * F'_cd' * e'^c_C' * e'^d_D' * F'^ef' * e'_e^C' * e'_f^D'))
printbr('=',frac(1,4*pi)*(e'^a_A' * e'^b_B' * F'_ac' * F'_b^c' - frac(1,4) * g'_ab' * e'^a_A' * e'^b_B' * F'_cd' * F'^cd'))
printbr('=',e'^a_A' * e'^b_B' * frac(1,4*pi)*(F'_ac' * F'_b^c' - frac(1,4) * g'_ab' * F'_cd' * F'^cd'))
printbr('=',e'^a_A' * e'^b_B' * T'_ab')
printbr('=',T'_AB')
printbr'yup'
printbr()

printbr'is the Faraday of the transformed potential equal to the transformed Faraday?'
printbr"Well, since the Faraday is defined as the potential's exterior derivative, this can only be true if the transform itself has no/symmetric derivatives, right?"
printbr(A'_B,A' - A'_A,B')
printbr((A'_B')'_,A' - (A'_A')'_,B')
printbr((A'_b' * e'^b_B')'_,A' - (A'_a' * e'^a_A')'_,B')
printbr(A'_b,A' * e'^b_B' + A'_b' * e'^b_B,A' - A'_a,B' * e'^a_A' - A'_a' * e'^a_A,B')
printbr(A'_b,a' * e'^a_A' * e'^b_B' - A'_a,b' * e'^b_B' * e'^a_A' + A'_c' * e'^c_B,A' - A'_c' * e'^c_A,B')
printbr((A'_b,a' - A'_a,b') * e'^a_A' * e'^b_B' + A'_c' * (e'^c_B,A' - e'^c_A,B'))
printbr(F'_ab' * e'^a_A' * e'^b_B' + A'_c' * (e'^c_B,A' - e'^c_A,B'))
printbr(F'_AB' + A'_c' * (e'^c_B,A' - e'^c_A,B'))
printbr('and if',e'^c_A','is a coordinate transform then its partial derivative will be symmetric, and it will cancel')
printbr(F'_AB')
printbr'yup'
