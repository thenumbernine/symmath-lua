#!/usr/bin/env luajit
-- this takes in the "BSSN - index - cache.lua" file and generates code for specific coordinate systems using finite difference

local env = setmetatable({}, {__index=_G})
require 'ext.env'(env)
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath'.setup{env=env}


local MathJax = symmath.export.MathJax
symmath.tostring = MathJax 
local printbr = MathJax.print
MathJax.header.title = 'BSSN formalism - index notation'
print(MathJax.header)




local eqns = table{
	assert(loadfile'BSSN - index - cache.lua')()
}


-- manifold info


local xs = table{'x','y','z'}
local x,y,z = vars(xs:unpack())
local coords = table{x,y,z}

Tensor.coords{
	{variables={x,y,z}}
}


-- variables


local beta_u_dense = Tensor('^i', function(i)
	return var('beta_u.'..xs[i])
end)
local B_u_dense = Tensor('^i', function(i)
	return var('B_u.'..xs[i])
end)
local LambdaBar_u_dense = Tensor('^i', function(i)
	return var('LambdaBar_u.'..xs[i])
end)
local gammaBar_ll_dense = Tensor('_ij', function(i,j)
	return var('gammaBar_ll.'..table{xs[i],xs[j]}:sort():concat())
end)
local gammaBar_uu_dense = Tensor('^ij', function(i,j)
	return var('gammaBar_uu.'..table{xs[i],xs[j]}:sort():concat())
end)
local epsilonBar_ll_dense = Tensor('_ij', function(i,j)
	return var('epsilonBar_ll.'..table{xs[i],xs[j]}:sort():concat())
end)
local ABar_ll_dense = Tensor('_ij', function(i,j)
	return var('ABar_ll.'..table{xs[i],xs[j]}:sort():concat())
end)
local R_ll_dense = Tensor('_ij', function(i,j)
	return var('R_ll.'..table{xs[i],xs[j]}:sort():concat())
end)
local S_ll_dense = Tensor('_ij', function(i,j)
	return var('S_ll.'..table{xs[i],xs[j]}:sort():concat())
end)
local GammaHat_ull_dense = Tensor('^i_jk', function(i,j,k)
	return var('GammaHat_ull.'..xs[i]..'.'..table{xs[j],xs[k]}:sort():concat())
end)


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
local partial_beta_ul_dense = Tensor('^i_j', function(i,j)
	return var('partial_beta_ul['..(j-1)..'].'..xs[i])
end)
local partial_gammaBar_lll_dense = Tensor('_ijk', function(i,j,k)
	return var('partial_gammaBar_lll['..(k-1)..'].'..table{xs[i],xs[j]}:sort():concat())
end)
local partial_ABar_lll_dense = Tensor('_ijk', function(i,j,k)
	return var('partial_ABar_lll['..(k-1)..'].'..table{xs[i],xs[j]}:sort():concat())
end)


	-- 2nd derivs

local partial2_alpha_ll_dense = Tensor('_ij', function(i,j)
	return var('partial_alpha_l.'..table{xs[i],xs[j]}:sort():concat())
end)


-- convert from tex vars and partials to C vars


for i,eqn in ipairs(eqns) do
	local lhs, rhs = table.unpack(eqn)
	assert(TensorRef.is(lhs))
	assert(lhs[#lhs].symbol == 't' and lhs[#lhs].lower)
	printbr('variable: '..lhs[1])
	
	rhs = rhs
		--:splitOffDerivIndexes()
		-- scalar 2nd derivs
		:replaceIndex(var'\\alpha''_,ij', partial2_alpha_ll_dense'_ij')
		-- scalar 1st derivs
		:replaceIndex(var'\\alpha''_,i', partial_alpha_l_dense'_i')
		:replaceIndex(var'W''_,i', partial_W_l_dense'_i')
		:replaceIndex(var'K''_,i', partial_K_l_dense'_i')
		-- tensor derivs - though shouldn't they autogen?
		:replaceIndex(var'\\beta''^i_,j', partial_beta_ul_dense'^i_j')
		:replaceIndex(var'\\bar{\\gamma}''_ij,k', partial_gammaBar_lll_dense'_ijk')
		:replaceIndex(var'\\bar{A}''_ij,k', partial_ABar_lll_dense'_ijk')
		-- tensor vars
		:replaceIndex(var'\\beta''^i', beta_u_dense'^i')
		:replaceIndex(var'B''^i', B_u_dense'^i')
		:replaceIndex(var'\\bar{\\Lambda}''^i', LambdaBar_u_dense'^i')
		:replaceIndex(var'\\bar{\\epsilon}''_ij', epsilonBar_ll_dense'_ij')
		:replaceIndex(var'\\bar{\\gamma}''_ij', gammaBar_ll_dense'_ij')
		:replaceIndex(var'\\bar{\\gamma}''^ij', gammaBar_uu_dense'^ij')
		:replaceIndex(var'\\bar{A}''_ij', ABar_ll_dense'_ij')
		:replaceIndex(var'R''_ij', R_ll_dense'_ij')
		:replaceIndex(var'S''_ij', S_ll_dense'_ij')
		:replaceIndex(var'\\hat{\\Gamma}''^i_jk', GammaHat_ull_dense'^i_jk') 
		-- rename greek to C var names
		:replace(var'\\alpha', var'alpha')
		:replace(var'\\rho', var'rho')
		:replace(var'\\pi', var'M_PI')
	printbr(rhs)
	rhs = rhs
		:simplify()	-- contract all the tensor operations
	
	local resultEqns = table()
	
	-- lazy arbitrary nested for-loop:
	local variance = table.sub(lhs, 2,#lhs-1)
	if #variance == 0 then
		-- scalar
		resultEqns:insert{['deriv->'..lhs[1].name:gsub('\\', '')] = rhs}
	else
		-- tensor
		--printbr('variance: '..variance:mapi(tostring):concat())
		Tensor(variance, function(...)
			local is = table{...}
			--printbr(...)
			resultEqns:insert{['deriv->'..lhs[1].name:gsub('\\', '')..'.'..is:mapi(function(i) return xs[i] end):concat()] = rhs[is]}
		end)
	end

	for _,eqn in ipairs(resultEqns) do
		local k,v = next(eqn)
		printbr(var(k):eq(v))
		printbr()
	end
end


-- to C code


print'---------------------------'
print(symmath.export.C:toCode{
	output = resultEqns,
})
