#!/usr/bin/env luajit
require 'ext'
require 'symmath'.setup{
	implicitVars=true,
	fixVariableNames=true,
	MathJax={
		title='Faraday tensor',
		--useCommaDerivative=true,			-- has latex errors
		usePartialLHSForDerivative=true,
	},
}

local KronDelta = require 'symmath.tensor.KronecherDelta'

local txs = table{t,x,y,z}
Tensor.coords{{variables=txs}}

ADef = Tensor('_a', function(a) 
	return var('A_'..txs[a].name, txs)
end)
printbr(A'_a':eq(ADef))

local FDef = (KronDelta(2)'^cd_ab' * ADef'_d,c')()
printbr(F'_ab':eq(FDef))

local partialFDef = FDef'_bc,a'():permute'_abc'
printbr(F'_bc,a':eq(partialFDef))

local d1 = KronDelta(1)
local d3 = KronDelta(3)
--printbr(delta'^abc_def')
--d3:printElem'delta' printbr()

-- assumes T is in covariant form: T_abc
function KronecherDelta3(T)
	assert(#T.variance == 3, "this only works on a 3-form")
	-- TODO also assert that all indexes are lowered
	return (T'_abc' + T'_bca' + T'_cab' - T'_cba' - T'_acb' - T'_bac')()
end

-- this is really slow and returns zeroes anyways... but dF = d^2 A = 0, so that means it works.
-- I bet it would be faster if we just used the rank-2 delta representation of the rank-2n delta
local startTime = os.clock()
io.stderr:write('starting d3^abc_def * partialFDef_abc...\n') io.stderr:flush()
--[[ it's taking 4:19 to finish
--local extFDef = (d3'^abc_def' * partialFDef'_abc')()
--local extFDef = (d3 * partialFDef)()
--]]
--[[ takes 5:13 to finish
local extFDef = (
	(
		d1'^a_d' * d1'^b_e' * d1'^c_f' 
		+ d1'^a_e' * d1'^b_f' * d1'^c_d' 
		+ d1'^a_f' * d1'^b_d' * d1'^c_e' 
		- d1'^a_f' * d1'^b_e' * d1'^c_d' 
		- d1'^a_d' * d1'^b_f' * d1'^c_e' 
		- d1'^a_e' * d1'^b_d' * d1'^c_f' 
	) * partialFDef'_abc'
)()
--]]
-- [[	-- 5.8 seconds
local extFDef = KronecherDelta3(partialFDef)
--]]

io.stderr:write('...done.  took '..(os.clock()-startTime)..' seconds\n') io.stderr:flush()
--[[
local extFDef = Tensor('_abc', function(a,b,c)
	local sum = 0
	for all permutations of a,b,c do
		sum = sum + parity * partialFDef[a][b][c]
	end
	return sum()
end)
--]]
printbr'verify $d^2 A = 0$'
printbr(var'dF''_abc':eq(extFDef))

FDef = Tensor('_ab', function(a,b)
	if a==b then return 0 end
	local s = 1
	if a>b then a,b,s = b,a,-1 end
	return s * var('F_{'..txs[a].name..txs[b].name..'}', txs)
end)
printbr(F'_ab':eq(FDef))

local partialFDef = FDef'_bc,a'():permute'_abc'
printbr(F'_bc,a':eq(partialFDef))

local startTime = os.clock()
io.stderr:write('starting d3^abc_def * partialFDef_abc...\n') io.stderr:flush()
local extFDef = KronecherDelta3(partialFDef)
io.stderr:write('...done.  took '..(os.clock()-startTime)..' seconds\n') io.stderr:flush()
--[[
local extFDef = Tensor('_abc', function(a,b,c)
	local sum = 0
	for all permutations of a,b,c do
		sum = sum + parity * partialFDef[a][b][c]
	end
	return sum()
end)
--]]
printbr'$d^2 A = 0$ in terms of $F_{ab}'
printbr(var'dF''_abc':eq(extFDef))

