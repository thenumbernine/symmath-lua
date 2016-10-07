local class = require 'ext.class'
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

Constant.visitorHandler = {
	Eval = function(eval, expr)
		return expr.value
	end,

	Tidy = function(tidy, expr)
		local unmOp = require 'symmath.unmOp'
		
		-- for formatting's sake ...
		if expr.value == 0 then	-- which could possibly be -0 ...
			return Constant(0)
		end
		
		-- -c => -(c)
		if expr.value < 0 then
			return tidy:apply(unmOp(Constant(-expr.value)))
		end
	end,
}

return Constant
