return function(n)
	local range = require 'ext.range'
	local Matrix = require 'symmath.Matrix'
	return Matrix(
		range(n):map(function(i)
			return range(n):map(function(j)
				return i == j and 1 or 0
			end)
		end):unpack()
	)
end
