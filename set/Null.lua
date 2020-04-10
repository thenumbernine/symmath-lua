local class = require 'ext.class'
local Set = require 'symmath.set.Set'

local Null = class(Set)
Null.name = 'Null'

-- is the null set a subset of itself? 
-- can a variable be defined to exist in the null set?
function Null:variable(...)
	error"you cannot create a variable from the null set"
end

function Null:containsVariable(s)
	return false
end

function Null:containsElement(s)
	return false
end

return Null
