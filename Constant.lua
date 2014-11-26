require 'ext'

local Expression = require 'symmath.Expression'

local Constant = class(Expression)

Constant.precedence = 10	-- high since it can't have child nodes 
Constant.name = 'Constant'

function Constant:init(value)
	if type(value) ~= 'number' then
		error('tried to init constant with non-number type '..type(value)..' value '..tostring(value))
	end
	self.value = value
end

function Constant:clone()
	return Constant(self.value)
end

-- this won't be called if a prim is used ...
function Constant.__eq(a,b)
	local va, vb
	if getmetatable(a) == Constant then va = a.value else va = tonumber(a) end
	if getmetatable(b) == Constant then vb = b.value else vb = tonumber(b) end
	return va == vb
end

function Constant:evaluateDerivative(...)
	return Constant(0)
end

function Constant:eval()
	return self.value
end

return Constant

