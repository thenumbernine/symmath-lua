local table = require 'ext.table'
--[[
makeLeviCivita(symbol, sqrtDetG)
	symbol = (optional) symbol of coordinates that the Levi-Civita symbol pertains to
		this determines the rank and the sqrtDetG
		if symbol is a number then this is the rank and the sqrtDetG default value is 1 
	sqrtDetG = (optional) sqrtDetG
--]]
local function makeLeviCivita(symbol, sqrtDetG)
	local Tensor = require 'symmath.Tensor'
	local Matrix = require 'symmath.Matrix'
	local Constant = require 'symmath.Constant'
	local sqrt = require 'symmath.sqrt'
	local TensorIndex = require 'symmath.tensor.TensorIndex'

	local rank
	local basis
	if type(symbol) == 'number' then
		rank = symbol
		sqrtDetG = sqrtDetG or 1
		basis = Tensor.findBasisForSymbol()
	else
		basis = Tensor.findBasisForSymbol(symbol or {})
		rank = basis and basis.metric and #basis.metric
			or #Tensor.__coordBasis[1].variables

		if not sqrtDetG then
			sqrtDetG = basis and basis.metric
				-- TODO: sqrt(abs(det(metric)))
				and sqrt(Matrix.determinant(basis.metric))()
				or Constant(1)
		end
	end

	local var = range(rank):map(function(i)
		return '_'..(
			basis.symbols 
			and basis.symbols[i]
			or string.char(('a'):byte()-1+i)
		)
	end):concat()
	
	return Tensor(var, function(...)
		local indexes = {...}
		-- duplicates mean 0
		for i=1,#indexes-1 do
			for j=i+1,#indexes do
				if indexes[i] == indexes[j] then return 0 end
			end
		end
		-- bubble sort, count the flips
		local parity = 1
		for i=1,#indexes-1 do
			for j=1,#indexes-i do
				if indexes[j] > indexes[j+1] then
					indexes[j], indexes[j+1] = indexes[j+1], indexes[j]
					parity = -parity
				end
			end
		end
		return (parity * sqrtDetG)()
	end)
end

return makeLeviCivita
