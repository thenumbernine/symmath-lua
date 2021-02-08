local class = require 'ext.class'
local math = require 'ext.math'
local Universal = require 'symmath.set.Universal'
local complex = require 'symmath.complex'

-- in some places I'm using subclasses to represent subsets ...
local RealInterval = class(Universal)

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
	if math.isnan(self.start) or math.isnan(self.finish) then
		error('tried to construct a RealInterval with nan bounds:\n'
				..require'ext.tolua'(self))
	end
end

function RealInterval:clone()
	return RealInterval(
		self.start,
		self.finish,
		self.includeStart,
		self.includeFinish)
end

function RealInterval:__tostring()
	return (self.includeStart and '[' or '(')
		.. self.start
		.. ', '
		.. self.finish
		.. (self.includeFinish and ']' or ')')
end

-- TODO add in PositiveReals, NonPositiveReals, and NegativeReals all as RealIntervals
-- TODO add in Rational, Irrational, Transcendental sets, and do similar function mapping stuff below for them too (IntegerInterval, Natural=IntegerInterval(0,inf), RationalInterval, IrrationalInterval, TranscendentalInterval, etc)
--   (I'm suspicious that I'm going to need to start associating each expression with its domain/range)

function RealInterval:containsNumber(x)
	if complex:isa(x) then
		if x.im ~= 0 then return false end
		x = x.re
	end
	
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
	if require 'symmath.Variable':isa(x) then
		if x.value then 
			return self:containsNumber(x.value) 
		end
		
		-- right now :containsSet returns nil if the domains are overlapping
		-- in that case, the variable *could* be inside 'self'
		assert(not RealInterval:isa(x.set)) -- phasing this out -- use RealDomain as a single interval
		local RealDomain = require 'symmath.set.RealDomain'
		if RealDomain:isa(x.set) then
			if #x.set == 1 then
				return self:containsSet(x.set)
			else
				-- if this interval contains all of x.set's intervals then we are good
				return RealDomain(self.start, self.finish, self.containsStart, self.containsFinish):containsSet(x.set)
			end
		end
	end
end

function RealInterval:intersects(x)
	if RealInterval:isa(x) then
		local result = true
		if self.includeStart and x.includeFinish then
			-- does [a,... contain ...,b]
			result = result and self.start <= x.finish
		elseif self.includeStart and not x.includeFinish then
			-- does [a,... contain ...,b)
			result = result and self.start < x.finish
		elseif not self.includeStart and x.includeFinish then
			-- does (a,... contain ...,b]
			result = result and self.start < x.finish
		elseif not self.includeStart and not x.includeFinish then
			-- does (a,... contain ...,b)
			result = result and self.start <= x.finish
		end
		
		if self.includeFinish and x.includeStart then
			-- does ...,a] contain [b,...
			result = result and x.start <= self.finish
		elseif self.includeFinish and not x.includeStart then
			-- does ...,a] contain (b,...
			result = result and x.start < self.finish
		elseif not self.includeFinish and x.includeStart then
			-- does ...,a) contain [b,...
			result = result and x.start < self.finish
		elseif not self.includeFinish and not x.includeStart then
			-- does ...,a) contain (b,...
			result = result and x.start < self.finish
		end
		
		if result == true then return true end
	end
end

function RealInterval:containsSet(I)
	if RealInterval:isa(I) then
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
	if type(x) == 'number' 
	or complex:isa(x)
	then 
		return self:containsNumber(x) 
	end

	-- this function is specific to each function -- maybe make it a member?
	-- but for now it is only used here, so only keep it here
	local I = x:getRealDomain()
	if I == nil then return end
	assert(not RealInterval:isa(I))
	local RealDomain = require 'symmath.set.RealDomain'
	if RealDomain:isa(I) then
		if RealDomain(self.start, self.finish, self.includeStart, self.includeFinish):containsSet(I) then return true end
	end
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
local function intervalmul(a,b)
	-- this is usually nan ...
	if a == 0 then
		if b == math.huge then return math.huge end
		if b == -math.huge then return -math.huge end
	end
	if b == 0 then
		if a == math.huge then return math.huge end
		if a == -math.huge then return -math.huge end
	end
	return a * b
end
function RealInterval.__mul(A,B)
	if 0 <= A.start and 0 <= B.start then
		return RealInterval(
			intervalmul(A.start, B.start),
			intervalmul(A.finish, B.finish),
			A.includeStart and B.includeStart,
			A.includeFinish and B.includeFinish
		)
	elseif A.finish <= 0 and 0 <= B.start then
		return RealInterval(
			intervalmul(A.start, B.finish),
			intervalmul(A.finish, B.start),
			A.includeStart and B.includeFinish,
			A.includeFinish and B.includeStart
		)
	elseif 0 <= A.start and B.finish <= 0 then
		return RealInterval(
			intervalmul(A.finish, B.start),
			intervalmul(A.start, B.finish),
			A.includeFinish and B.includeStart,
			A.includeStart and B.includeFinish
		)
	elseif A.finish <= 0 and B.finish <= 0 then
		return RealInterval(
			intervalmul(A.finish, B.finish),
			intervalmul(A.start, B.start),
			A.includeFinish and B.includeFinish,
			A.includeStart and B.includeStart
		)
	elseif A.start <= 0 and 0 <= A.finish and 0 <= B.start then
		return RealInterval(
			intervalmul(A.start, B.finish),
			intervalmul(A.finish, B.finish),
			A.includeStart and B.includeFinish,
			A.includeFinish and B.includeFinish
		)
	elseif A.start <= 0 and 0 <= A.finish and B.finish <= 0 then
		return RealInterval(
			intervalmul(B.start, A.finish),
			intervalmul(B.start, A.start),
			A.includeFinish and B.includeStart,
			A.includeStart and B.includeStart
		)
	elseif B.start <= 0 and 0 <= B.finish and 0 <= A.start then
		return RealInterval(
			intervalmul(B.start, A.finish),
			intervalmul(B.finish, A.finish),
			A.includeFinish and B.includeStart,
			A.includeFinish and B.includeFinish
		)
	elseif B.start <= 0 and 0 <= B.finish and A.finish <= 0 then
		return RealInterval(
			intervalmul(A.start, B.finish),
			intervalmul(A.start, B.start),
			A.includeStart and B.includeFinish,
			A.includeStart and B.includeStart
		)
	elseif B.start <= 0 and 0 <= B.finish and A.start <= 0 and 0 <= A.finish then
		local AstartBfinish = intervalmul(A.start, B.finish)
		local AfinishBstart = intervalmul(A.finish, B.start)
		local AstartBstart = intervalmul(A.start, B.start)
		local AfinishBfinish = intervalmul(A.finish, B.finish)
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

--[[ TODO modulo 
-- [a,b] % [c,d]
function RealInterval.__mod(A,B)
end
--]]

return RealInterval 
