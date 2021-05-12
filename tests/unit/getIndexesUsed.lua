#!/usr/bin/env luajit
local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath.tests.unit.unit'(env, 'getIndexesUsed')

env.a = var'a'
env.b = var'b'
env.c = var'c'
env.d = var'd'
env.e = var'e'
env.f = var'f'
env.g = var'g'
env.fixed = var'fixed'
env.summed = var'summed'
env.extra = var'extra'
require 'ext.env'(env)

function env.assertIndexesUsed(expr, args)
	args = args or {}
	local expectedFixedIndexStr = args.fixed
	local expectedSummedIndexStr = args.summed
	local expectedExtraIndexStr = args.extra
	local expectedFixedTensor = expectedFixedIndexStr and env.fixed(expectedFixedIndexStr) or fixed
	local expectedSummedTensor = expectedSummedIndexStr and env.summed(expectedSummedIndexStr) or summed
	local expectedExtraTensor = expectedExtraIndexStr and env.extra(expectedExtraIndexStr) or extra

	-- these are the expression's TensorIndex's
	local fixedIndexes, summedIndexes, extraIndexes = expr:getIndexesUsed()
	local fixedTensor = fixedIndexes and #fixedIndexes > 0 and TensorRef(fixed, table.unpack(fixedIndexes)) or env.fixed
	local summedTensor = summedIndexes and #summedIndexes > 0 and TensorRef(summed, table.unpack(summedIndexes)) or env.summed
	local extraTensor = extraIndexes and #extraIndexes > 0 and TensorRef(extra, table.unpack(extraIndexes)) or env.extra

	for _,info in ipairs{
		{fixedTensor, expectedFixedTensor},
		{summedTensor, expectedSummedTensor},
		{extraTensor, expectedExtraTensor},
	} do 
		asserteq(info[1], info[2])
	end
end

for _,line in ipairs(string.split(string.trim([=[

-- not a TensorRef == no indexes used
assertIndexesUsed(c)

-- single TensorRef, fixed
assertIndexesUsed(c'_i', {fixed='_i'})
assertIndexesUsed(c'_ij', {fixed='_ij'})
assertIndexesUsed(c'^i_jk', {fixed='^i_jk'})

-- single TensorRef, summed
assertIndexesUsed(c'^i_i', {summed='^i'})

-- single TensorRef, mixed
assertIndexesUsed(c'^i_ij', {fixed='_j', summed='^i'})

-- mul, fixed * summed
assertIndexesUsed(a'_i' * b'^j_j', {fixed='_i', summed='^j'})

-- mul, fixed * fixed => summed
assertIndexesUsed(g'^im' * c'_mjk', {fixed='^i_jk', summed='^m'})

-- add, nothing
assertIndexesUsed(a + b)

-- add, fixed
assertIndexesUsed(a'_i' + b'_i', {fixed='_i'})
assertIndexesUsed(a'_ij' + b'_ij', {fixed='_ij'})

-- add, summed
assertIndexesUsed(a'^i_i' + b'^i_i', {summed='^i'})
assertIndexesUsed(a'^i_i' + b'^j_j', {summed='^ij'})

-- add, extra
assertIndexesUsed( a'_i' + b, {extra='_i'})
assertIndexesUsed( a + b'_j', {extra='_j'})
assertIndexesUsed( a'_i' + b'_j', {extra='_ij'})

-- add, fixed + summed
assertIndexesUsed( a'^i_ij' + b'^i_ij', {fixed='_j', summed='^i'})
assertIndexesUsed( a'^i_ij' + b'^k_kj', {fixed='_j', summed='^ik'})

-- add, fixed + extra
assertIndexesUsed( a'_ij' + b'_kj', {fixed='_j', extra='_ik'})

-- add, summed + extra
assertIndexesUsed( a'^i_ij' + b'^i_ik', {summed='^i', extra='_jk'})

-- add, fixed + summed + extra
assertIndexesUsed( a'_ij^jk' + b'_ij^jl', {fixed='_i', summed='_j', extra='^kl'})


-- TODO fixed and summed of add
-- TODO fixed and summed of add and mul


-- notice that the summed index is counted by the number of the symbol's occurrence, regardless of the lower/upper
-- this means the lower/upper of the summed will be arbitrary
assertIndexesUsed( a'^i' * b'_i' * c'_j', {fixed='_j', summed='^i'})

assertIndexesUsed(a'^i' * b'_i' * c'_j' + d'^i' * e'_i' * f'_j', {fixed='_j', summed='^i'})

assertIndexesUsed(a'^i' * b'_i', {summed='^i'}) 

assertIndexesUsed(a'^i' * b'_i' + c, {summed='^i'}) 

assertIndexesUsed(a'^i' * b'_i' + c'^i' * d'_i', {summed='^i'})

]=]), '\n')) do
	env.exec(line)
end
