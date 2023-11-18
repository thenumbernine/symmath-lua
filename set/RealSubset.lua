local table = require 'ext.table'
local math = require 'ext.math'
local Set = require 'symmath.set.Set'
local RealInterval = require 'symmath.set.RealInterval'
local symmath

-- composites of intervals
-- TODO better term?
-- the math term "subset" could also define things with :nfinite regions, which cannot be defined by this class
local RealSubset = Set:subclass()
RealSubset.name = 'RealSubset'

RealSubset.last = table.last

function RealSubset:init(start, finish, includeStart, includeFinish)
	if type(start) == 'table' then
		for i,entry in ipairs(start) do
			local m = getmetatable(entry)
			if m == nil or m == table then
				table.insert(self, RealInterval(table.unpack(entry)))
			else
				if RealInterval:isa(entry) then
					table.insert(self, entry:clone())
				elseif RealSubset:isa(entry) then
					for j,interval in ipairs(entry) do
						table.insert(self, interval:clone())
					end
				else
					error'here'
				end
			end
		end
		self:checkMerge()
	elseif type(start) == 'number' then
		self[1] = RealInterval(start, finish, includeStart, includeFinish)
	elseif type(start) == 'nil' then
		self[1] = RealInterval(-math.huge, math.huge, true, true)	-- full domain
	else
		error'here'
	end
end

-- merge any contained intervals that overlap
function RealSubset:checkMerge()
	-- first sort intervals by start
	table.sort(self, function(a,b)
		return a.start < b.start
	end)

	-- get rid of any redundant sets
	for i=#self,1,-1 do
		local I = self[i]
		if I.start == I.finish
		and not (I.includeStart and I.includeFinish)
		then
			table.remove(self, i)
		end
	end

	-- next see if finish overruns any
	local i=2
	while i <= #self do
		local merge
		if self[i-1].includeFinish
		or self[i].includeStart
		then
			if self[i].start <= self[i-1].finish then
				merge = true
			end
		else
			-- if the previous interval doesn't include finish and this doesn't include start
			if self[i].start < self[i-1].finish then
				merge = true
			end
		end
		if merge then
			self[i-1].finish = self[i].finish
			self[i-1].includeFinish = self[i].includeFinish
			table.remove(self, i)
			i = i - 1
		end
		i = i + 1
	end

	return self
end

-- only represent empty RealSubsets as a single child that is an empty RealInterval
-- or TODO should I represent it as an empty RealSubset?
function RealSubset:isEmpty()
	if self[1]:isEmpty() then
		assert(#self == 1)
		return true
	else
		assert(#self > 0)
		for i=2,#self do
			assert(not self[i]:isEmpty())
		end
		return false
	end
end

function RealSubset:complement()
	if #self == 0 then
		-- in the reals, the complement of the empty set is the whole real line
		return RealSubset(-math.huge, math.huge, true, true)
	end
	local ints = table()
	local n = #self
	local first = self[1]
	local last = self[n]
	if first.start ~= -math.huge then
		ints:insert(RealInterval(-math.huge, first.start, true, not self[1].includeStart))
	end
	for i=1,n-1 do
		ints:insert(RealInterval(self[i].finish, self[i+1].start, not self[i].includeFinish, not self[i+1].includeStart))
	end
	if last.finish ~= math.huge then
		ints:insert(RealInterval(last.finish, math.huge, not last.includeStart, true))
	end
	return RealSubset(ints)
end

function RealSubset:open()
	local result = RealSubset(self)
	local n = #result
	for i=1,n do
		-- back to extended-real exceptions:
		-- [-inf,inf] open is going to still be [-inf, inf]
		if not (i == 1 and result[i].start == -math.huge) then
			result[i].includeStart = false
		end
		if not (i == n and result[i].finish == math.huge) then
			result[i].includeFinish = false
		end
	end
	return result:checkMerge()
end

function RealSubset:__tostring()
	local s = ''
	local sep = ''
	if #self > 1 then s = s .. '{' end
	for _,I in ipairs(self) do
		s = s .. sep
			.. (I.includeStart and '[' or '(')
			.. I.start
			.. ', '
			.. I.finish
			.. (I.includeFinish and ']' or ')')
		sep = ', '
	end
	if #self > 1 then s = s .. '}' end
	return s
end

function RealSubset.__concat(a,b)
	return tostring(a) .. tostring(b)
end

function RealSubset:intersects(set)
	if RealInterval:isa(set) then
		for _,selfi in ipairs(self) do
			if selfi:intersects(set) then return true end
		end
	elseif RealSubset:isa(set) then
		for _,seti in ipairs(set) do
			if self:intersects(seti) then return true end
		end
	end
end

function RealSubset:containsNumber(x)
	local gotfalse
	for _,I in ipairs(self) do
		local containsI = I:containsNumber(x)
		if containsI then return true end
		if containsI == false then gotfalse = false end
	end
	return gotfalse
end

function RealSubset:containsBigNumber(x)
	local gotfalse
	for _,I in ipairs(self) do
		local containsI = I:containsBigNumber(x)
		if containsI then return true end
		if containsI == false then gotfalse = false end
	end
	return gotfalse
end

function RealSubset:containsVariable(x)
	local gotfalse
	for _,I in ipairs(self) do
		local containsI = I:containsVariable(x)
		if containsI then return true end
		if containsI == false then gotfalse = false end
	end
	return gotfalse
end

function RealSubset:isSubsetOf(s)
	assert(#self > 0)	-- using the empty set? use set.null

	symmath = symmath or require 'symmath'
	-- real is RealSubset
	--if symmath.set.real:isSubsetOf(s) then return true end
	-- so use a minimal superset
	if symmath.set.complex:isSubsetOf(s) then return true end

	-- if we are a subset of any i'th interval of s then return true
	-- if we are not a subset of all intervals of s then return false
	-- otherwise nil?
	if RealSubset:isa(s) then
		local result = false
		for _,sI in ipairs(s) do
			local containsSI = self:isSubsetOf(sI)
			if containsSI == true then
				return true
			elseif containsSI == nil then
				result = nil
			end
		end
		return result
	end

	-- if all our intervals are within RealInterval 's' then return true
	-- if all are outside then return false
	-- if we have any intersection then return nil
	if RealInterval:isa(s) then
		local alltrue = true
		local allfalse = true
		for _,selfI in ipairs(self) do
			local selfIcontains = selfI:isSubsetOf(s)
			if selfIcontains ~= true then alltrue = false end
			if selfIcontains ~= false then allfalse = false end
			if selfIcontains == nil then return nil end
		end
		assert(not (alltrue and allfalse))	-- should only happen in the caese of the empty set, which I assert'd against at the top of the function
		if alltrue then return true end
		if allfalse then return false end
		return nil	-- short-circuit should stop us from getting here
	end
end

-- any non-Variable non-Constant Expression
function RealSubset:containsExpression(x)
	local gotfalse
	for _,I in ipairs(self) do
		local containsI = I:contains(x)
		if containsI then return true end
		if containsI == false then gotfalse = false end
	end
	return gotfalse
end

function RealSubset.__unm(A)
	return RealSubset(
		table.mapi(A, function(I)
			return -I
		end)
	)
end

-- {[a1,b1],[a2,b]} + {[c1,d1],[c2,d2]}
-- this becomes the union of the cartesian product of all set additions
function RealSubset.__add(A,B)
	local newints = table()
	for _,ai in ipairs(A) do
		for _,bi in ipairs(B) do
			newints:insert(ai + bi)
		end
	end
	return RealSubset(newints):checkMerge()
end

function RealSubset.__sub(A,B)
	local newints = table()
	for _,ai in ipairs(A) do
		for _,bi in ipairs(B) do
			newints:insert(ai - bi)
		end
	end
	return RealSubset(newints):checkMerge()
end

function RealSubset.__mul(A,B)
	local newints = table()
	for _,ai in ipairs(A) do
		for _,bi in ipairs(B) do
			newints:insert(ai * bi)
		end
	end
	return RealSubset(newints):checkMerge()
end

function RealSubset.__div(A,B)
	local newints = table()
	for _,ai in ipairs(A) do
		for _,bi in ipairs(B) do
			-- __div produce multiple disjoint intervals, and therefore can have multiple return
			-- in the event of multiple intervals, the first value is throw-away
			local is = table{ai:__div(bi)}
			if #is > 1 then is:remove(1) end
			newints:append(is)
		end
	end
	return RealSubset(newints):checkMerge()
end

-- RealInterval ops return nil when the result is invalid, such as raising a negative number to a fractional number.
-- this only happens in RealInterval.__pow, since the rest of the operations are determinable
-- so ... as a hack ... if __pow produces no intervals (because they were all nil)
-- (as when evaluating (-inf,inf)^(-inf,inf))
-- I am going to have a special condition to just insert the whole real line
-- TODO think this through.
function RealSubset.__pow(A,B)
	local newints = table()
	for _,ai in ipairs(A) do
		for _,bi in ipairs(B) do
			newints:insert(ai ^ bi)
		end
	end
	-- if we should've produced something, but we produced nothing...
	if not A:isEmpty() and not B:isEmpty() and #newints == 0 then
		return RealSubset(-math.huge, math.huge, true, true)	-- just produce the whole reals?
	end
	return RealSubset(newints):checkMerge()
end

function RealSubset.__mod(A,B)
	local newints = table()
	for _,ai in ipairs(A) do
		for _,bi in ipairs(B) do
			newints:insert(ai % bi)
		end
	end
	return RealSubset(newints):checkMerge()
end

function RealSubset.__eq(A,B)
	local nA, nB = #A, #B
	if nA ~= nB then return false end
	for i=1,nA do
		if A[i] ~= B[i] then return false end
	end
	return true
end

-- commonly used versions of the Expression:getRealDomain function

-- all reals
-- used by: abs, asinh
function RealSubset.getRealDomain_real()
	local set = require 'symmath.set.sets'
	return set.real
end

-- used by: log
function RealSubset.getRealDomain_positiveReal()
	local set = require 'symmath.set.sets'
	return set.positiveReal
end

-- used by: asin, acos
function RealSubset.getRealDomain_plusMinusOneClosed()
	return RealSubset(-1, 1, true, true)
end

-- used by: atanh
function RealSubset.getRealDomain_plusMinusOneOpen()
	return RealSubset(-1, 1, false, false)
end

-- used by sqrt
function RealSubset.getRealDomain_nonNegativeReal()
	return RealSubset(0, math.huge, true, true)
end

-- commonly used versions of the Expression:getRealRange function

-- (-inf,inf) even, increasing from zero
-- used by: abs, cosh
function RealSubset.getRealRange_evenIncreasing(x)
	if x.cachedSet then return x.cachedSet end
	local Is = x[1]:getRealRange()
	if Is == nil then
		x.cachedSet = nil
		return nil
	end
	x.cachedSet = RealSubset(table.mapi(Is, function(I)
		if I.finish <= 0 then
			return RealSubset(
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
			return RealSubset(
				x.realFunc(0),
				finish,
				true,
				includeFinish
			)
		elseif 0 <= I.start then
			return RealSubset(
				x.realFunc(I.start),
				x.realFunc(I.finish),
				I.includeStart,
				I.includeFinish
			)
		end
	end))
	return x.cachedSet
end

-- (0,inf) increasing, (-inf,0) imaginary
-- used by: sqrt, log
function RealSubset.getRealRange_posInc_negIm(x)
	if x.cachedSet then return x.cachedSet end
	local Is = x[1]:getRealRange()
	if Is == nil then
		x.cachedSet = nil
		return nil
	end
	-- if the input touches (-inf,0) but is not contained by (-inf,0) then we are uncertain
	-- but if it is contained then we are an empty set
	-- either way, nil for now
	for _,I in ipairs(Is) do
		if I.start < 0 then
			x.cachedSet = nil
			return nil
		end
	end
	x.cachedSet = RealSubset(table.mapi(Is, function(I)
		return RealSubset(
			x.realFunc(I.start),
			x.realFunc(I.finish),
			I.includeStart,
			I.includeFinish)
	end))
	return x.cachedSet
end

-- (-1,1) => (-inf,inf) increasing, (-inf,-1) and (1,inf) imaginary
-- used by: asin, atanh
function RealSubset.getRealRange_pmOneInc(x)
	if x.cachedSet then return x.cachedSet end
	local Is = x[1]:getRealRange()
	if Is == nil then
		x.cachedSet = nil
		return nil
	end
	-- not real
	for _,I in ipairs(Is) do
		if I.start < -1 or 1 < I.finish then
			x.cachedSet = nil
			return nil
		end
	end
	x.cachedSet = RealSubset(table.mapi(Is, function(I)
		return RealSubset(
			x.realFunc(I.start),
			x.realFunc(I.finish),
			I.includeStart,
			I.includeFinish)
	end))
	return x.cachedSet
end

-- (-inf,inf) increasing
-- used by: sinh, tanh, asinh, atan
function RealSubset.getRealRange_inc(x)
	if x.cachedSet then return x.cachedSet end
	local Is = x[1]:getRealRange()
	if Is == nil then
		x.cachedSet = nil
		return nil
	end
	x.cachedSet = RealSubset(table.mapi(Is, function(I)
		return RealSubset(
			x.realFunc(I.start),
			x.realFunc(I.finish),
			I.includeStart,
			I.includeFinish)
	end))
	return x.cachedSet
end

return RealSubset
