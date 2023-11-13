local Set = require 'symmath.set.Set'
local symmath

local Natural = Set:subclass()

function Natural:isSubsetOf(s)
	symmath = symmath or require 'symmath'
	if Natural:isa(s) then return true end
	if symmath.set.integer:isSubsetOf(s) then return true end
end

function Natural:containsNumber(x)
	assert(type(x) == 'number')
	symmath = symmath or require 'symmath'
	-- if it isn't an integer then it isn't a natural
	local isInteger = symmath.integer:containsNumber(x)
	if isInteger ~= true then return isInteger end
	-- TODO instead define positiveInteger and nonNegativeInteger
	-- and just make this a reference to one or the other, depending on the user's preference
	-- and TODO don't ever reference set.natural in our code, only use positiveInteger or nonNegativeInteger
	return x > 0
end

return Natural
