require 'ext'

local Expression = require 'symmath.Expression'

Invalid = class(Expression)

Invalid.name = 'Invalid'

-- true to NaNs
function Invalid.__eq(a,b)
	return false
end

function Invalid:diff(...)
	return self
end

function Invalid:eval()
	return 0/0	--nan
end

return Invalid

