local class = require 'ext.class'
local Expression = require 'symmath.Expression'

local Invalid = class(Expression)
Invalid.name = 'Invalid'

-- true to NaNs
function Invalid.__eq(a,b)
	return false
end

function Invalid:evaluateDerivative(...)
	return self
end

Invalid.visitorHandler = {
	Eval = function(eval, expr)
		return 0/0
	end,
}

return Invalid
