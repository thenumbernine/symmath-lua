--[[
visitor pattern superclass
--]]
local class = require 'ext.class'

local Visitor = class()
Visitor.name = 'Visitor'

--[[
debugging:
local function hash(t)
	local m = getmetatable(t)
	setmetatable(t, nil)
	local s = tostring(t):sub(10)
	setmetatable(t, m)
	return s
end
--]]

--[[
transform expr by whatever rules are provided in lookupTable

Visitor is the metatable of instances of it and all its subclasses.
Inherit from Visitor, instanciate that class as 'x', and x() will call Visitor:apply (or an overload of it in a child class)

--]]
function Visitor:apply(expr, ...)
--local Verbose = require 'symmath.tostring.Verbose'
--local id = hash(expr)
--print(id, 'begin Visitor', Verbose(expr))
	local clone = require 'symmath.clone'

	expr = clone(expr)
	
	local t = type(expr)
	if t == 'table' then
		local m = getmetatable(expr)
		-- if it's an expression then apply to all children first
		local Expression = require 'symmath.Expression'
		if m:isa(Expression) then
			-- I could use symmath.map to do this, but then I'd have to cache ... in a table (and nils might cause me to miss objects unless I called table.maxn a... )
			if expr then
				for i=1,#expr do
--print(id, 'simplifying child #'..i)
					expr[i] = self:apply(expr[i], ...)
				end
			end
		end
		-- traverse class parentwise til a key in the lookup table is found
		-- stop at null
		while m and not self.lookupTable[m] do
			m = m.super
		end
		-- if we found an entry then apply it
		if self.lookupTable[m] then
			expr = self.lookupTable[m](self, expr, ...) or expr
		end
	end
--print(id, 'done pruning with', Verbose(expr))
	return expr
end

-- wrapping this so child classes can add prefix/postfix custom code apart from the recursive case
function Visitor:__call(expr, ...)
	return self:apply(expr, ...)
end

return Visitor

