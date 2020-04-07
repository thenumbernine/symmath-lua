local class = require 'ext.class'
local Set = require 'symmath.set.Set'

-- the set of all things
local Universal = class(Set)

function Universal:containsElement(x)
	local result = Universal.super.containsElement(self, x) 
	if result ~= nil then return result end
	return true
end

return Universal
