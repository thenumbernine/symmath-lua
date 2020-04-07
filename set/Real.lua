local class = require 'ext.class'
local Universal = require 'symmath.set.Universal'
local Set = require 'symmath.set.Set'
local Constant = require 'symmath.Constant'
local complex = require 'symmath.complex'

-- TODO complex as well, and real subset of complex?
-- but then again, about about cartesian products of sets?
-- and what about tensor products of sets?
-- that will require modifying the Set:contains() function

-- TODO what about extended reals vs reals?  ExtendedReals = {+inf, -inf} union Reals

local Real = class(Universal)
	
-- Real.super == Universal
-- Universal.containsElement is true for everything
-- Universal.super == Set
-- Set.containsElement is the default functionality, which resorts to containsVariable

function Real:containsVariable(x)
	return Set.containsVariable(self, x)
end

function Real:containsElement(x)
	local result = Set.containsElement(self, x)
	if result ~= nil then return result end

	if Constant.is(x) then
		if type(x.value) == 'number' then return true end
		if complex.is(x.value) then return self:containsElement(x.value) end
	end

	if complex.is(x) then
		return x.im == 0 
	end
end

return Real
