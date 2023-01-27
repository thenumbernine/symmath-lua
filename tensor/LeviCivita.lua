local range = require 'ext.range'

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
	local abs = require 'symmath.abs'

	local rank
	local chart
	if type(symbol) == 'number' then
		rank = symbol
		sqrtDetG = sqrtDetG or 1
		-- technically this is a member function, but only member to lookup self.chart, then defaults to a global, so...
		chart = Tensor:findChartForSymbol()
	else
		chart = Tensor:findChartForSymbol(symbol or {})
		rank = chart and chart.metric and #chart.metric or #chart.coords

		if not sqrtDetG then
			sqrtDetG = chart and chart.metric
				-- TODO: sqrt(abs(det(metric)))
				and sqrt(abs(Matrix.determinant(chart.metric)))()
				or Constant(1)
		end
	end

	local defaultSymbols = require 'symmath.Tensor'.defaultSymbols
	local variance = ' '..range(rank):mapi(function(i)
		return '_'..(
			chart and chart.symbols and chart.symbols[i]
			or defaultSymbols[i]
			or error("ran out of symbols")
		)
	end):concat' '

	local dim = range(rank):mapi(function() return rank end)

	return Tensor{
		indexes = variance,
		dim = dim,
		values = function(...)
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
			local result = parity * sqrtDetG
			if type(result) == 'number' then
				result = Constant(result)
			else
				result = result()
			end
			return result
		end,
	}
end

return makeLeviCivita
