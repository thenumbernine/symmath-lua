--[[
visitor pattern superclass
--]]
local class = require 'ext.class'

local Visitor = class()
Visitor.name = 'Visitor'

--[[
look in the object's metatable for visitorHandler key matching the visitor's .name
only check in the child-most class
NOTICE this means classes must inherit (by copying) their parent class visitorHandler tables

also look in this vistor's lookup table for the key matching the object's metatable itself 

I can't use the table key here and the line above because
that would cause a dependency loop for the construction of both
--]]
function Visitor:lookup(m)
	-- check in the metatable for our visitor name.
	local f = m.visitorHandler and m.visitorHandler[self.name]
	if f then return f end
	
	while m do
		-- check in our lookupTable for the metatable key
		local f = self.lookupTable and self.lookupTable[m]
		if f then return f end
		m = m.super
	end
end

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
	local Expression = require 'symmath.Expression'

-- TODO don't be lazy, only clone when you need to
	expr = clone(expr)
	
	local t = type(expr)
	if t == 'table' then
		local m = getmetatable(expr)

		--[[
		local handler = self:lookup(m)
		if handler then
			local newexpr = handler(self, expr, ...) 
			if newexpr then
				expr = newexpr
				m = getmetatable(expr)
			end
		end
		--]]
		
		-- if it's an expression then apply to all children first
		if Expression.is(m) then
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

		-- if we found an entry then apply it
		local handler = self:lookup(m)
		if handler then
			expr = handler(self, expr, ...) or expr
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
