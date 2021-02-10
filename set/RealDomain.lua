local class = require 'ext.class'
local table = require 'ext.table'
local math = require 'ext.math'
local Universal = require 'symmath.set.Universal'
local RealInterval = require 'symmath.set.RealInterval'

-- composites of intervals
-- maybe I should change the name to RealCompositeInterval or RealSubset
local RealDomain = class(Universal)

function RealDomain:init(start, finish, includeStart, includeFinish)
	if type(start) == 'table' then
		for i,entry in ipairs(start) do
			local m = getmetatable(entry) 
			if m == nil or m == table then
				table.insert(self, RealInterval(table.unpack(entry)))
			else
				if RealInterval:isa(entry) then
					table.insert(self, entry:clone())
				elseif RealDomain:isa(entry) then
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
		assert(not math.isnan(start))
		assert(not math.isnan(finish))
		self[1] = RealInterval(start, finish, includeStart, includeFinish)
	elseif type(start) == 'nil' then
		self[1] = RealInterval()	-- full domain
	else
		error'here'
	end
end

-- merge any contained intervals that overlap
function RealDomain:checkMerge()
	-- first sort intervals by start
	table.sort(self, function(a,b)
		return a.start < b.start
	end)
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
end

function RealDomain:__tostring()
	local s = ''
	if #self > 1 then s = s .. '{' end
	for _,I in ipairs(self) do
		s = s .. (I.includeStart and '[' or '(')
			.. I.start
			.. ', '
			.. I.finish
			.. (I.includeFinish and ']' or ')')
	end
	if #self > 1 then s = s .. '}' end
	return s
end

function RealDomain:containsNumber(x)
	local gotfalse
	for _,I in ipairs(self) do
		local containsI = I:containsNumber(x) 
		if containsI then return true end
		if containsI == false then gotfalse = false end
	end
	return gotfalse
end

function RealDomain:containsVariable(x)
	local gotfalse
	for _,I in ipairs(self) do
		local containsI = I:containsVariable(x) 
		if containsI then return true end
		if containsI == false then gotfalse = false end
	end
	return gotfalse
end

function RealDomain:intersects(set)
	if RealInterval:isa(set) then	
		for _,selfi in ipairs(self) do
			if selfi:intersects(set) then return true end
		end
	elseif RealDomain:isa(set) then
		for _,seti in ipairs(set) do
			if self:intersects(seti) then return true end
		end
	end
end

function RealDomain:containsSet(set)
	if RealInterval:isa(set) then
		-- if any of self's intervals contains 'set' then return true
		local gotfalse
		for _,selfI in ipairs(self) do
			local selfIcontains = selfI:containsSet(set) 
			if selfIcontains then return true end
			if selfIcontains == false then gotfalse = false end
		end
		return gotfalse
	elseif RealDomain:isa(set) then
		-- if all of set's intervals are contained within this interval then return true
		for _,setI in ipairs(set) do
			local containsI = self:contains(setI)
			-- TODO what about uncertainty?
			if not containsI then return false end
		end
		return true 
	end
end

function RealDomain:containsElement(x)
	local gotfalse
	for _,I in ipairs(self) do
		local containsI = I:containsElement(x) 
		if containsI then return true end
		if containsI == false then gotfalse = false end
	end
	return gotfalse
end

function RealDomain.__unm(A)
	return RealDomain(
		table.mapi(A, function(I)
			return -I
		end)
	)
end

-- {[a1,b1],[a2,b]} + {[c1,d1],[c2,d2]}
-- this becomes the union of the cartesian product of all set additions
function RealDomain.__add(A,B)
	local newints = table()
	for _,ai in ipairs(A) do
		for _,bi in ipairs(B) do
			newints:insert(ai + bi)
		end
	end
	return RealDomain(newints)
end

function RealDomain.__sub(A,B)
	local newints = table()
	for _,ai in ipairs(A) do
		for _,bi in ipairs(B) do
			newints:insert(ai - bi)
		end
	end
	return RealDomain(newints)
end

function RealDomain.__mul(A,B)
	local newints = table()
	for _,ai in ipairs(A) do
		for _,bi in ipairs(B) do
			newints:insert(ai * bi)
		end
	end
	return RealDomain(newints)
end

function RealDomain.__div(A,B)
	local newints = table()
	for _,ai in ipairs(A) do
		for _,bi in ipairs(B) do
			newints:insert(ai / bi)
		end
	end
	return RealDomain(newints)
end

function RealDomain.__pow(A,B)
	local newints = table()
	for _,ai in ipairs(A) do
		for _,bi in ipairs(B) do
			newints:insert(ai ^ bi)
		end
	end
	return RealDomain(newints)
end

function RealDomain.__mod(A,B)
	local newints = table()
	for _,ai in ipairs(A) do
		for _,bi in ipairs(B) do
			newints:insert(ai % bi)
		end
	end
	return RealDomain(newints)
end

-- commonly used versions of the Expression:getRealDomain function

-- (-inf,inf) even, increasing from zero
-- abs, cosh
function RealDomain.getRealDomain_evenIncreasing(x)
	if x.cachedSet then return x.cachedSet end
	local Is = x[1]:getRealDomain()
	if Is == nil then 
		x.cachedSet = nil
		return nil 
	end
	x.cachedSet = RealDomain(table.mapi(Is, function(I)
		if I.finish <= 0 then
			return RealDomain(
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
			return RealDomain(
				x.realFunc(0),
				finish,
				true,
				includeFinish
			)
		elseif 0 <= I.start then
			return RealDomain(
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
-- sqrt, log
function RealDomain.getRealDomain_posInc_negIm(x)
	if x.cachedSet then return x.cachedSet end
	local Is = x[1]:getRealDomain()
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
	x.cachedSet = RealDomain(table.mapi(Is, function(I)
		return RealDomain(
			x.realFunc(I.start),
			x.realFunc(I.finish),
			I.includeStart,
			I.includeFinish)
	end))
	return x.cachedSet
end

-- (-1,1) => (-inf,inf) increasing, (-inf,-1) and (1,inf) imaginary
-- asin, atanh
function RealDomain.getRealDomain_pmOneInc(x)
	if x.cachedSet then return x.cachedSet end
	local Is = x[1]:getRealDomain()
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
	x.cachedSet = RealDomain(table.mapi(Is, function(I)
		return RealDomain(
			x.realFunc(I.start),
			x.realFunc(I.finish),
			I.includeStart,
			I.includeFinish)
	end))
	return x.cachedSet
end

-- (-inf,inf) increasing
-- sinh, tanh, asinh, atan
function RealDomain.getRealDomain_inc(x)
	if x.cachedSet then return x.cachedSet end
	local Is = x[1]:getRealDomain()
	if Is == nil then 
		x.cachedSet = nil
		return nil 
	end
	x.cachedSet = RealDomain(table.mapi(Is, function(I)
		return RealDomain(
			x.realFunc(I.start),
			x.realFunc(I.finish),
			I.includeStart,
			I.includeFinish)
	end))
	return x.cachedSet
end

return RealDomain
