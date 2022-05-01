#!/usr/bin/env luajit
local env = setmetatable({}, {__index=_G})
require 'ext.env'(env)
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath'.setup{env=env}
local MathJax = symmath.export.MathJax
symmath.tostring = MathJax 
local printbr = MathJax.print
MathJax.header.title = 'ADM formalism'
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

local g = Tensor:metricSymbol()
local n = var'n'
local v = var'v'
local K = var'K'
local G = var'G'
local R = var'R'
local T = var'T'
local delta = Tensor:deltaSymbol()
local gamma = var'\\gamma'
local rho = var'\\rho'
local RPerp = var[[(R^\perp)]]


-- [[ allow simplifyMetrics to operate on gamma for raising and lowering spatial vectors/forms
-- TODO but you can't just say "gamma is a metric" in that gamma_ac gamma^cb = delta_a^b
-- instead it's only equal to gamma_a^b
-- (while technically, g_a^b == delta_a^b, so I should be using 'g' for 'delta', but that's not convention)
-- one way around that for now: don't let gamma simplify against gamma?
local perpVars = table{
	RPerp,
	K,
	--gamma,	-- TODO change this to not create delta's.  until then, don't use this.  instead use gamma_lu_sq_def
	--v?
}

local simplifyMetricPerpRule = {
	isMetric = function(g)
		return g[1] == gamma
	end,
	canSimplify = function(g, t, gi, ti)
		return perpVars:find(t[1])
		and t[ti].lower ~= g[gi].lower
		and not t:hasDerivIndex()	-- only so long as deriv is not a comma
	end,
}

local function simplifyPerpMetrics(expr)
	return expr:simplifyMetrics{
		simplifyMetricPerpRule,
		Tensor.simplifyMetricMulRules.delta,
	}
end
--]]


printbr()
printHeader'properties of hypersurface normal:'
local n_norm_def = (n'^a' * n'_a'):eq(-1)
printbr(n_norm_def, '= unit hypersurface normal')
local nabla_normLen_def = n_norm_def'_;b'()
printbr(nabla_normLen_def)
-- hmm, here is tidying lowers/uppers of indexes, taking account covariant derivative can factor out metrics
local n_u_dot_nabla_n_ll_def = nabla_normLen_def() 
n_u_dot_nabla_n_ll_def[1] = ((n_u_dot_nabla_n_ll_def[1] - n'_a' * n'^a_;b' + n'^a' * n'_a;b') / 2)()
printbr(n_u_dot_nabla_n_ll_def)
local n_l_dot_nabla_n_ul_def = nabla_normLen_def() 
n_l_dot_nabla_n_ul_def[1] = ((n_l_dot_nabla_n_ul_def[1] - n'^a' * n'_a;b' + n'_a' * n'^a_;b') / 2)()
printbr(n_l_dot_nabla_n_ul_def)


printbr()
printHeader'matter hypersurface normal definition:'
local rho_def = rho:eq(n'^a' * n'^b' * T'_ab')
printbr(rho_def, '= density')


printbr()
printHeader'projection tensor:'
local gamma_ll_def = gamma'_ab':eq(g'_ab' + n'_a' * n'_b')
printbr(gamma_ll_def, '= projection operator')
local gamma_lu_def = (gamma_ll_def * g'^bc')():simplifyMetrics():reindex{c='b'}
printbr(gamma_lu_def)
local delta_lu_from_gamma_lu = gamma_lu_def:solve(delta'_a^b')
printbr(delta_lu_from_gamma_lu)
--[[ this is breaking at the moment ... in fact all of (a):eq(b + c * d * e):solve(d*e) (and :match ) is ... in fact all a:eq(c * d * e):solve(d * e) is
local nn_lu_from_delta_lu_gamma_lu = delta_lu_from_gamma_lu:solve(n'_a' * n'^b')()
--]]
-- [[ so until i fix it ...
local nlen = var'|n|'
local nlendef = nlen:eq(n'_a' * n'^b')
local nn_lu_from_delta_lu_gamma_lu = delta_lu_from_gamma_lu:subst(nlendef:switch()):solve(nlen):subst(nlendef)()
--]]
printbr(nn_lu_from_delta_lu_gamma_lu)

printbr()
local expr = gamma'_a^c' * gamma'_c^b'
local gamma_lu_sq_def = expr:eq(expr:substIndex(gamma_lu_def))
printbr(gamma_lu_sq_def)
gamma_lu_sq_def = gamma_lu_sq_def():simplifyMetrics()
--[[ not working
gamma_lu_sq_def = gamma_lu_sq_def:substIndex(n_norm_def)
--]]
-- [[ so instead
gamma_lu_sq_def = gamma_lu_sq_def:subst(n_norm_def:reindex{a='c'})()
--]]
printbr(gamma_lu_sq_def)
gamma_lu_sq_def = gamma_lu_sq_def:subst(delta_lu_from_gamma_lu)()
printbr(gamma_lu_sq_def)
printbr()

--[[
gamma_ac g^cd gamma_db
= (g_ac + n_a n_c) g^cd (g_db + n_d n_b)
= (delta_a^d + n_a n^d) (g_db + n_d n_b)
= g_ab + n_a n_b + n_a n_b + n_a n_b n^d n_d
= gamma_ab
--]]

local n_u_times_gamma_lu_def = (gamma_lu_def * n'^a')()
printbr(n_u_times_gamma_lu_def)
n_u_times_gamma_lu_def = n_u_times_gamma_lu_def:simplifyAddMulDiv():simplifyMetrics()
printbr(n_u_times_gamma_lu_def)
--[[ why doesn't substIndex work even when the indexes don't need to be swapped?
n_u_times_gamma_lu_def = n_u_times_gamma_lu_def:substIndex(n_norm_def)()
--]]
-- [[
n_u_times_gamma_lu_def = n_u_times_gamma_lu_def:subst(n_norm_def)()
--]]
n_u_times_gamma_lu_def = n_u_times_gamma_lu_def:reindex{ab='ba'}
printbr(n_u_times_gamma_lu_def)
printbr()

local gamma_lu_times_n_l_def = (gamma_lu_def * n'_b')()
printbr(gamma_lu_times_n_l_def)
gamma_lu_times_n_l_def = gamma_lu_times_n_l_def:simplifyAddMulDiv():simplifyMetrics()
printbr(gamma_lu_times_n_l_def)
--[[ hmm why doesn't substIndex work for sum-terms on the lhs?
gamma_lu_times_n_l_def = gamma_lu_times_n_l_def:substIndex(n_norm_def)()
--]]
-- [[ so until then, use the specific indexes ...
gamma_lu_times_n_l_def = gamma_lu_times_n_l_def:subst(n_norm_def:reindex{a='b'})()
--]]
printbr(gamma_lu_times_n_l_def)



printbr()
printHeader'properties of spatial vectors:'
local v_u_dot_n_l_def = (v'^a' * n'_a'):eq(0)
printbr(v_u_dot_n_l_def)
local tmp = v_u_dot_n_l_def'_;b'()
printbr(tmp)
local n_l_dot_nabla_v_ul_def = tmp:solve(n'_a' * v'^a_;b')
printbr(n_l_dot_nabla_v_ul_def)
printbr()

local v_l_dot_n_u_def = (v'_a' * n'^a'):eq(0)
printbr(v_l_dot_n_u_def)
local tmp = v_l_dot_n_u_def'_;b'()
local n_u_dot_nabla_v_ll_def = tmp:solve(n'^a' * v'_a;b')
printbr(n_u_dot_nabla_v_ll_def)
printbr()

local proj_v_from_v = (gamma'_b^a' * v'^b'):eq(v'^a')
printbr(proj_v_from_v)


printbr()
printHeader'extrinsic curvature'
local K_ll_def = K'_ab':eq(-gamma'_a^c' * gamma'_b^d' * n'_c;d')
printbr(K_ll_def)

local nabla_n_ll_from_K_ll = K_ll_def:clone()
printbr(nabla_n_ll_from_K_ll)
nabla_n_ll_from_K_ll = nabla_n_ll_from_K_ll:substIndex(gamma_lu_def)
printbr(nabla_n_ll_from_K_ll)
nabla_n_ll_from_K_ll = nabla_n_ll_from_K_ll:simplifyAddMulDiv():simplifyMetrics()
printbr(nabla_n_ll_from_K_ll)
-- substIndex not working
--nabla_n_ll_from_K_ll = nabla_n_ll_from_K_ll:substIndex(n_u_dot_nabla_n_ll_def)()
nabla_n_ll_from_K_ll = nabla_n_ll_from_K_ll:subst(
	n_u_dot_nabla_n_ll_def:reindex{a='c'},
	n_u_dot_nabla_n_ll_def:reindex{ab='cd'}
)()
printbr(nabla_n_ll_from_K_ll)
nabla_n_ll_from_K_ll = nabla_n_ll_from_K_ll:solve(n'_a;b')
printbr(nabla_n_ll_from_K_ll)
printbr()

local n_u_dot_K_ll_def = (n'^a' * K'_ab'):eq(0)
printbr(n_u_dot_K_ll_def, 'because $n \\cdot \\gamma = 0$ and $K = \\perp \\nabla n$')


printbr()
printHeader'projection of covariant derivative on a spatial vector'
-- TODO proj() function that looks at fixed indexes and multiplies/reindexes accordingly
local proj_nabla_v_ul_def = v'^a_|b':eq( gamma'_c^a' * gamma'_b^d' * v'^c_;d')
printbr(proj_nabla_v_ul_def)
printbr('using', gamma_lu_def:reindex{b='c'})
proj_nabla_v_ul_def = proj_nabla_v_ul_def:subst(gamma_lu_def:reindex{ab='ca'})	-- just the first gamma_a^c
printbr(proj_nabla_v_ul_def)
proj_nabla_v_ul_def = proj_nabla_v_ul_def:simplifyAddMulDiv():simplifyMetrics()
printbr(proj_nabla_v_ul_def)
proj_nabla_v_ul_def = proj_nabla_v_ul_def:subst(n_l_dot_nabla_v_ul_def:reindex{ab='cd'})()
printbr(proj_nabla_v_ul_def)
proj_nabla_v_ul_def = proj_nabla_v_ul_def:substIndex(nabla_n_ll_from_K_ll)()
printbr(proj_nabla_v_ul_def)
proj_nabla_v_ul_def = proj_nabla_v_ul_def:substIndex(gamma_lu_def)
printbr(proj_nabla_v_ul_def)
proj_nabla_v_ul_def = proj_nabla_v_ul_def():simplifyMetrics()
printbr(proj_nabla_v_ul_def)
proj_nabla_v_ul_def = proj_nabla_v_ul_def:subst(n_norm_def:reindex{a='d'})()
printbr(proj_nabla_v_ul_def)
local using = (n'^d' * K'_cd'):eq(0)
printbr('using', using)
proj_nabla_v_ul_def = proj_nabla_v_ul_def:subst(using)()
printbr(proj_nabla_v_ul_def)
proj_nabla_v_ul_def = proj_nabla_v_ul_def:subst(nn_lu_from_delta_lu_gamma_lu:reindex{ab='bd'})():simplifyMetrics()()
proj_nabla_v_ul_def = proj_nabla_v_ul_def:tidyIndexes()
printbr(proj_nabla_v_ul_def)


printbr()
printHeader'2nd projection covariant derivative of a spatial vector'
local proj2_nabla2_v_ull_def = v'^a_|bc':eq(v'^a_|b''_|c'):substIndex(proj_nabla_v_ul_def)
printbr(proj2_nabla2_v_ull_def)
proj2_nabla2_v_ull_def[2] = proj2_nabla2_v_ull_def[2]:replace(
	Tensor.Index{symbol='c', derivative='|', lower=true},
	Tensor.Index{symbol='c', derivative=';', lower=true}
):reindex{abc='gef'} * gamma'_g^a' * gamma'_b^e' * gamma'_c^f'
printbr(proj2_nabla2_v_ull_def)
proj2_nabla2_v_ull_def = proj2_nabla2_v_ull_def:simplifyAddMulDiv()
printbr(proj2_nabla2_v_ull_def)
-- proj2_nabla2_v_ull_def = proj2_nabla2_v_ull_def:substIndex(gamma_lu_sq_def)	-- not working
proj2_nabla2_v_ull_def = proj2_nabla2_v_ull_def:subst(gamma_lu_sq_def:reindex{acb='bed'})
printbr(proj2_nabla2_v_ull_def)
proj2_nabla2_v_ull_def = proj2_nabla2_v_ull_def
	:replace(K'_de' * gamma'_b^e', K'_db')	-- TODO prove this somewhere?
proj2_nabla2_v_ull_def = proj2_nabla2_v_ull_def:simplifyAddMulDiv()
printbr(proj2_nabla2_v_ull_def)
proj2_nabla2_v_ull_def = proj2_nabla2_v_ull_def
	:subst(n_u_times_gamma_lu_def:reindex{b='g'})
proj2_nabla2_v_ull_def = proj2_nabla2_v_ull_def:simplifyAddMulDiv()
printbr(proj2_nabla2_v_ull_def)
proj2_nabla2_v_ull_def = proj2_nabla2_v_ull_def
	:subst(gamma_lu_def:reindex{ab='ed'}'_;f'())
proj2_nabla2_v_ull_def = proj2_nabla2_v_ull_def
	:replaceIndex(delta'_a^b_;c', 0)
printbr(proj2_nabla2_v_ull_def)
proj2_nabla2_v_ull_def = proj2_nabla2_v_ull_def:simplifyAddMulDiv()
proj2_nabla2_v_ull_def = proj2_nabla2_v_ull_def:substIndex(gamma_lu_times_n_l_def:reindex{ab='be'})
proj2_nabla2_v_ull_def = proj2_nabla2_v_ull_def:simplifyAddMulDiv()
printbr(proj2_nabla2_v_ull_def)
proj2_nabla2_v_ull_def = proj2_nabla2_v_ull_def:replace(
	gamma'_g^a' * n'^g_;f',
	gamma'^ah' * gamma'_h^g' * n'_g;f'
)
proj2_nabla2_v_ull_def = proj2_nabla2_v_ull_def:simplifyAddMulDiv()
proj2_nabla2_v_ull_def = proj2_nabla2_v_ull_def:replace(
	gamma'_c^f' * gamma'_h^g' * n'_g;f',
	-K'_ch'
)
proj2_nabla2_v_ull_def = proj2_nabla2_v_ull_def:simplifyAddMulDiv()
proj2_nabla2_v_ull_def = proj2_nabla2_v_ull_def:replace(
	gamma'_b^e' * gamma'_c^f' * n'_e;f',
	-K'_bc'
)
proj2_nabla2_v_ull_def = proj2_nabla2_v_ull_def:simplifyAddMulDiv()
proj2_nabla2_v_ull_def = proj2_nabla2_v_ull_def:tidyIndexes()
printbr(proj2_nabla2_v_ull_def)


printbr()
printHeader'Riemann curvature of covariant derivative'
local R_ulll_v_u_def = (R'^a_bcd' * v'^b'):eq(v'^a_;dc' - v'^a_;cd')
printbr(R_ulll_v_u_def)


-- RPerp^a_bcd v^b = v^b_|dc - v^b_|cd
printbr()
printHeader'Riemann curvature of projection covariant derivative'
local RPerp_ulll_v_u_def = (RPerp'^a_bcd' * v'^b'):eq(v'^a_|dc' - v'^a_|cd')
printbr(RPerp_ulll_v_u_def)
-- not working ...
--RPerp_ulll_v_u_def = RPerp_ulll_v_u_def:substIndex(proj2_nabla2_v_ull_def)
RPerp_ulll_v_u_def = RPerp_ulll_v_u_def:subst(
	proj2_nabla2_v_ull_def:reindex{bcd='cdg'},
	proj2_nabla2_v_ull_def:reindex{bcd='dcg'}
)
printbr(RPerp_ulll_v_u_def)
RPerp_ulll_v_u_def = RPerp_ulll_v_u_def:simplifyAddMulDiv()
local using = R_ulll_v_u_def:solve(v'^a_;dc'):reindex{adc='fge'} * gamma'_f^a' * gamma'_c^g' * gamma'_d^e'
printbr('using', using)
RPerp_ulll_v_u_def = RPerp_ulll_v_u_def:subst(using)
printbr(RPerp_ulll_v_u_def)
RPerp_ulll_v_u_def = RPerp_ulll_v_u_def:tidyIndexes()
RPerp_ulll_v_u_def = RPerp_ulll_v_u_def:simplifyAddMulDiv()
printbr(RPerp_ulll_v_u_def)
RPerp_ulll_v_u_def = RPerp_ulll_v_u_def:symmetrizeIndexes(K, {1,2})
RPerp_ulll_v_u_def = RPerp_ulll_v_u_def:simplifyAddMulDiv()
printbr(RPerp_ulll_v_u_def)
RPerp_ulll_v_u_def = RPerp_ulll_v_u_def:reindex{b='h'}:replace(v'^h', gamma'_b^h')
RPerp_ulll_v_u_def = RPerp_ulll_v_u_def:simplifyAddMulDiv()
printbr(RPerp_ulll_v_u_def)
RPerp_ulll_v_u_def = simplifyPerpMetrics(RPerp_ulll_v_u_def)
printbr(RPerp_ulll_v_u_def)
RPerp_ulll_v_u_def = RPerp_ulll_v_u_def:reindex{a='k'} * gamma'_ak'
printbr(RPerp_ulll_v_u_def)
RPerp_ulll_v_u_def = simplifyPerpMetrics(RPerp_ulll_v_u_def)
RPerp_ulll_v_u_def = RPerp_ulll_v_u_def:replace(
	gamma'_ak' * gamma'_g^k' * R'^g_hfe',
	gamma'_a^g' * R'_ghfe'
)
RPerp_ulll_v_u_def = RPerp_ulll_v_u_def:symmetrizeIndexes(K, {1,2})
RPerp_ulll_v_u_def = RPerp_ulll_v_u_def:simplifyAddMulDiv():reindex{ghef='efgh'}
printbr(RPerp_ulll_v_u_def)
RPerp_ulll_v_u_def = RPerp_ulll_v_u_def:tidyIndexes()()
printbr(RPerp_ulll_v_u_def)
printbr("Gauss' equation")


printbr()
printHeader'Einstein Field Equations'
local EFE_def = G'_ab':eq(8 * pi * T'_ab')
printbr(EFE_def)
local using = G'_ab':eq(R'_ab' - frac(1,2) * R * g'_ab')
printbr('using', using)
EFE_def = EFE_def:substIndex(using)
printbr(EFE_def)


-- time-by-time
printbr()
printHeader'time-by-time'
local EFE_tt_def = (n'^a' * n'^b' * EFE_def)()
printbr(EFE_tt_def)
EFE_tt_def = EFE_tt_def:simplifyMetrics()
printbr(EFE_tt_def)
printbr('using', n_norm_def, ',', rho_def)
--[[	-- TOOD substIndex not working for matching sum indexes
EFE_tt_def = EFE_tt_def:substIndex(n_norm_def, rho_def:switch())
--]]
-- [[
EFE_tt_def = EFE_tt_def:subst(n_norm_def:reindex{a='b'}, rho_def:switch())
--]]
EFE_tt_def = EFE_tt_def:simplifyAddMulDiv()
printbr(EFE_tt_def)


-- time-by-space
printbr()
printHeader'time-by-space'
local EFE_ti_def = (n'^a' * gamma'_i^b' * EFE_def)()
printbr(EFE_ti_def)
EFE_ti_def = EFE_ti_def:substIndex(gamma_lu_def)
printbr(EFE_ti_def)
EFE_ti_def = EFE_ti_def:simplifyMetrics()()
printbr(EFE_ti_def)
--[[
EFE_ti_def = EFE_ti_def:substIndex(n_norm_def, rho_def:switch())()
--]]
-- [[
EFE_ti_def = EFE_ti_def:subst(n_norm_def:reindex{a='b'}, rho_def:switch())()
--]]
printbr(EFE_ti_def)


-- space-by-space
printbr()
printHeader'space-by-space'
local EFE_ij_def = (gamma'_i^a' * gamma'_j^b' * EFE_def)()
printbr(EFE_ij_def)
EFE_ij_def = EFE_ij_def:substIndex(gamma_lu_def)
printbr(EFE_ij_def)
EFE_ij_def = EFE_ij_def:simplifyMetrics()()
printbr(EFE_ij_def)
--[[
EFE_ij_def = EFE_ij_def:substIndex(n_norm_def, rho_def:switch())()
--]]
-- [[
EFE_ij_def = EFE_ij_def:subst(n_norm_def:reindex{a='b'}, rho_def:switch())()
--]]
printbr(EFE_ij_def)


-- DONE
printHeader()
io.stderr:write('TOTAL: '..(timer() - startTime)..'\n')
io.stderr:flush()
print(MathJax.footer)
