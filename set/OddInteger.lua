local class = require 'ext.class'
local Integer = require 'symmath.set.Integer'

local OddInteger = class(Integer)

function OddInteger:containsElement(x)
	if OddInteger.super.containsElement(self, x) == false then return false end
	if self:containsVariable(x) then return true end

	local Constant = require 'symmath.Constant'
	if Constant:isa(x) then
		return (x.value + 1) / 2 == math.floor((x.value + 1) / 2)
	end
end

return OddInteger
