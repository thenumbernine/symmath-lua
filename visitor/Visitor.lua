--[[
visitor pattern superclass
--]]
local class = require 'ext.class'

local Visitor = class()
Visitor.name = 'Visitor'

--[[
look in the object's metatable for rules key matching the visitor's .name
only check in the child-most class
NOTICE this means classes must inherit (by copying) their parent class rules tables

also look in this vistor's lookup table for the key matching the object's metatable itself 

I can't use the table key here and the line above because
that would cause a dependency loop for the construction of both
--]]
function Visitor:lookup(m)
	-- check in the metatable for our visitor name.
	local f = m.rules and m.rules[self.name]
	if f then return f end
end

-- [[ debugging:
local function hash(t)
	local m = getmetatable(t)
	setmetatable(t, nil)
	local s = tostring(t):sub(10)
	setmetatable(t, m)
	return s
end
--]]

local function getn(...)
	local t = {...}
	t.n = select('#', ...)
	return t
end

--[[
transform expr by whatever rules are provided in lookupTable

Visitor is the metatable of instances of it and all its subclasses.
Inherit from Visitor, instanciate that class as 'x', and x() will call Visitor:apply (or an overload of it in a child class)

--]]
function Visitor:apply(expr, ...)
	local debugVisitors = require 'symmath'.debugVisitors

	local Verbose
	if debugVisitors then
		Verbose = require 'symmath.tostring.Verbose'
	end

	local args = getn(...)
--[==[
	local success, results = xpcall(function()
--]==]

		local id
		if debugVisitors then
			id = hash(expr)
			print(id, 'begin Visitor', Verbose(expr))
		end
		
		local clone = require 'symmath.clone'
		local Expression = require 'symmath.Expression'

	-- TODO don't be lazy, only clone when you need to
		expr = clone(expr)
		
		local t = type(expr)
		if t == 'table' then
			local m = getmetatable(expr)

			--[[
			local rules = self:lookup(m)
			if rules then
				for _,rule in ipairs(rules) do
					local name, func = next(rule)
					local newexpr = func(self, expr, table.unpack(args, 1, args.n)) 
					if newexpr then
						expr = newexpr
						m = getmetatable(expr)
					end
				end
			end
			--]]
		
			-- TODO bubble-in and bubble-out

			-- if it's an expression then apply to all children first
			if Expression.is(m) then
				if expr then
					for i=1,#expr do
						if debugVisitors then
							print(id, 'simplifying child #'..i)
						end
						expr[i] = self:apply(expr[i], table.unpack(args, 1, args.n))
					end
				end
			end
			-- traverse class parentwise til a key in the lookup table is found
			-- stop at null

			-- if we found an entry then apply it
			local rules = self:lookup(m)
			if rules then
				for _,rule in ipairs(rules) do
					if not m.pushedRules
					or not m.pushedRules[rule]
					then
						local name, func = next(rule)
						local newexpr = func(self, expr, table.unpack(args, 1, args.n))
						if newexpr then
							expr = newexpr
							-- if we change content then there's no guarantee the metatable -- or the rules -- will be the same
							-- we probably need to start again
							-- this would have the detriment
							m = getmetatable(expr)
							break
						end
					end
				end
			end
		end
		if debugVisitors then
			print(id, 'done pruning with', Verbose(expr))
		end
		return expr
--[==[
	end, function(err)
		io.stderr:write('expr:'..tostring(expr)..'\n')
		io.stderr:write('err:'..err..'\n')
		io.stderr:write(debug.traceback())
		io.stderr:flush()
	end)
	if not success then 
		error'here'
	end
	return results 
--]==]
end

-- wrapping this so child classes can add prefix/postfix custom code apart from the recursive case
function Visitor:__call(expr, ...)
	return self:apply(expr, ...)
end

return Visitor
