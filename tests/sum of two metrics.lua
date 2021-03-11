#!/usr/bin/env luajit
local env = setmetatable({}, {__index=_G})
require 'ext.env'(env)
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath'.setup{env=env}
local MathJax = symmath.export.MathJax
symmath.tostring = MathJax 
local printbr = MathJax.print
MathJax.header.title = 'sum of two metrics'
print(MathJax.header)

local timer = os.clock
local startTime = timer()
local lastTime = startTime
local function printHeader(str)
	local thisTime = timer()
	io.stderr:write(' ... '..(thisTime-lastTime)..'s\n')
	lastTime = thisTime
	if str then 
		io.stderr:write(str) 
		printbr(str)
	end
	io.stderr:flush()
end

local delta = var'\\delta'
local eta = var'\\eta'

local g = var'g'
local g1 = var'\\hat{g}'
local g2 = var'\\tilde{g}'

local Gamma = var'\\Gamma'
local Gamma1 = var'\\hat{\\Gamma}'
local Gamma2 = var'\\tilde{\\Gamma}'

local R = var'R'
local R1 = var'\\hat{R}'
local R2 = var'\\tilde{R}'


printbr[[
This is supposed to generalize perturbative metric math.
Typical perturbative metric math is done using $g_{ab} = \eta_{ab} + h_{ab}$, where $\eta_{ab}$ must be $\pm diag\{-1, 1, 1, 1\}$ so that its derivative will be zero (or else a lot of other terms pop up) and $h_{ab}$ must be small.
This is shit-tier because most the physicists who use this metric themselves only do math in non-Cartesian background metrics (like spherical, cylindrical, etc).
This is also shit-tier because the metric is quadratic in nature ($ds = \int \sqrt{ g_{uv} \frac{\partial x^u}{\partial \lambda} \frac{\partial x^v}{\partial \lambda}} d\lambda$) 
and represents the inner product of basis vectors ($g_{uv} = e_u \cdot e_v$), such that, if you perturb the basis then you find $|g'_{ab}| = |g_{ab}|(1 + 2 |{\epsilon_a}^u| + |{\epsilon_a}^u|^2)$), 
and this $h_{ab}$ is only accounting for the $|{\epsilon_a}^u|^2$ term.
If you use this model then you are essentially throwing away the linear error term and only looking exclusively at quadratic error.<br>
<br>

With that disclaimer aside, I was asked once to extend gravitoelectrmagnetics to non-Cartesian backgrounds.  GEM relies on perturbative metrics and de-Donder gauge.  So let's see what a perturbed metric would look like with a non-Cartesian background metric.<br>
<br>

]]
printbr()



printbr(g1'_ab', '= first metric')
printbr(g2'_ab', '= second metric')
printbr()


printHeader'metric'
local g_def = g'_ab':eq(g1'_ab' + g2'_ab')
printbr(g_def)
printbr()


-- https://math.stackexchange.com/questions/17776/inverse-of-the-sum-of-matrices
printHeader'metric inverse'
local tr_g12 = var'g_{12}'
local tr_g12_def = tr_g12:eq(g1'^uv' * g2'_uv')
printbr(tr_g12_def)
local gU_def = g'^ab':eq(g1'^ab' - g1'^ac' * g2'_cd' * g1'^db' / (1 + tr_g12))
printbr(gU_def)
printbr()



printHeader'useful identity:'
printbr(delta'_i^j', [[= 1 for i=j, 0 otherwise]])
printbr(delta'_i^j_,k':eq(0))
local dg_uu_from_g_uu_parkial_g_lll = (g'_li' * g'^ij')'_,k':eq(0)
printbr(dg_uu_from_g_uu_parkial_g_lll)
dg_uu_from_g_uu_parkial_g_lll = dg_uu_from_g_uu_parkial_g_lll()
printbr(dg_uu_from_g_uu_parkial_g_lll)
dg_uu_from_g_uu_parkial_g_lll = (dg_uu_from_g_uu_parkial_g_lll * g'^lm')():factorDivision()
printbr(dg_uu_from_g_uu_parkial_g_lll)
dg_uu_from_g_uu_parkial_g_lll = dg_uu_from_g_uu_parkial_g_lll:simplifyMetrics()
	:reindex{im='mi'}
	:solve(g'^ij_,k')
printbr(dg_uu_from_g_uu_parkial_g_lll)
-- not the prettiest way to show that ...
printbr()




printHeader'connection'
local connL_from_dg_def = Gamma'_abc':eq(frac(1,2) * (g'_ab,c' + g'_ac,b' - g'_bc,a'))
printbr(connL_from_dg_def)
printbr()

local conn1L_def = connL_from_dg_def:replace(g, g1):replace(Gamma, Gamma1)
printbr(conn1L_def)
printbr()

local conn2L_def = connL_from_dg_def:replace(g, g2):replace(Gamma, Gamma2)
printbr(conn2L_def)
printbr()

local connL_from_dg1_dg2_def = connL_from_dg_def:splitOffDerivIndexes():substIndex(g_def)
printbr(connL_from_dg1_dg2_def)

connL_from_dg1_dg2_def = connL_from_dg1_dg2_def()
printbr(connL_from_dg1_dg2_def)

-- there are other ways to simplify this, such as solving Gamma_ijk for g_ij,k and substituting here
local connL_from_conn1L_conn2L_def = connL_from_dg1_dg2_def:clone()
connL_from_conn1L_conn2L_def[2] = connL_from_conn1L_conn2L_def[2]
	+ conn1L_def[1] - conn1L_def[2]
	+ conn2L_def[1] - conn2L_def[2]
connL_from_conn1L_conn2L_def = connL_from_conn1L_conn2L_def()
printbr(connL_from_conn1L_conn2L_def)
printbr()


local connU_def = Gamma'^a_bc':eq(g'^ad' * Gamma'_dbc')
printbr(connU_def)

local connU_from_conn1U_conn2U = connU_def:substIndex(connL_from_conn1L_conn2L_def)
printbr(connU_from_conn1U_conn2U)

local connU_from_gU_dg1L_dg2L_def = connU_from_conn1U_conn2U:substIndex(conn1L_def, conn2L_def)()
printbr(connU_from_gU_dg1L_dg2L_def)
printbr()


printHeader'connection partial'

local dconnL_from_dconn1L_dconn2L_def = connL_from_conn1L_conn2L_def',d'
printbr(dconnL_from_dconn1L_dconn2L_def)
dconnL_from_dconn1L_dconn2L_def = dconnL_from_dconn1L_dconn2L_def()
printbr(dconnL_from_dconn1L_dconn2L_def)
printbr()


local dconnL_from_dg_def = connL_from_dg_def',d'
printbr(dconnL_from_dg_def)
dconnL_from_dg_def = dconnL_from_dg_def()
printbr(dconnL_from_dg_def)
printbr()


local dconnU_def = connU_def:reindex{d='e'}',d'
printbr(dconnU_def)

dconnU_def = dconnU_def()
printbr(dconnU_def)

dconnU_def = dconnU_def:substIndex(dg_uu_from_g_uu_parkial_g_lll)()
printbr(dconnU_def)
printbr()

local dconnU_from_dconn1_dconn2_def = dconnU_def:splitOffDerivIndexes():substIndex(connL_from_conn1L_conn2L_def)()
printbr(dconnU_from_dconn1_dconn2_def)
dconnU_from_dconn1_dconn2_def = dconnU_from_dconn1_dconn2_def:splitOffDerivIndexes():substIndex(g_def)()
printbr(dconnU_from_dconn1_dconn2_def)
dconnU_from_dconn1_dconn2_def = dconnU_from_dconn1_dconn2_def:substIndex(conn1L_def, conn2L_def)()
printbr(dconnU_from_dconn1_dconn2_def)
printbr()


printHeader'Riemann curvature'

local Riemann_def = R'^a_bcd':eq(Gamma'^a_bd,c' - Gamma'^a_bc,d' + Gamma'^a_ec' * Gamma'^e_bd' - Gamma'^a_ed' * Gamma'^e_bc')
printbr(Riemann_def)

local Riemann_from_dconn_L_def = Riemann_def
	--:substIndex(dconnU_def)
	:subst(dconnU_def)
	:subst(dconnU_def:reindex{cd='dc'})
	:simplify()
printbr(Riemann_from_dconn_L_def)

-- TODO show Riemann in terms of g alone
local Riemann_from_g_def = Riemann_from_dconn_L_def 
	:splitOffDerivIndexes()
	
	-- if we substIndex two terms that both need sum variables then things go wrong ...
	--:substIndex(connU_def)
	-- so instead...
	:subst(connU_def:reindex{abcd='aecf'})
	:subst(connU_def:reindex{abcd='ebdh'})
	:subst(connU_def:reindex{abcd='aedf'})
	:subst(connU_def:reindex{abcd='ebch'})
	
	:substIndex(connL_from_dg_def)
	:simplify()
	:tidyIndexes()
	:symmetrizeIndexes(g, {1,2})
	:symmetrizeIndexes(g, {3,4})
	:simplifyAddMulDiv()
	--:simplify()

printbr(Riemann_from_g_def)
printbr()

printbr('Riemann curvature if the ', (g'_ab,c')^2, 'terms vanish:')

local Riemann_linear_def = Riemann_from_g_def:map(function(x)
	if symmath.op.mul:isa(x) then
		-- match to g'_ab,c'
		local numdgs = 0
		for i,xi in ipairs(x) do
			if TensorRef:isa(xi)
			and #xi == 4	-- { g  _a  _b  _,c }
			and xi[1] == g
			and not xi[2].derivative
			and not xi[3].derivative
			and xi[4].derivative
			then
				numdgs = numdgs + 1
				if numdgs >= 2 then return 0 end
			end
		end
	end
end)()
printbr(Riemann_linear_def)
printbr()

printbr'Riemann curvature of a sum of two metrics'

local Riemann_from_conn1_conn2_def = Riemann_from_dconn_L_def
	:splitOffDerivIndexes()
	:substIndex(connL_from_conn1L_conn2L_def)
	:simplify()
printbr(Riemann_from_conn1_conn2_def)

local Riemann_from_g1_g2_def = Riemann_from_conn1_conn2_def 
	--[[ TODO here, two 'h' sum indexes get introduced
	:substIndex(connU_from_conn1U_conn2U)
	--]]
	-- [[ instead, for the time being
	:subst(
		connU_from_conn1U_conn2U:reindex{abcd='aecf'},
		connU_from_conn1U_conn2U:reindex{abcd='ebdg'},
		connU_from_conn1U_conn2U:reindex{abcd='aedf'},
		connU_from_conn1U_conn2U:reindex{abcd='ebcg'}
	)
	--]]
	:simplify()

printbr(Riemann_from_g1_g2_def)

Riemann_from_g1_g2_def = Riemann_from_g1_g2_def
	:splitOffDerivIndexes()
	:substIndex(conn1L_def, conn2L_def, g_def)
	
	-- including both tidyIndexes before and after symmetrizeIndexes makes the time go from 4 to 27 seconds
	-- so which are necessary?
	-- with no tidyIndexes: 60 terms, 6.716136s
	-- with tidyIndexes before: 56 terms, 23.177396s
	-- with tidyIndexes after: 60 terms, 14.593795s
	-- with tidyIndexes before and after: 56 terms, 29.714078s
	:tidyIndexes()
	:symmetrizeIndexes(g, {1,2})
	:symmetrizeIndexes(g1, {1,2})
	:symmetrizeIndexes(g1, {3,4})
	:symmetrizeIndexes(g2, {1,2})
	:symmetrizeIndexes(g2, {3,4})
	--:tidyIndexes()
	:simplify()

printbr(Riemann_from_g1_g2_def)
printbr()


printbr('What if we assume', g'^ab':approx(g1'^ab'):approx(g2'^ab'))
printbr()

-- R^a_bcd only holds common terms with R1^a_bcd if their inverse metrics match
-- otherwise we are just adding more terms 
local Riemann1_from_g1_assuming_uppers_equal = Riemann_from_g_def:replace(g, g1):replace(R, R1)
	:replaceIndex(g1'^ab', g'^ab')
local Riemann2_from_g2_assuming_uppers_equal = Riemann_from_g_def:replace(g, g2):replace(R, R2)
	:replaceIndex(g2'^ab', g'^ab')

local Riemann_from_g1_g2_assumingUppersEqual = Riemann_from_g1_g2_def:clone()
Riemann_from_g1_g2_assumingUppersEqual[2] = Riemann_from_g1_g2_assumingUppersEqual[2]
	- Riemann1_from_g1_assuming_uppers_equal[2] + Riemann1_from_g1_assuming_uppers_equal[1]
	- Riemann2_from_g2_assuming_uppers_equal[2] + Riemann2_from_g2_assuming_uppers_equal[1]
Riemann_from_g1_g2_assumingUppersEqual = Riemann_from_g1_g2_assumingUppersEqual()
printbr(Riemann_from_g1_g2_assumingUppersEqual)
printbr()

--[=[ turns out all the (g1_ab,c)^2 terms are stored within R1_abcd
printbr('assuming', (g1'_ab,c'^2):eq(0))

local approx_Riemann_from_conn1_conn2_def = Riemann_from_g1_g2_assumingUppersEqual 
	--[[ not working
	:replaceIndex(g1'_ab,c' * g1'_de,f', 0)
	--]]
	-- breaks, needs to be fixed
	--:replaceIndex(g1' _$1 $2 ,$3' * g1' _$4 $5 ,$6', 0)
	-- [[ instead
	:replace(g1'_bc,g' * g1'_de,f', 0)
	:replace(g1'_bc,g' * g1'_df,e', 0)
	:replace(g1'_bc,g' * g1'_ef,d', 0)
	
	:replace(g1'_bd,g' * g1'_ce,f', 0)
	:replace(g1'_bd,g' * g1'_cf,e', 0)
	:replace(g1'_bd,g' * g1'_ef,c', 0)
	
	:replace(g1'_bg,c' * g1'_de,f', 0)
	:replace(g1'_bg,c' * g1'_df,e', 0)
	:replace(g1'_bg,c' * g1'_ef,d', 0)
	
	:replace(g1'_bg,d' * g1'_ce,f', 0)
	:replace(g1'_bg,d' * g1'_cf,e', 0)
	:replace(g1'_bg,d' * g1'_ef,c', 0)
	
	:replace(g1'_ce,f' * g1'_dg,b', 0)
	:replace(g1'_cf,e' * g1'_dg,b', 0)
	
	:replace(g1'_cg,b' * g1'_de,f', 0)
	:replace(g1'_cg,b' * g1'_df,e', 0)
	:replace(g1'_cg,b' * g1'_ef,d', 0)
	
	:replace(g1'_dg,b' * g1'_ef,c', 0)
	--]]
	:simplify()
printbr(approx_Riemann_from_conn1_conn2_def)
printbr()
--]=]

printbr('What if instead we assume', g'^ab':approx(g1'^ab'), ',', g2'_ab', '$ << 1$ s.t. ', ((g2'_ab,c')^2):approx(0), '?')

local Riemann_perturbed_def = Riemann_def:clone()
printbr(Riemann_perturbed_def)

Riemann_perturbed_def = Riemann_perturbed_def
	:splitOffDerivIndexes()
	:replace(Gamma'^a_bd', g'^ae' * Gamma'_ebd')
	:replace(Gamma'^a_bc', g'^ae' * Gamma'_ebc')
	
--[[ TODO FIXME causes duplicate sum terms...
substIndex(connU_from_conn1U_conn2U)
--]]
-- [[ instead:
	:replace(
		Gamma'^a_ec' * Gamma'^e_bd',
		g'^af' * Gamma'_fec' * g'^eh' * Gamma'_hbd'
	)
	:replace(
		Gamma'^a_ed' * Gamma'^e_bc',
		g'^af' * Gamma'_fed' * g'^eh' * Gamma'_hbc'
	)
--]]

	:simplifyAddMulDiv()
printbr(Riemann_perturbed_def)

printbr('using', g'^ab':approx(g1'^ab'))
Riemann_perturbed_def = Riemann_perturbed_def
	:splitOffDerivIndexes()
	:replaceIndex(g'^ab', g1'^ab')
	:simplifyAddMulDiv()
printbr(Riemann_perturbed_def)

printbr('using', connL_from_conn1L_conn2L_def)
Riemann_perturbed_def = Riemann_perturbed_def
	:splitOffDerivIndexes()
	:substIndex(connL_from_conn1L_conn2L_def)
	:simplifyAddMulDiv()
printbr(Riemann_perturbed_def)

printbr('recombining terms of', R1'^a_bcd')

Riemann_perturbed_def = Riemann_perturbed_def
	:replace(
		-1 * Gamma1'_ebc' * g1'^ae_,d' + -1 * g1'^ae' * Gamma1'_ebc,d',
		-Gamma1'^a_bc,d'
	)
	:replace(
		Gamma1'_ebd' * g1'^ae_,c' + g1'^ae' * Gamma1'_ebd,c',
		Gamma1'^a_bd,c'
	)
	

	:replace(
		g1'^af' * g1'^eh' * Gamma1'_fec' * Gamma1'_hbd',
		Gamma1'^a_ec' * Gamma1'^e_bd'
	)
	:replace(
		g1'^af' * g1'^eh' * Gamma1'_fed' * Gamma1'_hbc',
		Gamma1'^a_ed' * Gamma1'^e_bc'
	)

	:simplifyAddMulDiv()
printbr(Riemann_perturbed_def)

Riemann_perturbed_def = Riemann_perturbed_def
	:subst(
		Riemann_def:switch()
			:replace(Gamma, Gamma1)
			:replace(R, R1)
			:simplifyAddMulDiv()
	)
	:simplifyAddMulDiv()
printbr(Riemann_perturbed_def)

printbr("Take note that I'm not touching", g2'^ab', "specifically because", g2'_ab', "<< 1 implies", g2'^ab', ">> 1.  Another detail I think everyone who ever did perturbative metric / weak field GR ignores.")
printbr('Next comes ', (g2'_ab,c'^2):eq(0), 'and', (g2'_ab,c' * Gamma2'_abc'):eq(0), [[.  I don't know why.  It's not like $|y|<<1$ ever implied $|\frac{\partial y}{\partial x}|<<1$ ever in the history of math.  But this is part of the weak-field process.  Surprisingly this only removes two terms.]])

local Riemann_perturbed_dh2_removed_def = Riemann_perturbed_def
	:replace(Gamma2'_fec' * Gamma2'_hbd', 0)
	:replace(Gamma2'_fed' * Gamma2'_hbc', 0)
	:simplifyAddMulDiv()
printbr(Riemann_perturbed_dh2_removed_def)

printbr("So since that just removes two terms, I'm not going to remove them from here on.  I'll let you do that yourself if you want.")
printbr("Now expand the ", Gamma2'_abc,d', "terms")

local Riemann_perturbed_with_d2g_def = Riemann_perturbed_def
	:substIndex(conn2L_def'_,d'())
	:tidyIndexes()
	:symmetrizeIndexes(g2, {3,4})
	:simplifyAddMulDiv()
printbr(Riemann_perturbed_with_d2g_def)


printbr([[Now from here most perturbative literature assumes the background metric uses constant components, i.e. ]], g1'_ab':eq(eta'_ab'), 'and', eta'_ab,c':eq(0), ', and that removes all the other terms except for the 4', g2'_ab,cd', [[ perturbation terms.]])
printbr([[Mind you, if you don't expand the perturbation connection to produce those 4 ]], g2'_ab,cd', "terms then instead you can recombine the partial to see it is the antisymmetric portion of ", (g1'^ae' * Gamma2'_ebc')'_,d')

Riemann_perturbed_def = Riemann_perturbed_def 
	:replace(
		g1'^ae_,c' * Gamma2'_ebd' + g1'^ae' * Gamma2'_ebd,c',
		(g1'^ae' * Gamma2'_ebd')'_,c'
	)
	:replace(
		-1 * g1'^ae_,d' * Gamma2'_ebc' + -1 * g1'^ae' * Gamma2'_ebc,d',
		(-g1'^ae' * Gamma2'_ebc')'_,d'
	)
printbr(Riemann_perturbed_def)

--[[
In terms of group actions / basis transformations

E = matrix whose column elements are coefficients of basis vectors

E = [e_1 | ... e_i ... | e_n], for e_i = i'th basis vector

g = E^T * E, s.t. g_ij = e_i^T e_j = e_i dot e_j

E' = transform perturbation from E, E' ~ I + h, h_ij << 1

E2 = E * E'

g2 = E'^T * E^T * E * E' = E'^T * g * E'

this could be written as a change-of-index <-> change-of-basis:

g2'_IJ' = g'_ab' * e'^a_I' * e'^b_J'

and honestly makes more sense to analyze instead of a "perturbed metric" g_ab = eta_ab + h_ab

just redo all the typical coordinate math, but in the perturbed coordinate, where 'e^a_I' is the perturbation ~ delta^a_I

of course thise brings us to 

g2'_IJ' = (delta'^a_I' + h'^a_I') * g'_ab' * (delta'^b_J' + h'^b_J')
g2'_IJ' = g'_ab' * (delta'^a_I' * delta'^b_J' + delta'^a_I' * h'^b_J' + h'^a_I' * delta'^b_J' + h'^a_I' * h'^b_J')
g2'_IJ' = g'_ab' * delta'^a_I' * delta'^b_J' + g'_ab' * delta'^a_I' * h'^b_J' + g'_ab' * h'^a_I' * delta'^b_J' + g'_ab' * h'^a_I' * h'^b_J'
let g_IJ indexes be implicit for g_ab delta^a_I delta^b_J (as oppposed to being implicit for g_ab e^b_I e^b_J)
g2'_IJ' = g'_IJ' + g'_Ib' * h'^b_J' + g'_aJ' * h'^a_I' + g'_ab' * h'^a_I' * h'^b_J'
g2'_IJ' = g'_IJ' + 2 g'_u(I' * h'^u_J)' + g'_ab' * h'^a_I' * h'^b_J'
Now if h^a_I = sqrt(h_IJ) then this shows that perturbative g2_IJ = g_IJ + h_IJ is missing that middle 2 g_u(I h^u_J) term.

--]]

-- DONE
printHeader()
io.stderr:write('TOTAL: '..(timer() - startTime)..'\n')
io.stderr:flush()
print(MathJax.footer)
