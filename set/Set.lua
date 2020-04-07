local class = require 'ext.class'

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
	return require 'symmath.Variable'(name, dependentVars, value, self)
end

function Set:containsVariable(x)
	return require 'symmath.Variable'.is(x)
			and self:containsSet(x.set)
end

--[[
returns
	true = yes
	false = no
	nil = indetermined
--]]
function Set:containsElement(x)
	if self:containsVariable(x) then return true end
end

function Set:contains(x)
	if Set.is(x) then return self:containsSet(x) end
	return self:containsElement(x)
end

return Set
