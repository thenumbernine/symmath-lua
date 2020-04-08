local class = require 'ext.class'

local Real = require 'symmath.set.Real'

local RealInterval = class(Real)

RealInterval.start = start or -math.huge
RealInterval.finish = finish or math.huge
RealInterval.includeStart = false
RealInterval.includeFinish = false

function RealInterval:init(start, finish, includeStart, includeFinish)
	self.start = start
	self.finish = finish
	self.includeStart = includeStart
	self.includeFinish = includeFinish
	if self.start == -math.huge or self.start == math.huge then self.includeStart = false end
	if self.finish == -math.huge or self.finish == math.huge then self.includeFinish = false end
end

function RealInterval:__tostring()
	return (self.includeStart and '[' or '(')
		.. self.start
		.. ', '
		.. self.finish
		.. (self.includeFinish and ']' or ')')
end

-- TODO add in PositiveReals, NonPositiveReals, and NegativeReals all as RealIntervals
-- TODO add in Rational, Irrational, Transcendental sets, and do similar function mapping stuff below for them too (IntegerInterval, Natural=IntegerInterval(0,inf), RationalInterval, IrrationalInteral, TranscendentalInterval, etc)
--   (I'm suspicious that I'm going to need to start associating each expression with its domain/range)

function RealInterval:containsNumber(x)
	local result = true
	if self.includeStart then
		result = result and self.start <= x
	else
		result = result and self.start < x
	end
	if self.includeFinish then
		result = result and x <= self.finish
	else
		result = result and x < self.finish
	end
	return result
end

function RealInterval:containsVariable(x)
	local result = Real.containsVariable(self, x) 
	if result ~= true then return result end
	if x.value then return self:containsNumber(x.value) end
	if x.set then 
		-- right now :containsSet returns nil if the domains are overlapping
		-- in that case, the variable *could* be inside 'self'
		return self:containsSet(x.set) 
	end
end

function RealInterval:containsSet(I)
	if RealInterval.is(I) or getmetatable(I) == Real then
		local result = true
		
		if self.includeStart and I.includeStart then
			-- does [a,... contain [b,...
			result = result and self.start <= I.start
		elseif self.includeStart and not I.includeStart then
			-- does [a,... contain (b,...
			result = result and self.start <= I.start
		elseif not self.includeStart and I.includeStart then
			-- does (a,... contain [b,...
			result = result and self.start < I.start
		elseif not self.includeStart and not I.includeStart then
			-- does (a,... contain (b,...
			result = result and self.start <= I.start
		end
		
		if self.includeFinish and I.includeFinish then
			-- does ...,a] contain ...,b]
			result = result and I.finish <= self.finish
		elseif self.includeFinish and not I.includeFinish then
			-- does ...,a] contain ...,b)
			result = result and I.finish <= self.finish
		elseif not self.includeFinish and I.includeFinish then
			-- does ...,a) contain ...,b]
			result = result and I.finish < self.finish
		elseif not self.includeFinish and not I.includeFinish then
			-- does ...,a) contain ...,b)
			result = result and I.finish <= self.finish
		end
		
		if result == true then return true end
		
		if I.finish < self.start then return false end
		if self.finish < I.start then return false end

		-- by here the two sets are overlapping but I isn't contained in self
		-- so technically 'containsSet' is false
		-- but right now :containsVariable is calling this
		-- and containsVariable wants to return nil when the sets overlap
		-- and I'm too lazy to write a separate :touchesSet function
	end
end

function RealInterval:containsElement(x)
	local result = Real.containsElement(self, x)
	if result ~= true then return result end
	
	-- this function is specific to each function -- maybe make it a member?
	-- but for now it is only used here, so only keep it here
	local I = self:getExprRealInterval(x)
	if I == nil then return end
	if self:containsSet(I) then return true end
end

-- ops might break my use of classes as singletons, since classes don't have the same op metatable as objects

function RealInterval.__unm(I)
	return RealInterval(-I.finish, -I.start, I.includeFinish, I.includeStart)
end

-- [a,b] + [c,d] = [a+c,b+d]
function RealInterval.__add(A,B)
	return RealInterval(
		A.start + B.start,
		A.finish + B.finish,
		A.includeStart or B.includeStart,
		A.includeFinish or B.includeFinish)
end

-- [a,b] - [c,d] = [a-d, b-c]
function RealInterval.__sub(A,B)
	return RealInterval(
		A.start - B.finish,
		A.finish - B.start,
		A.includeStart or B.includeFinish,
		A.includeFinish or B.includeStart)
end

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
function RealInterval.__mul(A,B)
	if 0 <= A.start and 0 <= B.start then
		return RealInterval(
			A.start * B.start,
			A.finish * B.finish,
			A.includeStart and B.includeStart,
			A.includeFinish and B.includeFinish
		)
	elseif A.finish <= 0 and 0 <= B.start then
		return RealInterval(
			A.start * B.finish,
			A.finish * B.start,
			A.includeStart and B.includeFinish,
			A.includeFinish and B.includeStart
		)
	elseif 0 <= A.start and B.finish <= 0 then
		return RealInterval(
			A.finish * B.start,
			A.start * B.finish,
			A.includeFinish and B.includeStart,
			A.includeStart and B.includeFinish
		)
	elseif A.finish <= 0 and B.finish <= 0 then
		return RealInterval(
			A.finish * B.finish,
			A.start * B.start,
			A.includeFinish and B.includeFinish,
			A.includeStart and B.includeStart
		)
	elseif A.start <= 0 and 0 <= A.finish and 0 <= B.start then
		return RealInterval(
			A.start * B.finish,
			A.finish * B.finish,
			A.includeStart and B.includeFinish,
			A.includeFinish and B.includeFinish
		)
	elseif A.start <= 0 and 0 <= A.finish and B.finish <= 0 then
		return RealInterval(
			B.start * A.finish,
			B.start * A.start,
			A.includeFinish and B.includeStart,
			A.includeStart and B.includeStart
		)
	elseif B.start <= 0 and 0 <= B.finish and 0 <= A.start then
		return RealInterval(
			B.start * A.finish,
			B.finish * A.finish,
			A.includeFinish and B.includeStart,
			A.includeFinish and B.includeFinish
		)
	elseif B.start <= 0 and 0 <= B.finish and A.finish <= 0 then
		return RealInterval(
			A.start * B.finish,
			A.start * B.start,
			A.includeStart and B.includeFinish,
			A.includeStart and B.includeStart
		)
	elseif B.start <= 0 and 0 <= B.finish and A.start <= 0 and 0 <= A.finish then
		local AstartBfinish = A.start * B.finish
		local AfinishBstart = A.finish * B.start
		local AstartBstart = A.start * B.start
		local AfinishBfinish = A.finish * B.finish
		local includeStart
		if AstartBfinish < AfinishBstart then
			includeStart = A.includeStart and B.includeFinish
		else
			includeStart = A.includeFinish and B.includeStart
		end
		local includeFinish
		if AstartBstart < AfinishBfinish then
			includeFinish = A.includeStart and B.includeStart
		else
			includeFinish = A.includeFinish and B.includeFinish
		end
		return RealInterval(
			math.min(AstartBfinish, AfinishBstart),
			math.max(AstartBstart, AfinishBfinish),
			includeStart,
			includeFinish
		)
	else
		error'here'
	end
end

--[[
[a,b] / [c,d] => 
for 0 <= c <= d this is the same as [a,b] * [1/d, 1/c] = [a/d, b/c]
for c <= d <= 0 this is the same as [a,b] * [1/d, 1/c] = [b/d, a/c]
for c <= 0 <= d this is the same as
 [a,b] * ((-inf,1/c] union [1/d,inf))
 = [a,b] * (-inf,1/c] union [a,b] * [1/d,inf)
this brings us to the world of separate contiguous domains ...
--]]
function RealInterval.__div(A,B)
	if 0 <= A.start and 0 <= B.start then
		return A * RealInterval(1/B.finish, 1/B.start, B.includeFinish, B.includeStart)
	elseif 0 <= A.start and B.finish <= 0 then
		return A * RealInterval(1/B.finish, 1/B.start, B.includeFinish, B.includeStart)
	
	elseif A.finish <= 0 and 0 <= B.start then
		return A * RealInterval(1/B.finish, 1/B.start, B.includeFinish, B.includeStart)
	elseif A.finish <= 0 and B.finish <= 0 then
		return A * RealInterval(1/B.finish, 1/B.start, B.includeFinish, B.includeStart)
	
	elseif A.start <= 0 and 0 <= A.finish and 0 <= B.start then
		return A * RealInterval(1/B.finish, 1/B.start, B.includeFinish, B.includeStart)
	elseif A.start <= 0 and 0 <= A.finish and B.finish <= 0 then
		return A * RealInterval(1/B.finish, 1/B.start, B.includeFinish, B.includeStart)
	
	elseif 0 <= A.start and B.start <= 0 and 0 <= B.finish then
		return RealInterval(-math.huge, math.huge)
	elseif A.finish <= 0 and B.start <= 0 and 0 <= B.finish then
		return RealInterval(-math.huge, math.huge)
	
	elseif A.start <= 0 and 0 <= A.finish and B.start <= 0 and 0 <= B.finish then
		return RealInterval(-math.huge, math.huge)
	else
		error'here'
	end
end

--[[
(1,inf)^(1,inf) = (1,inf)	increasing
(1,inf)^(0,1) = (1,inf)		decreasing
(1,inf)^0 = 1
(1,inf)^(-inf,0) = (0,1)
(0,1)^(1,inf) = (0,1)		decreasing
(0,1)^

(0,inf)^(0,inf) = (1,inf)
(0,inf)^0 = 1
(0,inf)^(-inf,0) = (0,1)
0^0 = 1
(-inf,0)^(pos and even) = (0,inf)
(-inf,0)^(pos and odd) = (-inf,0)

... what ranges are nan ranges for reals?
fractional (even denominator) powers of negative numbers make complex
fractional (odd denominator) powers of negative numbers make real
--]]
function RealInterval.__pow(A,B)
	return RealInterval(-math.huge, math.huge)
end

-- function for telling the interval of arbitrary expressions
-- NOTICE only call this on x such that Real:containsElement(x)
-- hmm, this could also be renamed 'getRealDomain' ...
-- I could call it 'getDomain' - give it to all Expressions - and just have expressions return RealInterval objects when their input is RealInterval objects
--	but if I generalized it then I might need to also include support for ComplexDomain ... that might be tough
function RealInterval:getExprRealInterval(x)
	local symmath = require 'symmath'
	
	if symmath.Variable.is(x) then
		local set = x.set
		
		if RealInterval.is(set) then return set end
		
		-- assuming start and finish are defined in all Real's subclasses
		-- what about Integer?  Integer is a subst of Real, but its RealInterval is discontinuous ...
		--if Real.is(set) then return set end
		-- so for now I'll only accept Real itself
		if getmetatable(set) == Real then return set end
	end

	if Constant.is(x) then
		if type(x.value) == 'number' then
			-- should a Constant's domain be the single value of the constant?
			return RealInterval(x.value, x.value, true, true)
		end
		if complex.is(x.value) then 
			return self:getExprRealInterval(x.value) 
		end
	end

	if complex.is(x) then
		if x.im ~= 0 then return end
		return RealInterval(x.re, x.re, true, true)
	end

	if symmath.op.unm.is(x) 
	-- and Real():containsElement(x[1])
	then
		local I = self:getExprRealInterval(x[1])
		if I == nil then return end
		return -I
	end

	if symmath.op.add.is(x) then
		local I = self:getExprRealInterval(x[1])
		if I == nil then return end
		for i=2,#x do
			local I2 = self:getExprRealInterval(x[i])
			if I2 == nil then return end
			I = I + I2
		end
		return I
	end

	if symmath.op.sub.is(x) then
		local I = self:getExprRealInterval(x[1])
		if I == nil then return end
		for i=2,#x do
			local I2 = self:getExprRealInterval(x[i])
			if I2 == nil then return end
			I = I - I2
		end
		return I
	end

	if symmath.op.mul.is(x) then
		local I = self:getExprRealInterval(x[1])
		if I == nil then return end
		for i=2,#x do
			local I2 = self:getExprRealInterval(x[i])
			if I2 == nil then return end
			I = I * I2
		end
		return I
	end

	if symmath.op.div.is(x) then
		local I = self:getExprRealInterval(x[1])
		if I == nil then return end
		local I2 = self:getExprRealInterval(x[2])
		if I2 == nil then return end
		return I / I2
	end

	if symmath.op.pow.is(x) then
		local I = self:getExprRealInterval(x[1])
		if I == nil then return end
		local I2 = self:getExprRealInterval(x[2])
		if I2 == nil then return end
		return I ^ I2
	end

	-- (-inf,inf) even, increasing from zero
	if symmath.abs.is(x) 
	or symmath.cosh.is(x)
	then
		local I = self:getExprRealInterval(x[1])
		if I == nil then return end
		if I.finish <= 0 then
			return RealInterval(
				x.realFunc(I.finish),
				x.realFunc(I.start),
				I.includeFinish,
				I.includeStart
			)
		elseif I.start <= 0 and 0 <= I.finish then
			local fStart = x.realFunc(I.start)
			local fFinish = x.realFunc(I.finish)
			local finish
			local includeFinish
			if fStart < fFinish then
				finish = fFinish
				includeFinish = I.includeFinish
			else
				finish = fStart
				includeFinish = I.includeStart
			end
			return RealInteral(
				x.realFunc(0),
				finish,
				true,
				includeFinish
			)
		elseif 0 <= I.start then
			return RealInterval(
				x.realFunc(I.start),
				x.realFunc(I.finish),
				I.includeStart,
				I.includeFinish
			)
		end
	end

	-- (0,inf) increasing, (-inf,0) imaginary
	if symmath.sqrt.is(x) 
	or symmath.log.is(x)
	then
		local I = self:getExprRealInterval(x[1])
		if I == nil then return end
		if I.start < 0 then return end
		return RealInterval(
			x.realFunc(I.start),
			x.realFunc(I.finish),
			I.includeStart,
			I.includeFinish
		)
	end

	-- (-inf,inf) => (-1,1)
	-- TODO you can map this by quadrant
	if symmath.sin.is(x) 
	or symmath.cos.is(x)
	then
		local I = self:getExprRealInterval(x[1])
		if I == nil then return end
		return RealInterval(-1, 1, true, true)
	end

	-- (-inf,inf) => (-inf,inf) increasing periodic
	if symmath.tan.is(x) 
	or symmath.atan.is(x)
	then
		local I = self:getExprRealInterval(x[1])
		if I == nil then return end
		-- TODO once again, this can be chopped up by half-circles
		return RealInterval(-math.huge, math.huge)
	end

	-- (-1,1) => (-inf,inf) increasing, (-inf,-1) and (1,inf) imaginary
	if symmath.asin.is(x) 
	or symmath.atanh.is(x)
	then
		local I = self:getExprRealInterval(x[1])
		if I == nil then return end
		-- not real
		if I.start < -1 or 1 < I.finish then return end
		return RealInterval(
			x.realFunc(I.start),
			x.realFunc(I.finish),
			I.includeStart,
			I.includeFinish
		)
	end

	-- (-1,1) => (-inf,inf) decreasing, (-inf,-1) and (1,inf) imaginary
	if symmath.acos.is(x) then
		local I = self:getExprRealInterval(x[1])
		if I == nil then return end
		-- not real
		if I.start < -1 or 1 < I.finish then return end
		return RealInterval(
			math.acos(I.finish),
			math.acos(I.start),
			I.includeFinish,
			I.includeStart
		)
	end
	
	-- increasing
	if symmath.sinh.is(x)
	or symmath.tanh.is(x)
	or symmath.asinh.is(x)
	then
		local I = self:getExprRealInterval(x[1])
		if I == nil then return end
		return RealInterval(
			x.realFunc(I.start),
			x.realFunc(I.finish),
			I.includeStart,
			I.includeFinish
		)
	end

	-- (1,inf) increasing, (-inf,1) imaginary
	if symmath.acosh.is(x) then
		local I = self:getExprRealInterval(x[1])
		if I == nil then return end
		if I.start < 1 then return end
		return RealInterval(
			x.realFunc(I.start),
			x.realFunc(I.finish),
			I.includeStart,
			I.includeFinish
		)
	end
end

return RealInterval 
