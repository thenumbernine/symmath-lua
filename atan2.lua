local class = require 'ext.class'
local Function = require 'symmath.Function'

local atan2 = class(Function)
atan2.name = 'atan2'
atan2.func = math.atan2

function atan2:evaluateDerivative(...)
	local y, x = table.unpack(self)
	y, x = y:clone(), x:clone()
	local diff = require 'symmath.Derivative'
	return diff(y/x, ...) / (1 + (y/x)^2)
end

function atan2:reverse(soln, index)
	local tan = require 'symmath.tan'
	-- atan2(y,x) ~ atan(y/x) and then some
	local y, x = table.unpack(self)
	-- z = atan(y(q)/x) => y(q) = x tan(z)
	if index == 1 then
		return tan(soln) * x
	-- z = atan(y/x(q)) => x(q) = y / tan(z)
	elseif index == 2 then
		return y / tan(soln)
	end
end

return atan2
