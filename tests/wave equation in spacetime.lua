#!/usr/bin/env luajit
require 'ext'
require 'symmath'.setup{tostring='MathJax', MathJax={title='wave equation in spacetime'}}

-- used here and in 'Kaluza-Klein - index' ... maybe I should just change 'simplify'
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
local alpha = var'\\alpha'
local beta = var'\\beta'
local gamma = var'\\gamma'
printbr'ADM metric:'
printbr()
local ADMdef = g' _\\mu _\\nu':eq(Matrix( {-alpha^2 + beta'^k' * beta'_k', beta'_j' }, { beta'_i', gamma'_ij' }))
printbr(ADMdef)
printbr()
local ADMInv_def = g' ^\\mu ^\\nu':eq(Matrix( {-frac(1, alpha^2), frac(1, alpha^2) * beta'^j' }, { frac(1, alpha^2) * beta'^i', gamma'^ij' - frac(1, alpha^2) * beta'^i' * beta'^j' }))
printbr(ADMInv_def)
printbr()
local n = var'n'
local normalL_def = n' _\\mu':eq(Matrix({ -alpha, 0 }))
printbr(normalL_def)
printbr()
local normalU_def = n' ^\\mu':eq(Matrix({ frac(1,alpha), -frac(1,alpha) * beta'^i' }))
printbr(normalU_def)
printbr()

local K = var'K'
local conn3 = var'\\Gamma'
local conn4 = var'\\bar{\\Gamma}'
printbr[[From 2008 Alcubierre "Introduction to 3+1 Numerical Relativity" Appendix B]]
local conn40U_def = conn4'^0':eq( -frac(1,alpha^3) * (alpha'_,0' - beta'^m' * alpha'_,m' + alpha^2 * K) )
printbr(conn40U_def)
local conn4iU_def = conn4'^i':eq( conn3'^i' + frac(1,alpha^3) * beta'^i' * (alpha'_,0' - beta'^m' * alpha'_,m' + alpha^2 * K) - frac(1,alpha^2) * (beta'^i_,0' - beta'^m' * beta'^i_,m' + alpha * alpha'_j' * gamma'^ij') )
printbr(conn4iU_def)
printbr()

printbr[[Let ${\bar{\Gamma}^\alpha}_{\mu\nu}$ is the 4-metric connection.]]
printbr[[Let $\bar{\Gamma}^\alpha = {\bar{\Gamma}^\alpha}_{\mu\nu} g^{\mu\nu}$]]
printbr()

local Phi = var'\\Phi'
local f = var'f'
printbr'wave equation in spacetime:'
local waveEqn = Phi' _;\\mu ^;\\mu':eq(f)
printbr(waveEqn)
waveEqn = (g' ^\\mu ^\\nu' * Phi' _;\\mu _\\nu'):eq(f)
printbr(waveEqn)
waveEqn = (g' ^\\mu ^\\nu' * (Phi' _,\\mu _\\nu' - conn4' ^\\alpha _\\mu _\\nu' * Phi' _,\\alpha')):eq(f)
printbr(waveEqn)
waveEqn = (g' ^\\mu ^\\nu' * Phi' _,\\mu _\\nu' - conn4' ^\\alpha' * Phi' _,\\alpha'):eq(f)
printbr(waveEqn)
printbr'split space and time:'
waveEqn = (g'^00' * Phi'_,00' + 2 * g'^0i' * Phi'_,0i' + g'^ij' * Phi'_,ij' - conn4'^0' * Phi'_,0' - conn4'^i' * Phi'_,i'):eq(f)
printbr(waveEqn)
printbr'substitute ADM metric components into wave equation:'
waveEqn = betterSimplify(waveEqn
	:replace(g'^00', ADMInv_def:rhs()[1][1])
	:replace(g'^0i', ADMInv_def:rhs()[2][1])
	:replace(g'^ij', ADMInv_def:rhs()[2][2])
)
printbr(waveEqn)
printbr[[solve for $\Phi_{,00}$:]]
local d00_Phi_def = waveEqn:solve(Phi'_,00')
printbr(d00_Phi_def)
printbr()

local Pi = var'\\Pi'
local Pi_def = Pi:eq(n' ^\\mu' * Phi' _,\\mu')
printbr('Let ', Pi_def)
-- Pi_def = splitIndexes(Pi_def, {' \\mu' = {'0', 'i'}})
Pi_def = Pi:eq(n'^0' * Phi'_,0' + n'^i' * Phi'_,i')
printbr(Pi_def)
Pi_def = betterSimplify(Pi_def
	:replace(n'^0', normalU_def:rhs()[1][1])
	:replace(n'^i', normalU_def:rhs()[1][2])
)
printbr(Pi_def)
printbr()

local Psi = var'\\Psi'
local Psi_def = Psi'_i':eq(Phi'_,i')
printbr[[Let $\Psi = \nabla^\perp_i \Phi = {\gamma_i}^\mu \nabla_\mu \Phi$]]
printbr(Psi_def)
local di_Phi_def = Psi_def:solve(Phi'_,i')
printbr(di_Phi_def)
printbr()

printbr[[Solve $\Pi$ for $\Phi_{,0}$:]]
local d0_Phi_def = betterSimplify(Pi_def:solve(Phi'_,0'))
printbr(d0_Phi_def )
d0_Phi_def = betterSimplify(d0_Phi_def:subst(Psi_def:switch()))
printbr(d0_Phi_def )
printbr()

printbr[[Solve $\Pi_{,i}$ for $\Psi_{i,0}$:]]
di_Pi_def = betterSimplify(Pi_def:reindex{i='j'}'_,i'()
	:symmetrizeIndexes(Phi, {1,2})
)
printbr(di_Pi_def)
printbr('substitute', d0_Phi_def, ',', di_Phi_def)
di_Pi_def = betterSimplify(di_Pi_def:subst(d0_Phi_def:reindex{i='j'}, di_Phi_def:reindex{i='j'}))
printbr(di_Pi_def)
printbr()

printbr[[Solve $\Pi_{,0}$]]
local d0_Pi_def = betterSimplify(Pi_def'_,0'():symmetrizeIndexes(Phi, {1,2}))
printbr(d0_Pi_def)
printbr('substitute', di_Phi_def, ',', d0_Phi_def)
d0_Pi_def = betterSimplify(d0_Pi_def:subst(di_Phi_def, d0_Phi_def))
printbr(d0_Pi_def)
printbr('substitute', d00_Phi_def, ',', di_Phi_def, ',', di_Phi_def'_,j'())
d0_Pi_def = betterSimplify(d0_Pi_def:subst(d00_Phi_def, di_Phi_def, di_Phi_def'_,j'()))
printbr(d0_Pi_def)
printbr('substitute', conn40U_def, ',', d0_Phi_def, ',', d0_Phi_def:reindex{i='j'}'_,i'())
d0_Pi_def = d0_Pi_def:subst(
	conn40U_def, 
	d0_Phi_def, 
	d0_Phi_def:reindex{i='j'}'_,i'()
):replace(Psi'_j,i', Psi'_i,j')()
d0_Pi_def = d0_Pi_def:replace( beta'^i' * alpha'_,i', beta'^m' * alpha'_,m')()
d0_Pi_def = d0_Pi_def:reindex{m='j'}
d0_Pi_def = betterSimplify(d0_Pi_def)
printbr(d0_Pi_def)
-- hmm, I need to get this to ignore indexes... otherwise it gives an error
---d0_Pi_def = d0_Pi_def:tidyIndexes{fixed='0'}	
--printbr(d0_Pi_def)
printbr()
