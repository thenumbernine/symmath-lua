local Set = require 'symmath.set.Set'
local symmath

-- TODO IntegerQuotientRingCoset to hold {p n + q}

local OddInteger = Set:subclass()

function OddInteger:isSubsetOf(s)
	symmath = symmath or require 'symmath'
	if OddInteger:isa(s) then return true end
	if symmath.set.integer:isSubsetOf(s) then return true end
end

function OddInteger:containsNumber(x)
	assert(type(x) == 'number')
	symmath = symmath or require 'symmath'
	local isInteger = symmath.set.integer:containsNumber(x)
	if isInteger ~= true then return isInteger end
	return x % 2 == 1
end

local bignumber = require 'bignumber'
function OddInteger:containsBigNumber(x)
	assert(bignumber:isa(x))
	symmath = symmath or require 'symmath'
	local isInteger = symmath.set.integer:containsBigNumber(x)
	if isInteger ~= true then return isInteger end
	return bignumber.__eq(x % 2, 1)
end


return OddInteger
