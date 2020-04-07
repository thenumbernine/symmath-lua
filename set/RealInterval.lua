local class = require 'ext.class'

local Real = require 'symmath.set.Real'

local RealInterval = class(Real)

RealInterval.start = start or -math.huge
RealInterval.finish = finish or math.huge

function RealInterval:init(start, finish)
	self.start = start
	self.finish = finish
end

function RealInterval:containsNumber(x)
	return self.start <= x and x <= self.finish
end

function RealInterval:containsVariable(x)
	local result = Real.containsVariable(self, x) 
	if result ~= true then return result end
	if x.value then return self:containsNumber(x.value) end
	if x.set then return self:containsSet(x.set) end
end

function RealInterval:containsSet(s)
	if RealInterval.is(s) then
		return self.start <= s.start and s.finish <= self.finish
	end
	if Real.is(s) then
		return self.start <= -math.huge and math.huge <= self.finish
	end
end

function RealInterval:containsElement(x)
	local result = Real.containsElement(self, x)
	if result ~= true then return result end
	
	-- this function is specific to each function -- maybe make it a member?
	-- but for now it is only used here, so only keep it here
	local start, finish = self:getExprRealInterval(x)
	if self.start <= start and finish <= self.finish then return true end
	if finish < self.start then return false end
	if self.finish < start then return false end
end

-- function for telling the interval of arbitrary expressions
-- NOTICE only call this on x such that Real:containsElement(x)
function RealInterval:getExprRealInterval(x)
	local symmath = require 'symmath'
	
	if symmath.Variable.is(x) then
		local set = x.set
		if RealInterval.is(set) then
			return set.start, set.finish
		end
		if Real.is(set) then return -math.huge, math.huge end
	end

	if Constant.is(x) then
		if type(x.value) == 'number' then return x.value, x.value end
		if complex.is(x.value) then return self:getExprRealInterval(x.value) end
	end

	if complex.is(x) 
	and x.im == 0
	then
		return x.re, x.re
	end

	if symmath.op.unm.is(x) 
	-- and Real:containsElement(x[1])
	then
		local start, finish = self:getExprRealInterval(x[1])
		if start == nil then return end
		return -finish, -start
	end

	-- [a,b] + [c,d] = [a+c,b+d]
	if symmath.op.add.is(x) then
		local start, finish = self:getExprRealInterval(x[1])
		if start == nil then return end
		for i=2,#x do
			local start2, finish2 = self:getExprRealInterval(x[i])
			if start2 == nil then return end
			start, finish = start + start2, finish + finish2
		end
		return start, finish
	end

	if symmath.op.mul.is(x) then
		--[[
		[a,b] * [c,d] ...
		
		= [a*c, b*d] for 0 <= a <= b and 0 <= c <= d
		= [a*d, b*c] for a <= b <= 0 and 0 <= c <= d
		= [b*c, a*d] for 0 <= a <= b and c <= d <= 0
		= [b*d, a*c] for a <= b <= 0 and c <= d <= 0
		
		for a <= 0 <= b and 0 <= c <= d it is 
			union of [a,0] * [c,d] and [0,b] * [c,d]
			= union of [a*d, 0*c] and [0*c, b*d]
			= [a*d, b*d]
		
		for a <= 0 <= b and c <= d <= 0 it is
			[c*b, c*a]
		
		for a <= 0 <= b and c <= 0 <= d it is
			union of [a,b]*[c,0] = [c*b, c*a]
				and [a,b]*[0,d] = [a*d, b*d]
		...
		--]]	
		local function mulInterval(start, finish, start2, finish2) 
			if 0 <= start and 0 <= start then
				return start*start2, finish*finish2
			elseif finish <= 0 and 0 <= start2 then
				return start*finish2, finish*start2
			elseif 0 <= start and finish2 <= 0 then
				return finish*start2, start*finish2
			elseif finish <= 0 and finish2 <= 0 then
				return finish*finish2, start*start2
			elseif start <= 0 and 0 <= finish and 0 <= start2 then
				return start*finish2, finish*finish2
			elseif start <= 0 and 0 <= finish and finish2 <= 0 then
				return start2*finish, start2*start
			elseif start2 <= 0 and 0 <= finish2 and 0 <= start then
				return start2*finish, finish2*finish
			elseif start2 <= 0 and 0 <= finish2 and finish <= 0 then
				return start*finish2, start*start2
			elseif start2 <= 0 and 0 <= finish2 and start <= 0 and 0 <= finish then
				return math.min(a*d, b*c), math.max(a*c, b*d)
			else
				error'here'
			end
		end
		local start, finish = self:getExprRealInterval(x[1])
		if start == nil then return end
		for i=2,#x do
			local start2, finish2 = self:getExprRealInterval(x[i])
			if start2 == nil then return end
			start, finish = mulInterval(start, finish, start2, finish2)
		end
		return start, finish
	end

	if symmath.op.pow.is(x) then
		local start, finish = self:getExprRealInterval(x[1])
		if start == nil then return end
		local start2, finish2 = self:getExprRealInterval(x[2])
		if start2 == nil then return end
		return -math.huge, math.huge
		
		-- (1,inf)^(1,inf) = (1,inf)	increasing
		-- (1,inf)^(0,1) = (1,inf)		decreasing
		-- (1,inf)^0 = 1
		-- (1,inf)^(-inf,0) = (0,1)
		-- (0,1)^(1,inf) = (0,1)		decreasing
		-- (0,1)^

		-- (0,inf)^(0,inf) = (1,inf)
		-- (0,inf)^0 = 1
		-- (0,inf)^(-inf,0) = (0,1)
		-- 0^0 = 1
		-- (-inf,0)^(pos and even) = (0,inf)
		-- (-inf,0)^(pos and odd) = (-inf,0)
		--
	end

	-- (-inf,inf) even, increasing from zero
	if symmath.abs.is(x) then
		local start, finish = self:getExprRealInterval(x[1])
		if start == nil then return end
		-- even function
		if finish <= 0 then
			return math.abs(finish), math.abs(start)
		elseif start <= 0 and 0 <= finish then
			return math.abs(0), math.max(math.abs(start), math.abs(finish))
		elseif 0 <= start then
			return math.abs(start), math.abs(finish)
		end
	end
	-- (-inf,inf) even, increasing from zero
	if symmath.cosh.is(x) then
		local start, finish = self:getExprRealInterval(x[1])
		if start == nil then return end
		-- even function
		if finish <= 0 then
			return math.cosh(finish), math.cosh(start)
		elseif start <= 0 and 0 <= finish then
			return math.cosh(0), math.max(math.cosh(start), math.cosh(finish))
		elseif 0 <= start then
			return math.cosh(start), math.cosh(finish)
		end
	end

	-- (0,inf) increasing, (-inf,0) imaginary
	if symmath.sqrt.is(x) 
	or symmath.log.is(x)
	then
		local start, finish = self:getExprRealInterval(x[1])
		if start == nil then return end
		if start < 0 then return end
		return x.func(start).re, x.func(finish).re
	end

	-- (-inf,inf) => (-1,1)
	-- TODO you can map this by quadrant
	if symmath.sin.is(x) 
	or symmath.cos.is(x)
	then
		local start, finish = self:getExprRealInterval(x[1])
		if start == nil then return end
		return -1, 1
	end

	-- (-inf,inf) => (-inf,inf) increasing periodic
	if symmath.tan.is(x) 
	or symmath.atan.is(x)
	then
		local start, finish = self:getExprRealInterval(x[1])
		if start == nil then return end
		-- TODO once again, this can be chopped up by half-circles
		return -math.huge, math.huge
	end

	-- (-1,1) => (-inf,inf) increasing, (-inf,-1) and (1,inf) imaginary
	if symmath.asin.is(x) 
	or symmath.atanh.is(x)
	then
		local start, finish = self:getExprRealInterval(x[1])
		if start == nil then return end
		-- not real
		if start < -1 or 1 < finish then return end
		return x.func(start).re, x.func(finish).re
	end

	-- (-1,1) => (-inf,inf) decreasing, (-inf,-1) and (1,inf) imaginary
	if symmath.acos.is(x) then
		local start, finish = self:getExprRealInterval(x[1])
		if start == nil then return end
		-- not real
		if start < -1 or 1 < finish then return end
		return math.acos(finish), math.acos(start)
	end
	
	-- increasing
	if symmath.sinh.is(x)
	or symmath.tanh.is(x)
	or symmath.asinh.is(x)
	then
		local start, finish = self:getExprRealInterval(x[1])
		if start == nil then return end
		return x.func(start).re, x.func(finish).re
	end

	-- (1,inf) increasing, (-inf,1) imaginary
	if symmath.acosh.is(x) then
		local start, finish = self:getExprRealInterval(x[1])
		if start == nil then return end
		if start < 1 then return end
		return x.func(start).re, x.func(finish).re
	end


end

return RealInterval 
