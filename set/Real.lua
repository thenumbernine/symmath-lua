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

function Real:interval(start, finish)
	return require 'symmath.set.RealInterval'(start, finish)
end

-- Real.super == Universal
-- Universal.containsElement is true for everything
-- Universal.super == Set
-- Set.containsElement is the default functionality, which resorts to containsVariable

function Real:containsVariable(x)
	return Set.containsVariable(self, x)
end

function Real:containsElement(x)
	local symmath = require 'symmath'
	local NonNegativeReal = symmath.set.NonNegativeReal
	
	local result = Set.containsElement(self, x)
	if result ~= nil then return result end

	if Constant.is(x) then
		if type(x.value) == 'number' then return true end
		if complex.is(x.value) then return self:containsElement(x.value) end
	end

	if complex.is(x) then
		return x.im == 0 
	end

	if symmath.op.unm.is(x)
	and Real:containsElement(x[1])
	then
		return true
	end

	if symmath.op.add.is(x) then
		local fail
		for i=1,#x do
			if Real:containsElement(x[i]) ~= true then
				fail = true
				break
			end
		end
		if not fail then return true end
	end

	if symmath.op.mul.is(x) then
		local fail
		for i=1,#x do
			if Real:containsElement(x[i]) ~= true then
				fail = true
				break
			end
		end
		if not fail then return true end
	end

	if symmath.op.pow.is(x) then
		-- c^x >= 0 for x real and c >= 0
		if NonNegativeReal:containsElement(x[1])
		and Real:containsElement(x[2])
		then
			return true
		end
	end
	
	if symmath.abs.is(x) and Real:containsElement(x[1]) then return true end
	if symmath.sqrt.is(x) and NonNegativeReal:containsElement(x[1]) then return true end
	--if symmath.log.is(x) and x[1] is PositiveReal then return true end
	if symmath.sin.is(x) and Real:containsElement(x[1]) then return true end
	if symmath.cos.is(x) and Real:containsElement(x[1]) then return true end
	-- if symmath.tan.is(x) and Real:containsElement(x[1]) and x[1] is not pi/2 + pi*k for k in Integer then return true end
	-- if symmath.asin.is(x) and x Real in [-1,1] then return true end
	-- if symmath.acos.is(x) and x Real in [-1,1] then return true end
	if symmath.atan.is(x) and Real:containsElement(x[1]) then return true end
	if symmath.sinh.is(x) and Real:containsElement(x[1]) then return true end
	if symmath.cosh.is(x) and Real:containsElement(x[1]) then return true end
	if symmath.tanh.is(x) and Real:containsElement(x[1]) then return true end
	if symmath.asinh.is(x) and Real:containsElement(x[1]) then return true end
	--if symmath.acosh.is(x) and x Real in [1,inf) then return true end
	--if symmath.atanh.is(x) and x Real in [-1,1] then return true end
end

return Real
