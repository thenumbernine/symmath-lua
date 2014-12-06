require 'ext'
return function(n)
	return require 'symmath.Matrix'(
		range(n):map(function(i)
			return range(n):map(function(j)
				return i == j and 1 or 0
			end)
		end):unpack()
	)
end
