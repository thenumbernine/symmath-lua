local class = require 'ext.class'
local table = require 'ext.table'
local Variable = require 'symmath.Variable'

-- abstract parent class
local Set = class()

Set.name = 'Set'

-- cheap trick for now: let inheritence double as set-contains
function Set:containsSet(s)
	local m = getmetatable(self)
	local is = m.is or self.is
	if is then return is(s) end
end

function Set:variable(name, dependentVars, value)
	-- TODO args are getting unruly, just use a table?
	return Variable(name, dependentVars, value, self)
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

local Constant
function Set:containsVariable(x)
	if Variable:isa(x) then
		if x.value then
			Constant = Constant or require 'symmath.Constant'
			return self:containsElement(Constant(x.value))
		end
		
		-- if x's set is a subset of this set then true
		-- but if x's set is not a subset ... x could still be contained
		if self:containsSet(x.set) then return true end
	end
end

--[[
returns
	true = yes
	false = no
	nil = indetermined
--]]
function Set:containsElement(x)
	return self:containsVariable(x)
end

function Set:contains(x)
	if Set:isa(x) then return self:containsSet(x) end
	return self:containsElement(x)
end

return Set
