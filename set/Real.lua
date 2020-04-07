local class = require 'ext.class'
local Universal = require 'symmath.set.Universal'

-- TODO complex as well, and real subset of complex?
-- but then again, about about cartesian products of sets?
-- and what about tensor products of sets?
-- that will require modifying the Set:contains() function

-- TODO what about extended reals vs reals?  ExtendedReals = {+inf, -inf} union Reals

local Real = class(Universal)

function Real:containsElement(x)
	local result = Real.super.containsElement(self, x) 
	if result ~= nil then return result end
	
	if Constant.is(x) and type(x.value) == 'number' then return true end
end

return Real
