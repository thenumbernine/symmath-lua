local class = require 'ext.class'
local table = require 'ext.table'
local symmath

-- abstract parent class
local Set = class()

Set.name = 'Set'

function Set:variable(name, dependentVars, value)
	symmath = symmath or require 'symmath'
	-- TODO args are getting unruly, just use a table?
	return symmath.Variable(name, dependentVars, value, self)
end
-- shorthand
Set.var = Set.variable

function Set.__eq(a,b)
	return getmetatable(a) == getmetatable(b)
end

function Set:vars(...)
	return table{...}:mapi(function(x) 
		return self:var(x)
	end):unpack()
end

function Set:containsNumber(x)
	assert(type(x) == 'number')
end

local complex = require 'complex'
function Set:containsComplex(x)
	assert(complex:isa(x))

	if x.im == 0 then
		return self:containsNumber(x.re)
	end
end

-- only call this on Constant's
function Set:containsConstant(x)
	symmath = symmath or require 'symmath'
	assert(symmath.Constant:isa(x))
	return self:contains(x.value)
end

-- only call this on Variable's
function Set:containsVariable(x)
	symmath = symmath or require 'symmath'
	assert(symmath.Variable:isa(x))

	-- TODO should I care about x.value?
	-- it is more accurate to use its 'containsConstant' for sure
	-- then the resolution is specific to the number value.
	-- 
	-- TODO what is x.value? is it always a Constant?
	-- if it's an expression then shouldn't it be a UserFunction?
	-- just let :contains()'s cases handle it
	if x.value then
		return self:contains(x.value)
	end
	
	-- if x's set is a subset of this set then true
	-- but if x's set is not a subset ... x could still be contained
	assert(Set:isa(x.set))
	return x.set:isSubsetOf(self)
end

-- class Set
-- does 'self' contain 's'?
-- TODO another math technicality ... subset and containment are two separate things
-- you can have a set of elements of sets, and those sets are not subsets of the set
-- also, in that case, the set does not necessarily contain itself
-- so I'm really starting to lean away from this function name 
-- and from this function altogether
function Set:containsSet(s)
	-- rather than consider all possible subsets 's'...
	-- how about asking the opposite question?
	if s == self then return true end
	return s:isSubsetOf(self)
end

-- does 's' contain 'self'? 
-- called by 'containsSet', which subclasses hopefully shouldn't need to modify
--  because there are usually too many subsets to enumerate
-- instead just modify this function, 
--  and check against a minimal number of possible supersets
--  and trust them to check against a minimal number of supersets too
function Set:isSubsetOf(s)
end

-- any non-Variable non-Constant Expression 
function Set:containsExpression(x)
end

--[[
returns
	true = yes
	false = no
	nil = indetermined
--]]
function Set:contains(x)
	symmath = symmath or require 'symmath'

	if type(x) == 'number' then
		return self:containsNumber(x)
	end

	-- TODO
	-- Class:isa(obj) tests type(obj) and obj.isaSet, then does the lookup
	-- so just do those tests once?

	if complex:isa(x) then
		return self:containsComplex(x)
	end
	
	if Set:isa(x) then 
		return x:isSubsetOf(self) 
	end

	-- returns ~= nil when we get a Variable
	-- should I test for Variable outside 'containsVariable' ?
	if symmath.Variable:isa(x) then
		return self:containsVariable(x)
	end

	if symmath.Constant:isa(x) then
		return self:containsConstant(x)
	end

--[[
	set-containment 
	and at that, make Set a subclass of Expression
	and add set operators
	if symmath.Set:isa(x) then
		return self:containsSet(x)
	end
--]]

	-- for any other genetic Expressions
	-- hmm, looking like visitor and inheritence and rules once again
	if symmath.Expression:isa(x) then
		return self:containsExpression(x)
	end

--[[
so TODO something like:
	local t = type(x)
	if t ~= 'table' then
		local rule = self.containsRules[t] 
		if rule then return rule(self, x) end
	else
		local m = getmetatable(x)
		repeat
			local rule = self.containsRules[m]
			if rule then return rule(self, x) end
			m = m.super
		until m == nil
		local rule = self.containsRule.table 
		if rule then return rule(self, x) end
	end
	local rule = self.containsRule['*']
	if rule then return rule(self, x) end
--]]
end

return Set
