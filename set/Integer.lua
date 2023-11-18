local Set = require 'symmath.set.Set'
local symmath

--[[
TODO subclass of Real?  just like EvenInteger is subclass of Integer
but Real itself isn't a class.
real is an instance of RealSubset of (-inf, inf)
but idk if the Integer set should possess all behavior of RealSubset
esp the operators

how about a separate Real class,
which always contains any RealSubset / RealInterval
--]]
local Integer = Set:subclass()

function Integer:isSubsetOf(s)
	symmath = symmath or require 'symmath'
	if Integer:isa(s) then return true end
	if symmath.set.real:isSubsetOf(s) then return true end
end

function Integer:containsNumber(x)
	assert(type(x) == 'number')

	-- if it isn't a real then it isn't an integer
	-- TODO make a class for Real based on RealSubset(-huge,huge) ?
	symmath = symmath or require 'symmath'
	local isReal = symmath.set.real:containsNumber(x)
	if isReal ~= true then return isReal end

	if x == math.floor(x) then return true end
end

local bignumber = require 'bignumber'
function Integer:containsBigNumber(x)
	assert(bignumber:isa(x))
	symmath = symmath or require 'symmath'
	local isReal = symmath.set.real:containsBigNumber(x)
	if isReal ~= true then return isReal end
	if x == x:floor() then return true end
end

return Integer
