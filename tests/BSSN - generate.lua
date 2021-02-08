#!/usr/bin/env luajit
-- this takes in the "BSSN - index - cache.lua" file and generates code for specific coordinate systems using finite difference

local env = setmetatable({}, {__index=_G})
require 'ext.env'(env)
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath'.setup{env=env}


local MathJax = symmath.export.MathJax
symmath.tostring = MathJax 
local printbr = MathJax.print
MathJax.header.title = 'BSSN formalism - code generation'
print(MathJax.header)


-- [=[ these are going slow
local mul = symmath.op.mul
mul.pushedRules = {[mul.rules.Expand[1]] = true}
require 'symmath.simplify'.useTrigSimplify = false
--]=]


local eqns = assert(loadfile'BSSN - index - cache.lua')()

local xs = table{'x','y','z'}	-- names of the fields in the internal real3 type in the simulation code

-- manifold info

-- this is going to be metric-specific
--[[ Cartesian

local x,y,z = vars('x', 'y', 'z')
local coords = table{x,y,z}
Tensor.coords{
	{variables=coords}
}

local e_lU_dense = Tensor('_i^I', 
	{1,0,0},
	{0,1,0},
	{0,0,1})

--]]
-- [[ spherical

local r, theta, phi = vars('r', 'theta', 'phi')
local coords = table{r, theta, phi}
Tensor.coords{
	{variables=coords}
}

local e_lU_dense = Tensor('_i^I', 
	{1,0,0},
	{0,r,0},
	{0,0,r*sin(theta)})

--]]


local e_uL_dense = Tensor('^i_I', 
	table.unpack((Matrix.inverse(e_lU_dense)))
)


-- variables

local function makeVars_U(name)
	return Tensor('^i', function(i)
		return var(name..'.'..xs[i])
	end)
end

local function makeVars_sym_LL(name)
	return Tensor('_ij', function(i,j)
		return var(name..'.'..table{xs[i],xs[j]}:sort():concat())
	end)
end

local function makeVars_sym_UU(name)
	return Tensor('^ij', function(i,j)
		return var(name..'.'..table{xs[i],xs[j]}:sort():concat())
	end)
end

local function makeVars_sym_ULL(name)
	return Tensor('^i_jk', function(i,j,k)
		return var(name..'.'..xs[i]..'.'..table{xs[j],xs[k]}:sort():concat())
	end)
end

-- coordinate form
local beta_U_dense = makeVars_U'U->beta_U'
local B_U_dense = makeVars_U'U->B_U'
local LambdaBar_U_dense = makeVars_U'U->LambdaBar_U'
local C_U_dense = makeVars_U'C_U'
local gammaBar_LL_dense = makeVars_sym_LL'gammaBar_LL'
local gammaBar_UU_dense = makeVars_sym_UU'gammaBar_UU'
local epsilonBar_LL_dense = makeVars_sym_LL'epsilonBar_LL'
local ABar_LL_dense = makeVars_sym_LL'ABar_LL'
local R_LL_dense = makeVars_sym_LL'R_LL'
local S_LL_dense = makeVars_sym_LL'S_LL'


-- local orthonormal non-coordinate transform derivatives:
local e_lUl_dense = e_lU_dense'_i^I_,j'():permute'_i^I_j'
local e_uLl_dense = e_uL_dense'^i_I_,j'():permute'^i_I_j'
local e_lUll_dense = e_lU_dense'_i^I_,jk'():permute'_i^I_jk'
local e_uLll_dense = e_uL_dense'^i_I_,jk'():permute'^i_I_jk'


-- locally-Minkowski spatial metric
local eta_LL_dense = Tensor('_IJ', function(i,j) return i == j and 1 or 0 end)
printbr(var'\\eta''_IJ':eq(eta_LL_dense))

local eta_UU_dense = Tensor('^IJ', function(i,j) return i == j and 1 or 0 end)
printbr(var'\\eta''^IJ':eq(eta_UU_dense))

-- grid metric, calculated based on the local transformations
local gammaHat_ll_dense = (e_lU_dense'_a^I' * e_lU_dense'_b^J' * eta_LL_dense'_IJ')()
printbr(var'\\hat{\\gamma}''_ij':eq(gammaHat_ll_dense))

local det_gammaHat_ll = Matrix.determinant(gammaHat_ll_dense)
printbr(var'\\hat{\\gamma}':eq(det_gammaHat_ll))

local GammaHat_lll_dense = (frac(1,2) * (gammaHat_ll_dense'_ij,k' + gammaHat_ll_dense'_ik,j' - gammaHat_ll_dense'_jk,i'))():permute'_ijk'
printbr(var'\\hat{\\Gamma}''_ijk':eq(GammaHat_lll_dense))

local GammaHat_LLL_dense = (e_uL_dense'^i_I' * e_uL_dense'^j_J' * e_uL_dense'^k_K' * GammaHat_lll_dense'_ijk')():permute'_IJK'
printbr(var'\\hat{\\Gamma}''_IJK':eq(GammaHat_LLL_dense))

local GammaHat_ULL_dense = (eta_UU_dense'^IM' * GammaHat_LLL_dense'_MJK')():permute'^I_JK'	-- since the metric is locally-Minkowski 
printbr(var'\\hat{\\Gamma}''^I_JK':eq(GammaHat_ULL_dense))

-- looks like in my 'BSSN - index.lua', GammaHat^a isn't GammaHat^a_bc gammaHat^bc, but is GammaHat^a_bc gammaBar^bc
-- maybe I shouldn't even save it in the output of 'BSSN - index.lua' ?

local GammaHat_U_dense = (GammaHat_ULL_dense'^I_JK' * gammaBar_UU_dense'^JK')()
printbr(var'\\hat{\\Gamma}''^I':eq(GammaHat_U_dense))

-- by BSSN assertion, det_gammaBar = det_gammaHat, so:
local partial_det_gammaBar_l_dense = Tensor('_i', function(i)
	return det_gammaHat_ll:diff(coords[i])()
end)
printbr(var'\\hat{\\gamma}''_,i':eq(partial_det_gammaBar_l_dense))


-- derivatives


local partial_alpha_l_dense = Tensor('_i', function(i)
	return var('partial_alpha_l.'..xs[i])
end)
local partial_W_l_dense = Tensor('_i', function(i)
	return var('partial_W_l.'..xs[i])
end)
local partial_K_l_dense = Tensor('_i', function(i)
	return var('partial_K_l.'..xs[i])
end)
local partial_beta_Ul_dense = Tensor('^I_j', function(i,j)
	return var('partial_beta_Ul['..(j-1)..'].'..xs[i])
end)
local partial_gammaBar_LLl_dense = Tensor('_IJk', function(i,j,k)
	return var('partial_gammaBar_LLl['..(k-1)..'].'..table{xs[i],xs[j]}:sort():concat())
end)
local partial_ABar_LLl_dense = Tensor('_IJk', function(i,j,k)
	return var('partial_ABar_LLl['..(k-1)..'].'..table{xs[i],xs[j]}:sort():concat())
end)


	-- 2nd derivs

local partial2_alpha_ll_dense = Tensor('_ij', function(i,j)
	return var('partial2_alpha_ll.'..table{xs[i],xs[j]}:sort():concat())
end)
local partial2_beta_Ull_dense = Tensor('^I_jk', function(i,j,k)
	return var('partial2_beta_Ull['..(j-1)..']['..(k-1)..'].'..xs[i])
end)
local partial2_gammaBar_LLll_dense = Tensor('_IJkl', function(i,j,k,l)
	return var('partial2_gammaBar_LLll['..(k-1)..']['..(l-1)..'].'..table{xs[i],xs[j]}:sort():concat())
end)

-- time derivatives of state variables:
local dt_alpha = var'dt_alpha'
local dt_beta_U_dense = makeVars_U'dt_beta_U'
local dt_W = var'dt_W'
local dt_K = var'dt_K'
local dt_epsilonBar_LL_dense = makeVars_sym_LL'dt_epsilonBar_LL'
local dt_ABar_LL_dense = makeVars_sym_LL'dt_ABar_LL'
local dt_LambdaBar_U_dense = makeVars_U'dt_LambdaBar_U'
local dt_B_U_dense = makeVars_U'dt_B_U'


-- convert from tex vars and partials to C vars

io.stderr:write('starting conversion...\n')
io.stderr:flush()

local allResultEqns = table()

for _,nameAndEqn in ipairs(eqns) do
	local name, eqn = next(nameAndEqn)
	if name:match'_norm_def$' then	-- use the normalized version

		local lhs, rhs = table.unpack(eqn)
		if not TensorRef.is(lhs) then
			printbr("expected lhs to be a TensorRef, found: ", lhs)
			error'expected lhs to be a TensorRef'
		end
		assert(lhs[#lhs].symbol == 't' and lhs[#lhs].lower)
		printbr('variable: '..lhs[1])
		io.stderr:write('variable: '..lhs[1]..'\n')
		io.stderr:flush()
		printbr('eqn:'..eqn)

local origRhs = rhs:clone()
		eqn = eqn:factorDivision()

timer('replacing tensors with dense tensors', function()
		eqn = eqn
			--:splitOffDerivIndexes()
			
			-- special for B^I_,t's replacement ,which has another _,t in its rhs:
			-- why not just do this with all of them?  to fix the variable assignment names...
			-- TODO don't do replaceIndex since we don't want the 't' remapped
			:replace(var'\\alpha''_,t', dt_alpha)
			:replace(var'\\beta''^I_,t', dt_beta_U_dense'^I')
			:replace(var'W''_,t', dt_W)
			:replace(var'K''_,t', dt_K)
			:replace(var'\\bar{\\epsilon}''_IJ,t', dt_epsilonBar_LL_dense'_IJ')
			:replace(var'\\bar{A}''_IJ,t', dt_ABar_LL_dense'_IJ')
			:replace(var'\\bar{\\Lambda}''^I_,t', dt_LambdaBar_U_dense'^I')
			:replace(var'B''^I_,t', dt_B_U_dense'^I')

			-- scalar 2nd derivs
			:replaceIndex(var'\\alpha''_,ij', partial2_alpha_ll_dense'_ij')
			-- scalar 1st derivs
			:replaceIndex(var'\\alpha''_,i', partial_alpha_l_dense'_i')
			:replaceIndex(var'W''_,i', partial_W_l_dense'_i')
			:replaceIndex(var'K''_,i', partial_K_l_dense'_i')
			:replaceIndex(var'\\bar{\\gamma}''_,i', partial_det_gammaBar_l_dense'_i')
			-- tensor 1st derivs - though shouldn't they autogen?
			:replaceIndex(var'\\beta''^I_,j', partial_beta_Ul_dense'^I_j')
			:replaceIndex(var'\\bar{\\gamma}''_IJ,k', partial_gammaBar_LLl_dense'_IJk')
			:replaceIndex(var'\\bar{A}''_IJ,k', partial_ABar_LLl_dense'_IJk')
			-- tensor 2nd derivs 
			:replaceIndex(var'\\beta''^I_,jk', partial2_beta_Ull_dense'^I_jk')
			:replaceIndex(var'\\bar{\\gamma}''_IJ,kl', partial2_gammaBar_LLll_dense'_IJkl')
			-- tensor vars
			:replaceIndex(var'\\beta''^I', beta_U_dense'^I')
			:replaceIndex(var'B''^I', B_U_dense'^I')
			:replaceIndex(var'\\mathcal{C}''^I', C_U_dense'^I')
			:replaceIndex(var'\\bar{\\Lambda}''^I', LambdaBar_U_dense'^I')
			:replaceIndex(var'\\bar{\\epsilon}''_IJ', epsilonBar_LL_dense'_IJ')
			:replaceIndex(var'\\bar{\\gamma}''_IJ', gammaBar_LL_dense'_IJ')
			:replaceIndex(var'\\bar{\\gamma}''^IJ', gammaBar_UU_dense'^IJ')
			:replaceIndex(var'\\bar{A}''_IJ', ABar_LL_dense'_IJ')
			:replaceIndex(var'R''_IJ', R_LL_dense'_IJ')
			:replaceIndex(var'S''_IJ', S_LL_dense'_IJ')
			:replaceIndex(var'\\hat{\\Gamma}''^I_JK', GammaHat_ULL_dense'^I_JK') 
			:replaceIndex(var'\\hat{\\Gamma}''^I', GammaHat_U_dense'^I') 
			-- rename greek to C var names
			:replace(var'\\alpha', var'U->alpha')
			:replace(var'\\rho', var'U->rho')
			:replace(var'\\pi', var'M_PI')
			:replace(var'\\bar{\\gamma}', var'det_gammaBar')
			-- scalar vars fine as they are:
			-- var'S' 
			:replace(var'K', var'U->K')
			-- var'R'
			-- var'W'
		
			-- e_i^I and e^i_I are special, because replaceIndex can't discern the i's from I's, so i'll use map()
			-- actually I will just assume that the e indexes haven't been raised or lowered
			-- (and so far I'm not doing this)
			-- which means the upper/lower will determine the direction of the transform
			:replaceIndex(var'e''_i^I', e_lU_dense'_i^I')
			:replaceIndex(var'e''^i_I', e_uL_dense'^i_I')
			:replaceIndex(var'e''_i^I_,j', e_lUl_dense'_i^I_j')
			:replaceIndex(var'e''^i_I_,j', e_uLl_dense'^i_I_j')
			:replaceIndex(var'e''_i^I_,jk', e_lUll_dense'_i^I_jk')
			:replaceIndex(var'e''^i_I_,jk', e_uLll_dense'^i_I_jk')
end)

			-- TODO what about f?  what about substituting its analytical value?
			--  f = 2 / alpha for Bona-Masso slicing

		printbr('new eqn:', eqn)

timer('simplifying', function()
		-- all of these are too slow
		--[[
		eqn = eqn()
		--]]
		--[[
		eqn = eqn:factorDivision()	-- got all the way to LambdaBar 
		--]]
		-- [[
		eqn[1] = eqn[1]()
		if symmath.op.add.is(eqn[2]) then
			for i=1,#eqn[2] do
timer('simplifying term '..i, function()
printbr('simplifying term '..i)
printbr('from', eqn[2][i])
				eqn[2][i] = eqn[2][i]:simplifyAddMulDiv()
printbr('to', eqn[2][i])
end)			
			end
-- this is the worst wrt performance
timer('simplifying addition of terms', function()
			eqn[2] = eqn[2]:simplifyAddMulDiv()
end)
		else
			eqn[2] = eqn[2]:simplifyAddMulDiv()
		end
		--]]
end)

io.stderr:write('creating equations with new variable names...\n')
io.stderr:flush()

		local resultEqns = table()
		
		local lhs, rhs = table.unpack(eqn)
		
		-- lazy arbitrary nested for-loop:
		if not Tensor.is(lhs) then
			assert(Variable.is(lhs), "expected TensorRef or Variable on lhs, found "..lhs.name)
			assert(rhs)
			-- scalar
			resultEqns:insert{[lhs.name] = rhs}
		else
			assert(Tensor.is(rhs), "lhs is a Tensor but rhs didn't simplify to a Tensor")
			local variance = table.sub(lhs, 2,#lhs-1) 
			-- tensor
			--printbr('variance: '..variance:mapi(tostring):concat())
			for is,lhsvalue in lhs:iter() do
				is = table(is)
				local rhsvalue = rhs[is]
				if not rhsvalue then
					local msg = ("failed to find "..tostring(lhs).."["..is:concat','.."]<br>\n"
								.."from orig eqn "..tostring(origRhs).."["..is:concat','.."]<br>\n"
								.."rhs "..tostring(rhs).."<br>\n"
								.."rhs["..is:concat','.."] = "..tostring(rhsvalue))
					printbr(msg)
					error(msg)
				end
				--printbr(...)
				resultEqns:insert{[lhsvalue.name] = rhs[is]}
			end
		end

		printbr'<pre>'
timer('exporting to C', function()
		--[[ single-line output
		for _,eqn in ipairs(resultEqns) do
			local k,v = next(eqn)	-- why would this ever fail?
			printbr(export.C(var(k):eq(v)))
		end
		--]]
		-- [[ cache the like expressions
		printbr(export.C:toCode{
			output = resultEqns,
		})
end)		
		--]]
		printbr'</pre>'
		printbr()
	end

	allResultEqns:append(resultEqns)
end


-- to C code

io.stderr:write('converting to C code:\n')
io.stderr:flush()

printbr'---------------------------'
printbr(export.C:toCode{
	output = allResultEqns,
})

print(MathJax.footer)
