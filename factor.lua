return function(x, ...)
	local applyToAll = require 'symmath.applyToAll'
	return applyToAll('factor', x, ...)
end

