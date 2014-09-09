--shorthand
local function diff(y, ...)
	local Derivative = require 'symmath.Derivative'
	return Derivative(y, ...)
end
return diff

