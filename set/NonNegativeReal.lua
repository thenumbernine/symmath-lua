local class = require 'ext.class'
local Real = require 'symmath.set.Real'
local Set = require 'symmath.set.Set'
local Constant = require 'symmath.Constant'

local NonNegativeReal = class(Real)

function NonNegativeReal:containsVariable(x)
	-- if x is a Real and it has a >= 0 value then return true
	-- make sure Real: so it doesn't use NonNegReal's metatable
	local isReal = Real:containsVariable(x)
	if isReal == false then return false end
	if isReal == true then
		if x.value
		and type(x.value) == 'number'
		then
			return x.value >= 0
		end
	end

	if Set.containsVariable(self, x) then return true end
end

function NonNegativeReal:containsElement(x)
	if NonNegativeReal.super.containsElement(self, x) == false then return false end

	if self:containsVariable(x) then return true end

	if Constant.is(x) 
	and type(x.value) == 'number'
	then
		return x.value >= 0
	end

	-- |(x^n)| = x^n for n even and x real
	if symmath.op.pow.is(x)
	and require 'symmath.set.Real':contains(x[1])
	and require 'symmath.set.EvenInteger':contains(x[2])
	then
		return true
	end
end

return NonNegativeReal 
