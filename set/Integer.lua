local class = require 'ext.class'
local Universal = require 'symmath.set.Universal'

local Integer = class(Universal)

function Integer:containsElement(x)
	-- if it isn't a real then it isn't an integer
	if require 'symmath.set.sets'.real:containsElement(x) == false then 
		return false 
	end

	if self:containsVariable(x) then return true end

	local Constant = require 'symmath.Constant'
	if Constant.is(x) 
	and type(x.value) == 'number'
	then
		return x.value == math.floor(x.value)
	end
end

return Integer
