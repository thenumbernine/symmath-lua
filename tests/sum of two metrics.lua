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


-- TODO put an add-mul-div simplification inside Expression somewhere
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



local g = var'g'
local g1 = var'\\hat{g}'
local g2 = var'\\tilde{g}'

local Gamma = var'\\Gamma'
local Gamma1 = var'\\hat{\\Gamma}'
local Gamma2 = var'\\tilde{\\Gamma}'

local R = var'R'
local R1 = var'\\hat{R}'
local R2 = var'\\tilde{R}'


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
	:simplify()

printbr(Riemann_from_g_def)
printbr()

local Riemann_from_conn1_conn2_def = Riemann_from_dconn_L_def
	:splitOffDerivIndexes()
	:substIndex(connL_from_conn1L_conn2L_def)
	:simplify()
printbr(Riemann_from_conn1_conn2_def)

Riemann_from_conn1_conn2_def = Riemann_from_conn1_conn2_def 
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

printbr(Riemann_from_conn1_conn2_def)

Riemann_from_conn1_conn2_def = Riemann_from_conn1_conn2_def
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

printbr(Riemann_from_conn1_conn2_def)
printbr()


printbr('assuming', g'^ab', '$\\approx$', g1'^ab', '$\\approx$', g2'^ab')
printbr()

-- R^a_bcd only holds common terms with R1^a_bcd if their inverse metrics match
-- otherwise we are just adding more terms 
local Riemann1_from_g1_def = Riemann_from_g_def:replace(g, g1):replace(R, R1)
	:replaceIndex(g1'^ab', g'^ab')
local Riemann2_from_g2_def = Riemann_from_g_def:replace(g, g2):replace(R, R2)
	:replaceIndex(g2'^ab', g'^ab')

local Riemann_from_Riemann1_Riemann2_def = Riemann_from_conn1_conn2_def:clone()
Riemann_from_Riemann1_Riemann2_def[2] = Riemann_from_Riemann1_Riemann2_def[2]
	- Riemann1_from_g1_def[2] + Riemann1_from_g1_def[1]
	- Riemann2_from_g2_def[2] + Riemann2_from_g2_def[1]
Riemann_from_Riemann1_Riemann2_def = Riemann_from_Riemann1_Riemann2_def()
printbr(Riemann_from_Riemann1_Riemann2_def)
printbr()

--[=[ turns out all the (g1_ab,c)^2 terms are stored within R1_abcd
printbr('assuming', (g1'_ab,c'^2):eq(0))

local approx_Riemann_from_conn1_conn2_def = Riemann_from_Riemann1_Riemann2_def 
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

-- DONE
printHeader()
io.stderr:write('TOTAL: '..(timer() - startTime)..'\n')
io.stderr:flush()
print(MathJax.footer)
