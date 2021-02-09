local class = require 'ext.class'
local Universal = require 'symmath.set.Universal'

local Integer = class(Universal)

local sets
local Constant
function Integer:containsElement(x)
	-- if it isn't a real then it isn't an integer
	sets = sets or require 'symmath.set.sets'
	if sets.real:containsElement(x) == false then 
		return false 
	end

	if self:containsVariable(x) then return true end

	Constant = Constant or require 'symmath.Constant'
	if Constant:isa(x) 
	and type(x.value) == 'number'
	then
		return x.value == math.floor(x.value)
	end
end

return Integer
