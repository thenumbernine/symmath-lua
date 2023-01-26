local class = require 'ext.class'
local math = require 'ext.math'
local Set = require 'symmath.set.Set'
local complex = require 'complex'
local symmath

-- in some places I'm using subclasses to represent subsets ...
local RealInterval = class(Set)
RealInterval.name = 'RealInterval'

function RealInterval:init(start, finish, includeStart, includeFinish)
	-- if any values are nil then all values should be nil, meaning an empty interval
	self.start = assert(start)
	self.finish = assert(finish)
	self.includeStart = includeStart
	self.includeFinish = includeFinish
-- extended real stuff
--[[
assert(self.start ~= -math.huge or self.includeStart)
assert(self.finish ~= math.huge or self.includeFinish)
--]]
-- [[
if self.start == -math.huge then self.includeStart = true end
if self.finish == math.huge then self.includeFinish = true end
--]]
	assert(type(self.includeStart) == 'boolean')
	assert(type(self.includeFinish) == 'boolean')
	if math.isnan(self.start) or math.isnan(self.finish) then
		error('tried to construct a RealInterval with nan bounds:\n'
				..require'ext.tolua'(self))
	end
end

function RealInterval:isEmpty()
	if not self.start then
		assert(not self.finish)
		return true
	end
	return false
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

function RealInterval.__concat(a,b)
	return tostring(a) .. tostring(b)
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

-- TODO add in PositiveReals, NonPositiveReals, and NegativeReals all as RealIntervals
-- TODO add in Rational, Irrational, Transcendental sets, and do similar function mapping stuff below for them too (IntegerInterval, Natural=IntegerInterval(0,inf), RationalInterval, IrrationalInterval, TranscendentalInterval, etc)
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

-- A:isSubsetOf(B) == A ⊆ B
function RealInterval.isSubsetOf(subI, supI)
	symmath = symmath or require 'symmath'
	-- minimal superset test
	if symmath.set.complex:isSubsetOf(s) then return true end
	local RealSubset = symmath.set.RealSubset

	if RealInterval:isa(subI) then
		local result = true
		if supI.includeStart and subI.includeStart then
			-- does [a,... contain [b,...
			result = result and supI.start <= subI.start
		elseif supI.includeStart and not subI.includeStart then
			-- does [a,... contain (b,...
			result = result and supI.start <= subI.start
		elseif not supI.includeStart and subI.includeStart then
			-- does (a,... contain [b,...
			result = result and supI.start < subI.start
		elseif not supI.includeStart and not subI.includeStart then
			-- does (a,... contain (b,...
			result = result and supI.start <= subI.start
		end

		if supI.includeFinish and subI.includeFinish then
			-- does ...,a] contain ...,b]
			result = result and subI.finish <= supI.finish
		elseif supI.includeFinish and not subI.includeFinish then
			-- does ...,a] contain ...,b)
			result = result and subI.finish <= supI.finish
		elseif not supI.includeFinish and subI.includeFinish then
			-- does ...,a) contain ...,b]
			result = result and subI.finish < supI.finish
		elseif not supI.includeFinish and not subI.includeFinish then
			-- does ...,a) contain ...,b)
			result = result and subI.finish <= supI.finish
		end

		if result == true then return true end

		if subI.finish < supI.start then return false end
		if supI.finish < subI.start then return false end

		-- by here the two sets are overlapping but I isn't contained in supI
		-- so technically 'containsSet' is false
		-- but right now :containsVariable is calling this
		-- and containsVariable wants to return nil when the sets overlap
		-- and I'm too lazy to write a separate :touchesSet function
	end

	-- are we a subset of a set of intervals?
	-- true if any of those intervals contain this interval
	-- nil if any overlap
	-- false if all exclude
	if RealSubset:isa(supI) then
		assert(#supI > 0)
		local result
		for _,setI in ipairs(supI) do
			local containsI = self:isSubsetOf(setI)
			if containsI == nil then
				return nil	-- if any are uncertain then return uncertain
			elseif containsI == false then
				-- if a previous interval was true, but this interval is false,
				-- then return uncertain
				if result == true then
					return nil
				end
				result = false 	-- only return false if all are false
			else
				assert(containsI == true)
				result = true
			end
		end
		return result
	end
end

function RealInterval:containsExpression(x)
	-- Expressions, other than Variable, Constant, etc
	-- is Set an Expression?  not right now.
	-- should it be?
	--
	-- this function is specific to each function -- maybe make it a member?
	-- but for now it is only used here, so only keep it here
	local I = x:getRealRange()
	if I == nil then return end
	assert(not RealInterval:isa(I))

	symmath = symmath or require 'symmath'
	local RealSubset = symmath.set.RealSubset
	if RealSubset:isa(I) then
		if I:isSubsetOf(RealSubset(self.start, self.finish, self.includeStart, self.includeFinish)) then return true end
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
	-- reals are (-inf, inf)
	-- I saw shorthand for extended reals to be [-inf, inf] and jumped on it
	-- but using this concept comes with its own set of problems
	-- for example, when considering the boundary of 1/(a,b), it's nice for inf to be open by default

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

	--[[
	these produce disjoint domains, not intervals,
	so they cannot be handled in the RealInterval operator,
	but they are in the RealSubset operator

	better to err on the side of a larger domain than a smaller domain
	and built-in operators don't support multiple return
	so for these, I'll have the first result by (-inf,inf) - for doing operators on intervals
	and then afterwards I'll return the separate disjoint intervals.
	and then I'll change RealSubset to explicitly call the __div member and to look for multiple return values
	--]]
	elseif 0 <= A.start and B.start <= 0 and 0 <= B.finish then
		local invBincludeStart = B.includeStart
		if B.start == -math.huge then invBincludeStart = false end
		local invBincludeFinish = B.includeFinish
		if B.finish == math.huge then invBincludeFinish = false end
		return RealInterval(-math.huge, math.huge, true, true),
			A * RealInterval(-math.huge, 1/B.start, true, invBincludeStart),
			A * RealInterval(1/B.finish, math.huge, invBincludeFinish, true)
	elseif A.finish <= 0 and B.start <= 0 and 0 <= B.finish then
		local invBincludeStart = B.includeStart
		if B.start == -math.huge then invBincludeStart = false end
		local invBincludeFinish = B.includeFinish
		if B.finish == math.huge then invBincludeFinish = false end
		return RealInterval(-math.huge, math.huge, true, true),
			A * RealInterval(-math.huge, 1/B.start, true, invBincludeStart),
			A * RealInterval(1/B.finish, math.huge, invBincludeFinish, true)
	elseif A.start <= 0 and 0 <= A.finish and B.start <= 0 and 0 <= B.finish then
		local invBincludeStart = B.includeStart
		if B.start == -math.huge then invBincludeStart = false end
		local invBincludeFinish = B.includeFinish
		if B.finish == math.huge then invBincludeFinish = false end
		return RealInterval(-math.huge, math.huge, true, true),
			A * RealInterval(-math.huge, 1/B.start, true, invBincludeStart),
			A * RealInterval(1/B.finish, math.huge, invBincludeFinish, true)
	else
		-- that should be all possible cases
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
	-- for (a,b)^(0,0), return [1,1] ... ?
	if B.start == 0 and B.finish == 0 then	-- and B.includeStart and B.includeFinish ... or is this implied?
		return RealInterval(1,1,true,true)
	end

	-- for (a,b)^(c,d), d <= 0
	-- try (1/(a,b)) ^ (-d, -c)
	if B.finish <= 0 then
		return (RealInterval(1,1,true,true) / A) ^ -B
	end

	--[[
	if any of the (a,b) interval is negative:
	if (c,d) *contains* a non-integer then our domain is not real and therefore invalid
	however if it is solely an integer then, for odd integers, we preserve sign and apply power
	for even integers we make it positive
	--]]
	if A.start < 0 then
		-- if it is an interval at all then there will be an irrational point within it, and our exponent will be a root and therefore not real and therefore invalid
		-- if it not inclusive on both sides then it won't contain its sole point and therefore will be invalid
		if not (B.start == B.finish and B.includeStart and B.includeFinish) then
			return nil
		end

		-- roots of negatives are not real:
		if B.start ~= math.floor(B.start) then

-- however ... R^R lies in this condition
-- x^x, x in reals, has a range of (-inf,inf)^(-inf,inf)
-- and this will lie here ...
			return nil
		end

		if B.start % 2 == 1 then 	-- odd: preserve sign
			return RealInterval(
				A.start ^ B.start,
				A.finish ^ B.start,
				A.includeStart and B.includeStart,
				A.includeFinish and B.includeFinish)
		else	-- even: make positive
			-- if A's endpoints are on either side of 0 then 0 will be the range minimum
			if A.finish > 0 then
				return RealInterval(
					0,
					math.max(A.start ^ B.start, A.finish ^ B.start),
					true,
					A.includeFinish and B.includeFinish)
			-- otherwise, with a<0 and b<0, we know the signs will be flipped
			else
				return RealInterval(
					A.finish ^ B.start,
					A.start ^ B.start,
					A.includeStart and B.includeStart,
					A.includeFinish and B.includeFinish)
			end
		end
	end

	--[[
	for 0 < a, 0 < c, (a,b) ^ (c,d) = (a^c, b^d)
	mind you, for 0 <= c <= 1, the interval (a,b)^c will increase, but for 1 < c, (a,b)^c will decrease, but it will maintain its order
	this means (.5, .6) ^ (.5, 2) will reverse its order
	--]]
	if 0 <= A.start then
		if 0 <= B.start and B.finish <= 1 then
			-- order will be preserved
			-- (a,b)^(c,d) will converge towards 1
			return RealInterval(
				A.start ^ B.start,
				A.finish ^ B.finish,
				A.includeStart and B.includeStart,
				A.includeFinish and B.includeFinish)
		elseif 0 <= B.start and B.start <= 1 and 1 <= B.finish then
			-- the order of a ^ c and b ^ d could reverse
			-- but everything will still be positive since 0<a
			local ac = A.start ^ B.start
			local ad = A.start ^ B.finish
			local bc = A.finish ^ B.start
			local bd = A.finish ^ B.finish
			return RealInterval(
				math.min(ac, ad, bc, bd),
				math.max(ac, ad, bc, bd),
				A.includeStart and B.includeStart,
				A.includeFinish and B.includeFinish)
		elseif 1 <= B.start then
			-- order will be preserved
			-- (a,b)^(c,d) will diverge away from 1
			return RealInterval(
				A.start ^ B.start,
				A.finish ^ B.finish,
				A.includeStart and B.includeStart,
				A.includeFinish and B.includeFinish)
		end

		-- if 1<=a then even for c=-inf we will map to positives
		-- but we still have the dilemma that c,d < 0 will go down and >0 will go up
		-- if c,d < 0 then b will be the minimum
		-- if c,d > 0 then a will be the minimum
		if 1 <= A.start then
			return RealInterval(
				math.min(A.start ^ B.start, A.start ^ B.finish),
				math.max(A.finish ^ B.start, A.finish ^ B.finish),
				A.includeStart and B.includeStart,
				A.includeFinish and B.includeFinish)
		end
	end

	return RealInterval(-math.huge, math.huge, true, true)
end

--[[ TODO modulo
-- [a,b] % [c,d]
function RealInterval.__mod(A,B)
end
--]]

function RealInterval.__eq(A,B)
	return A.start == B.start
	and A.finish == B.finish
	and A.includeStart == B.includeStart
	and A.includeFinish == B.includeFinish
end

return RealInterval
