local class = require 'ext.class'
local Integer = require 'symmath.set.Integer'

local EvenInteger = class(Integer)

function EvenInteger:containsElement(x)
	local result = EvenInteger.super.containsElement(self, x) 
	if result ~= nil then return result end
	
	if self:containsVariable(x) then return true end

	local Constant = require 'symmath.Constant'
	if Constant.is(x) then
		return x.value / 2 == math.floor(x.value / 2)
	end
end

return EvenInteger
