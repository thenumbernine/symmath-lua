require 'ext'

local Expression = require 'symmath.Expression'

Invalid = class(Expression)

Invalid.name = 'Invalid'

-- true to NaNs
function Invalid.__eq(a,b)
	return false
end

function Invalid:evaluateDerivative(...)
	return self
end

return Invalid

