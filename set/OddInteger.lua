local class = require 'ext.class'
local Integer = require 'symmath.set.Integer'

local OddInteger = class(Integer)

function OddInteger:containsElement(x)
	if not OddInteger.super.containsElement(x) then return false end
	if self:containsVariable(x) then return true end

	local Constant = require 'symmath.Constant'
	if Constant.is(x) then
		return (x.value + 1) / 2 == math.floor((x.value + 1) / 2)
	end
end

return OddInteger

