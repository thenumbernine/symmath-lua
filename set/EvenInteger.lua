local class = require 'ext.class'
local Integer = require 'symmath.set.Integer'

local EvenInteger = class(Integer)

local Constant
function EvenInteger:containsElement(x)
	if EvenInteger.super.containsElement(self, x) == false then return false end
	if self:containsVariable(x) then return true end

	Constant = Constant or require 'symmath.Constant'
	if Constant:isa(x) then
		return x.value / 2 == math.floor(x.value / 2)
	end
end

return EvenInteger
