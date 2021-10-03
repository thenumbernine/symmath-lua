#!/usr/bin/env luajit
require 'ext'
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath'.setup{env=env, MathJax={title='Acoustic Black Hole', usePartialLHSForDerivative=true}}

local chart = Tensor.Chart{coords={'0', 'xyz'}}

local greekSymbols = require 'symmath.tensor.symbols'.greekSymbolNames
	-- :sort(function(a,b) return a < b end)
	:filter(function(s) return s:match'^[a-z]' end)		-- lowercase
	:mapi(function(s) return '\\'..s end)				-- append \ to the beginning for LaTeX

Tensor.defaultSymbols = table{'i','j','k','l','m','n'}


local alpha = var'\\alpha'
local beta = var'\\beta'
local gamma = var'\\gamma'
local delta = var'\\delta'
local conn3 = var'\\Gamma'
local conn4 = var'\\hat{\\Gamma}'
local g = var'g'
local n = var'n'
local K = var'K'
local c = var'c'
local v = var'v'


local gLL = Tensor('_ab', 
	{-alpha^2 + beta'^k' * beta'_k', beta'_j'},
	{beta'_i', gamma'_ij'}
)
printbr(g'_ab':eq(gLL), '= ADM metric')

local gUU = Tensor('^ab',
	{-1/alpha^2, beta'^j' / alpha^2},
	{beta'^i' / alpha^2, gamma'^ij' - beta'^i' * beta'^j' / alpha^2}
)
printbr(g'^ab':eq(gUU), '= ADM metric inverse')

local gLU = (
	gLL'_ac':reindex{j='k'}
	* gUU'^cb':reindex{i='k'}
)() 
:replaceIndex( beta'_i', beta'^j' * gamma'_ij' )():tidyIndexes()()
	:symmetrizeIndexes(gamma, {1,2})
	:replace(gamma'^jm' * gamma'_im', delta'_i^j')
	:replace(beta'^i' * delta'_i^j', beta'^j')()

printbr((g'_ac' * g'^cb'):eq(gLU))
printbr()


printbr[[wave equation of a scalar field (from my 'wave equation in spacetime' symmath worksheet)]]
local f = var'f'
local Phi = var'\\Phi'
local partial00_Phi_def = Phi'_,00':eq(
	-alpha^2 * Phi'_,0' * conn4'^0' 
	+ alpha^2 * Phi'_,ij' * gamma'^ij' 
	- alpha^2 * Phi'_,i' * conn4'^i'
	+ 2 * beta'^i' * Phi'_,0i'
	- beta'^i' * beta'^j' * Phi'_,ij'
	- f * alpha^2
)
printbr(partial00_Phi_def)
local conn4_0_U_def = conn4'^0':eq(-frac(1, alpha^3) * (alpha'_,0' - beta'^k' * alpha'_,k' + alpha^2 * K))
printbr(conn4_0_U_def)
local conn4_i_U_def = conn4'^i':eq(conn3'^i' + frac(1, alpha^3) * beta'^i' * (alpha'_,0' - beta'^k' * alpha'_,k' + alpha^2 * K) - frac(1, alpha^2) * (beta'^i_,0' - beta'^k' * beta'^i_,k' + alpha * alpha'_,j' * gamma'^ij'))
printbr(conn4_i_U_def)
partial00_Phi_def = partial00_Phi_def:subst(conn4_0_U_def, conn4_i_U_def )
partial00_Phi_def = partial00_Phi_def:simplifyAddMulDiv()
printbr(partial00_Phi_def)
printbr()


printbr'<hr>'


printbr[[2012 Visser acoustic black hole metric]]
local gUUab1 = Tensor('^ab', 
	{-1/c^2, -v'^j' / c^2},
	{-v'^i' / c^2, delta'^ij' - v'^i' * v'^j' / c^2}
)
printbr(g'^ab':eq(gUUab1))

local ab1_alpha_def = gUU[1][1]:eq(gUUab1[1][1])
printbr(ab1_alpha_def)
ab1_alpha_def = ab1_alpha_def:solve(alpha)
printbr(ab1_alpha_def)
printbr()

local ab1_betaU_def = gUU[2][1]:eq(gUUab1[2][1])
printbr(ab1_betaU_def)
ab1_betaU_def = ab1_betaU_def:subst(ab1_alpha_def):solve(beta'^i')
printbr(ab1_betaU_def)
printbr()

local ab1_gammaUU_def = gUU[2][2]:eq(gUUab1[2][2])
printbr(ab1_gammaUU_def)
ab1_gammaUU_def = ab1_gammaUU_def
	:subst(ab1_alpha_def)
	:substIndex(ab1_betaU_def)
	:solve(gamma'^ij')
printbr(ab1_gammaUU_def)
printbr()

-- TODO manually assuming ab1_gammaUU_def is gamma^ij = delta^ij ...
local ab1_gammaLL_def = gamma'_ij':eq(delta'_ij')
printbr(ab1_gammaLL_def)
printbr()

-- TODO manually assuming ab1_gammaUU_def is gamma^ij = delta^ij ...
printbr(beta'_i':eq(gamma'_ij' * beta'^j'):eq(ab1_betaU_def:rhs():reindex{i='j'} * ab1_gammaLL_def:rhs()))
printbr[[Using convention $v_i = \delta_{ij} v^j$]]
local ab1_betaL_def = beta'_i':eq(-v'_i')
printbr('So',ab1_betaL_def)
printbr()

local ab1_gLL = gLL
	:subst(ab1_alpha_def)
	:substIndex(ab1_betaU_def)
	:substIndex(ab1_betaL_def)
	:subst(ab1_gammaLL_def)
	()
printbr(g'_ab':eq(ab1_gLL))
printbr()

printbr[[$\gamma_{ij} = \delta_{ij}$, so $\Gamma_{ijk} = 0$ and ${\Gamma^i}_{jk} = 0$ and $\Gamma^i = 0$]]
local ab1_conn4ijkLLL_def = conn4'_ijk':eq(0)
printbr(ab1_conn4ijkLLL_def)
local ab1_conn3iU_def = conn3'^i':eq(0)
printbr(ab1_conn3iU_def)
printbr()

printbr'spacetime metric connection:'
local ab1_conn4tijLLL_def = conn4'_0ij':eq( frac(1,2) * (g'_0i,j' + g'_0j,i' - g'_ij,0'))
printbr(ab1_conn4tijLLL_def)
-- TODO manually replacing here ...
local ab1_conn4tijLLL_def = conn4'_0ij':eq( frac(1,2) * (ab1_gLL[2][1]'_,j' + ab1_gLL[1][2]'_,i' - ab1_gLL[2][2]'_,0'))
printbr(ab1_conn4tijLLL_def)
ab1_conn4tijLLL_def = ab1_conn4tijLLL_def():replaceIndex(delta'_ij,k', 0)
ab1_conn4tijLLL_def = ab1_conn4tijLLL_def:simplifyAddMulDiv()
printbr(ab1_conn4tijLLL_def)
printbr()

local ab1_conn40jkULL_def = conn4'^0_jk':eq(g'^00' * conn4'_0jk' + g'^0i' * conn4'_ijk')
printbr(ab1_conn40jkULL_def)
ab1_conn40jkULL_def = ab1_conn40jkULL_def
	:replace(g'^00', gUUab1[1][1])
	:replace(g'^0i', gUUab1[2][1])
	:subst(ab1_conn4tijLLL_def:reindex{ij='jk'})
	:subst(ab1_conn4ijkLLL_def)
	():replace(v'^i' * delta'_ik', v'_k')
	():replace(v'^i' * delta'_ij', v'_j')
ab1_conn40jkULL_def = ab1_conn40jkULL_def:simplifyAddMulDiv()
printbr(ab1_conn40jkULL_def)
printbr()

local ab1_KLL_def = K'_ij':eq(-alpha * conn4'^0_ij')
printbr(ab1_KLL_def)
ab1_KLL_def = ab1_KLL_def:subst(ab1_alpha_def,  ab1_conn40jkULL_def:reindex{jki='ijk'})
ab1_KLL_def = ab1_KLL_def:simplifyAddMulDiv()
printbr(ab1_KLL_def)
printbr()

local K_def = K:eq(gamma'^ij' * K'_ij')
printbr(K_def)
local ab1_K_def = K_def:subst(ab1_gammaUU_def, ab1_KLL_def)
ab1_K_def = ab1_K_def:simplifyAddMulDiv()
printbr(ab1_K_def)
ab1_K_def = ab1_K_def
	:replace(delta'^ij' * delta'_ij', n)
	:replace(delta'^ij' * v'_i,j', v'^k_,k')
	:replace(delta'^ij' * v'_j,i', v'^k_,k')
ab1_K_def = ab1_K_def()
printbr(ab1_K_def)
printbr()

printbr'wave equation:'
local ab1_partial00_Phi_def = partial00_Phi_def
	:splitOffDerivIndexes()
	:subst(ab1_alpha_def)
	:substIndex(ab1_betaU_def)
	:subst(ab1_K_def)
	:substIndex(ab1_conn3iU_def)
	:subst(ab1_gammaUU_def)
	:simplify()
	--:tidyIndexes()	-- tidyIndexes() doesnt like specific indexes, like _0
ab1_partial00_Phi_def = ab1_partial00_Phi_def:simplifyAddMulDiv()
printbr(ab1_partial00_Phi_def)
printbr()


printbr'<hr>'


local rho = var'\\rho'
printbr[[Ussembayev acoustic black hole metric]]
local gUUab2 = Tensor('^ab', 
	{-1/(rho * c), -v'^j' / (rho * c)},
	{-v'^i' / (rho * c), (c / rho) * delta'^ij' - v'^i' * v'^j' / (rho * c)}
)
printbr(g'^ab':eq(gUUab2))
printbr()

local ab2_alpha_def = gUU[1][1]:eq(gUUab2[1][1])
printbr(ab2_alpha_def)
ab2_alpha_def = ab2_alpha_def:solve(alpha)
printbr(ab2_alpha_def)
printbr()

local ab2_betaU_def = gUU[2][1]:eq(gUUab2[2][1])
printbr(ab2_betaU_def)
ab2_betaU_def = ab2_betaU_def:subst(ab2_alpha_def):solve(beta'^i')
printbr(ab2_betaU_def)
printbr()

local ab2_gammaUU_def = gUU[2][2]:eq(gUUab2[2][2])
printbr(ab2_gammaUU_def)
ab2_gammaUU_def = ab2_gammaUU_def
	:subst(ab2_alpha_def)
	:substIndex(ab2_betaU_def)
	:solve(gamma'^ij')
printbr(ab2_gammaUU_def)
printbr()

-- TODO manually assuming ab2_gammaUU_def is gamma^ij = (c/rho) delta^ij ...
local ab2_gammaLL_def = gamma'_ij':eq((rho / c) * delta'_ij')
printbr(ab2_gammaLL_def)
printbr()

-- TODO manually assuming ab2_gammaUU_def is gamma^ij = delta^ij ...
printbr(beta'_i':eq(gamma'_ij' * beta'^j'))
local ab2_betaL_def = beta'_i':eq(ab2_betaU_def:rhs():reindex{i='j'} * ab2_gammaLL_def:rhs())
printbr(ab2_betaL_def)
printbr[[Using convention $v_i = \delta_{ij} v^j$]]
--ab2_betaL_def = ab2_betaL_def:replace(v'^j' * delta'_ij', v'_j')
ab2_betaL_def = beta'_i':eq(-(rho / c) * v'_i')
printbr('So',ab2_betaL_def)
printbr()

local ab2_gLL = gLL
	:subst(ab2_alpha_def)
	:substIndex(ab2_betaU_def)
	:substIndex(ab2_betaL_def)
	:subst(ab2_gammaLL_def)
	()
printbr(g'_ab':eq(ab2_gLL))
printbr()

printbr'spatial metric connection:'
local conn3_def = conn3'_ijk':eq( frac(1,2) * (gamma'_ij,k' + gamma'_ik,j' - gamma'_jk,i'))
printbr(conn3_def)
local ab2_conn3_def = conn3_def
	:splitOffDerivIndexes()
	:substIndex(ab2_gammaLL_def)
printbr(ab2_conn3_def)
ab2_conn3_def = ab2_conn3_def():replaceIndex(delta'_ij,k', 0)
ab2_conn3_def = ab2_conn3_def:simplifyAddMulDiv()
printbr(ab2_conn3_def)
printbr()

printbr'spatial metric contracted on 2nd and 3rd indexes:'
local ab2_conn3_tr23_def = (ab2_conn3_def * gamma'^jk')()
ab2_conn3_tr23_def[2] = ab2_conn3_tr23_def[2]:substIndex(ab2_gammaUU_def)
ab2_conn3_tr23_def[2] = ab2_conn3_tr23_def[2]:simplifyAddMulDiv()	-- :simplifyAddMulDiv() distributes the deltas so they are next to one another so replace() can work
ab2_conn3_tr23_def[2] = ab2_conn3_tr23_def[2]:replace(delta'^jk' * delta'_jk', n)
ab2_conn3_tr23_def[2] = ab2_conn3_tr23_def[2]:replaceIndex(delta'^jk' * delta'_ik', delta'^j_i')
ab2_conn3_tr23_def[2] = ab2_conn3_tr23_def[2]:replaceIndex(delta'^jk' * delta'_ij', delta'^k_i')
ab2_conn3_tr23_def[2] = ab2_conn3_tr23_def[2]:replaceIndex(c'_,j' * delta'^j_i', c'_,i')
ab2_conn3_tr23_def[2] = ab2_conn3_tr23_def[2]:replaceIndex(c'_,k' * delta'^k_i', c'_,i')
ab2_conn3_tr23_def[2] = ab2_conn3_tr23_def[2]:replaceIndex(rho'_,j' * delta'^j_i', rho'_,i')
ab2_conn3_tr23_def[2] = ab2_conn3_tr23_def[2]:replaceIndex(rho'_,k' * delta'^k_i', rho'_,i')
ab2_conn3_tr23_def[2] = ab2_conn3_tr23_def[2]:simplifyAddMulDiv()
printbr(ab2_conn3_tr23_def)
--ab2_conn3_tr23_def = ab2_conn3_tr23_def:simplifyAddMulDiv()
--printbr(ab2_conn3_tr23_def)
printbr()

printbr'spacetime metric connection:'
local ab2_conn4tijLLL_def = conn4'_0ij':eq( frac(1,2) * (g'_0i,j' + g'_0j,i' - g'_ij,0'))
printbr(ab2_conn4tijLLL_def)
-- TODO manually replacing here ...
local ab2_conn4tijLLL_def = conn4'_0ij':eq( frac(1,2) * (ab2_gLL[2][1]'_,j' + ab2_gLL[1][2]'_,i' - ab2_gLL[2][2]'_,0'))
printbr(ab2_conn4tijLLL_def)
ab2_conn4tijLLL_def = ab2_conn4tijLLL_def():replaceIndex(delta'_ij,k', 0)
ab2_conn4tijLLL_def = ab2_conn4tijLLL_def:simplifyAddMulDiv()
printbr(ab2_conn4tijLLL_def)
printbr()

local ab2_conn4ijkLLL_def = conn4'_ijk':eq( frac(1,2) * (g'_ij,k' + g'_ik,j' - g'_jk,i' ))
printbr(ab2_conn4ijkLLL_def)
ab2_conn4ijkLLL_def = ab2_conn4ijkLLL_def:splitOffDerivIndexes():replaceIndex(g'_ij', ab2_gLL[2][2])
printbr(ab2_conn4ijkLLL_def)
ab2_conn4ijkLLL_def = ab2_conn4ijkLLL_def():replaceIndex(delta'_ij,k', 0)
ab2_conn4ijkLLL_def = ab2_conn4ijkLLL_def:simplifyAddMulDiv()
printbr(ab2_conn4ijkLLL_def)
printbr()

local ab2_conn40jkULL_def = conn4'^0_jk':eq(g'^00' * conn4'_0jk' + g'^0i' * conn4'_ijk')
printbr(ab2_conn40jkULL_def)
ab2_conn40jkULL_def = ab2_conn40jkULL_def
	:replace(g'^00', gUUab2[1][1])
	:replace(g'^0i', gUUab2[2][1])
	:subst(ab2_conn4tijLLL_def:reindex{ij='jk'})
	:subst(ab2_conn4ijkLLL_def)
	():replace(v'^i' * delta'_ik', v'_k')
	():replace(v'^i' * delta'_ij', v'_j')
ab2_conn40jkULL_def = ab2_conn40jkULL_def:simplifyAddMulDiv()
printbr(ab2_conn40jkULL_def)
printbr()

local K = var'K'
local ab2_KLL_def = K'_ij':eq(-alpha * conn4'^0_ij')
printbr(ab2_KLL_def)
ab2_KLL_def = ab2_KLL_def:subst(ab2_alpha_def,  ab2_conn40jkULL_def:reindex{jki='ijk'})
ab2_KLL_def = ab2_KLL_def:simplifyAddMulDiv()
printbr(ab2_KLL_def)
printbr()

local K_def = K:eq(gamma'^ij' * K'_ij')
printbr(K_def)
local ab2_K_def = K_def:subst(ab2_gammaUU_def, ab2_KLL_def)
ab2_K_def = ab2_K_def:simplifyAddMulDiv()
printbr(ab2_K_def)
ab2_K_def = ab2_K_def
	:replace(delta'^ij' * delta'_ij', n)
	:replace(delta'^ij' * v'_i,j', v'^k_,k')
	:replace(delta'^ij' * v'_j,i', v'^k_,k')
ab2_K_def = ab2_K_def()
printbr(ab2_K_def)
printbr()
