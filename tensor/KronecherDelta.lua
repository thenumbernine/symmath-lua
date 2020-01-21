local range = require 'ext.range'

--[[
generalized kronecher delta
delta^a_b = 1 for a == b, 0 otherwise

delta^{a1 ... ak}_{b1 ... bk} = k! delta^a1_[b1 delta^a2_b2 ... delta^ak_bk] (antisymmetric index brackets around lower indexes)
--]]
return function(rank, symbol)
	rank = rank or 1
	
	local basis = Tensor.findBasisForSymbol(symbol)

	local defaultSymbols = require 'symmath.Tensor'.defaultSymbols
	local variance = 
	' '..range(1,rank):mapi(function(i)
		return '^'..(
			basis and basis.symbols and basis.symbols[i]
			or defaultSymbols[i]
			or error("ran out of symbols")
		)
	end):concat' '
	..' '..range(rank+1,rank*2):mapi(function(i)
		return '_'..(
			basis and basis.symbols and basis.symbols[i]
			or defaultSymbols[i]
			or error("ran out of symbols")
		)
	end):concat' '

	return Tensor(variance, function(...)
		local indexes = {...}
		-- duplicates mean 0
		for i=1,rank-1 do
			for j=i+1,rank do
				if indexes[i] == indexes[j] then return 0 end
				if indexes[i+rank] == indexes[j+rank] then return 0 end
			end
		end
		-- bubble sort, count the flips
		local parity = 1
		for i=1,rank-1 do
			for j=1,rank-i do
				if indexes[j] > indexes[j+1] then
					indexes[j], indexes[j+1] = indexes[j+1], indexes[j]
					parity = -parity
				end
				if indexes[j+rank] > indexes[j+1+rank] then
					indexes[j+rank], indexes[j+1+rank] = indexes[j+1+rank], indexes[j+rank]
					parity = -parity
				end		
			end
		end
		for i=1,rank do
			if indexes[i] ~= indexes[i+rank] then return 0 end
		end
		return parity
	end)
end
