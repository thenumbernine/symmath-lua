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




local eqns = assert(loadfile'BSSN - index - cache.lua')()


--[[ hack for fixing things
eqns = table{eqns[#eqns-1]}
print(eqns[1][1])
assert(eqns[1][1] == var'\\bar{\\Lambda}''^i_,t')
--]]


-- manifold info


local xs = table{'x','y','z'}
local x,y,z = vars(xs:unpack())
local coords = table{x,y,z}

Tensor.coords{
	{variables={x,y,z}}
}


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

-- [[ coordinate form
local beta_U_dense = makeVars_U'U->beta_U'
local B_U_dense = makeVars_U'U->B_U'
local LambdaBar_U_dense = makeVars_U'U->LambdaBar_U'
local dt_LambdaBar_U_dense = makeVars_U'dt_LambdaBar_U'
local C_U_dense = makeVars_U'C_U'
local gammaBar_LL_dense = makeVars_sym_LL'gammaBar_LL'
local gammaBar_UU_dense = makeVars_sym_UU'gammaBar_UU'
local epsilonBar_LL_dense = makeVars_sym_LL'epsilonBar_LL'
local ABar_LL_dense = makeVars_sym_LL'ABar_LL'
local R_LL_dense = makeVars_sym_LL'R_LL'
local S_LL_dense = makeVars_sym_LL'S_LL'
local GammaHat_U_dense = makeVars_U'GammaHat_U'
local GammaHat_ULL_dense = makeVars_sym_ULL'GammaHat_ULL'

-- this is going to be metric-specific
-- Cartesian
local e_lU_dense = Tensor('_i^I', 
	{1,0,0},
	{0,1,0},
	{0,0,1})
local e_uL_dense = Tensor('^i_I', 
	{1,0,0},
	{0,1,0},
	{0,0,1})

local e_lUl_dense = e_lU_dense'_i^I_,j'():permute'_i^I_j'
local e_uLl_dense = e_uL_dense'^i_I_,j'():permute'^i_I_j'

-- derivatives


local partial_det_gammaBar_l_dense = Tensor('_i', function(i)
	return var('partial_det_gammaBar_l.'..xs[i])
end)
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
		printbr('rhs:'..rhs)

local origRhs = rhs
		rhs = rhs:factorDivision()

		rhs = rhs
			--:splitOffDerivIndexes()
			
			-- special for B^I_,t's replacement ,which has another _,t in its rhs:

			:replace(var'\\bar{\\Lambda}''^I_,t', dt_LambdaBar_U_dense'^I')

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


			-- TODO what about f?  what about substituting its analytical value?
			--  f = 2 / alpha for Bona-Masso slicing

		printbr('new rhs:', rhs)


		rhs = rhs()
		--rhs = rhs:factorDivision()	-- got all the way to LambdaBar 

io.stderr:write('creating equations with new variable names...\n')
io.stderr:flush()

		local resultEqns = table()
		
		-- lazy arbitrary nested for-loop:
		local variance = table.sub(lhs, 2,#lhs-1)
		if #variance == 0 then
			assert(rhs)
			-- scalar
			resultEqns:insert{['deriv->'..lhs[1].name:gsub('\\', '')] = rhs}
		else
			-- tensor
			--printbr('variance: '..variance:mapi(tostring):concat())
			Tensor(variance, function(...)
				local is = table{...}
				if not rhs[is] then
					local msg = ("failed to find "..tostring(lhs).."["..is:concat','.."]<br>\n"
								.."from orig eqn "..origRhs.."["..is:concat','.."]<br>\n"
								.."rhs "..tostring(rhs).."<br>\n"
								.."rhs["..is:concat','.."] = "..tostring(rhs[is]))
					printbr(msg)
					error(msg)
				end
				--printbr(...)
				resultEqns:insert{['deriv->'..lhs[1].name:gsub('\\', '')..'.'..is:mapi(function(i) return xs[i] end):concat()] = rhs[is]}
			end)
		end

		for _,eqn in ipairs(resultEqns) do
			local k,v = next(eqn)	-- why would this ever fail?
			assert(k, "failed on "..tolua(eqn))
			assert(v, "failed on "..tolua(eqn))
			printbr('<pre>', export.C(var(k):eq(v)), '</pre>')
			printbr()
		end
	end

	allResultEqns:append(resultEqns)
end


-- to C code

io.stderr:write('converting to C code:\n')
io.stderr:flush()

print'---------------------------'
print(symmath.export.C:toCode{
	output = allResultEqns,
})
