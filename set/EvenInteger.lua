local Set = require 'symmath.set.Set'
local symmath

--[[
TODO IntegerQuotientRingCoset to hold {p n + q}
for p > 1 in Naturals
for 0 <= q < p in Naturals
--]]

local EvenInteger = Set:subclass()

function EvenInteger:isSubsetOf(s)
	symmath = symmath or require 'symmath'
	if EvenInteger:isa(s) then return true end
	if symmath.set.integer:isSubsetOf(s) then return true end
end

function EvenInteger:containsNumber(x)
	assert(type(x) == 'number')
	symmath = symmath or require 'symmath'
	-- if it is not an integer then fail
	local isInteger = symmath.set.integer:containsNumber(x)
	if isInteger ~= true then return isInteger end
	return x % 2 == 0
end

return EvenInteger
