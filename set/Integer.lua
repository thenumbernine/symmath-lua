local class = require 'ext.class'
local Real = require 'symmath.set.Real'

local Integer = class(Real)

function Integer:containsElement(x)
	-- if it isn't a real then it isn't an integer
	local result = Integer.super.containsElement(self, x) 
	if result == false then return false end

	if self:containsVariable(x) then return true end

	local Constant = require 'symmath.Constant'
	if Constant.is(x) 
	and type(x.value) == 'number'
	then
		return x.value == math.floor(x.value)
	end
end

return Integer
