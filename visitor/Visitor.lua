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
function Visitor:lookup(m, bubbleIn)
	assert(m, "expression metatable is nil")
	if bubbleIn then
		return m.rulesBubbleIn and m.rulesBubbleIn[self.name] or nil
	else
		-- check in the metatable for our visitor name.
		return m.rules and m.rules[self.name] or nil
	end
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

--[[
whether we want to prevent visitors twice from running on an expression
--]]
Visitor.rememberVisit = true

--[[
transform expr by whatever rules are provided in lookupTable

Visitor is the metatable of instances of it and all its subclasses.
Inherit from Visitor, instanciate that class as 'x', and x() will call Visitor:apply (or an overload of it in a child class)

--]]
local symmath
function Visitor:apply(expr, ...)
--DEBUG(@5):return select(2, require 'ext.timer'(self.name, function(...)
--DEBUG(@5):local changeInNodes = {}

	symmath = symmath or require 'symmath'
	local debugVisitors = symmath.debugVisitors

	local origIsExpr
	if self.rememberVisit then
-- [[ cache visitors & simplification.  does this help?
assert(self.name ~= Visitor.name)
		local selfmt = self.class	 --getmetatable(self)
		if not selfmt.hasBeenField then
			selfmt.hasBeenField = 'hasBeen'..self.name
		end
assert(selfmt.hasBeenField == self.hasBeenField)
--]]
-- [[
		origIsExpr = symmath.Expression:isa(expr)
		if symmath.useHasBeenFlags
		and origIsExpr
		and not expr.mutable
		and expr[self.hasBeenField]
		then
--DEBUG(@5):print('found '..self.hasBeenField..' on '..symmath.export.SingleLine(expr)..' - not visiting')
			return expr
		end
--]]
	end

	local Verbose
	if debugVisitors then
		Verbose = symmath.Verbose
	end

	local id
	if debugVisitors then
		id = hash(expr)
		print(id, 'begin Visitor', Verbose(expr))
	end

	local clone = symmath.clone
	local Expression = symmath.Expression

	-- TODO only clone when you need to
	-- expr = expr:cloneIfMutable()	--TODO
	local orig = expr
--[[ deep copy ... not needed if mutable objects are mutable
	expr = clone(expr)
--]]
-- [[
	if not Expression:isa(expr) then
		expr = clone(expr)	-- not an Expression ... turn it into an expression
	else
		-- expression -- do a shallow copy if it is not a mutable object
		-- mutable objects are: Array, Wildcard
		-- TODO how about a mutableCopy() or mutableShallowCopy()
		-- that does deep copy for Array/mutable, but shallow for all non-mutable Expression's
		if not expr.mutable then
			-- TODO make this not a shallow copy ... make it no copy for not mutable
			-- to cut down on one more clone ...
			-- if it's an Expression then rely on the Visitor to return a clone ... only when necessary
			expr = expr:shallowCopy()
		else
			-- TODO shouldn't this be shallowCopy only if it *IS* a mutable object?
			expr = expr:clone()
		end
	end
--]]
--[[ cache visitors & simplification.  does this help?
-- TODO NO
-- because if we change the children ... this flag should get invalidated
-- but where does that change happen?
	-- preserve 'hasBeen' flags.
	-- should I put this copy into clone() itself?
	-- or how about I make sure no in-place modification is used in any visitors, then I can get rid of this clone()
	if origIsExpr then
		for k,v in pairs(orig) do
			if type(k) == 'string'
			and k:match'^hasBeen' then
				expr[k] = v
			end
		end
	end
--]]


-- [[ make expr write-protected
	if not Expression:isa(expr) then
		error("after clone failed to find an expression:\n"..require 'ext.tolua'(expr))
	end
	if not expr.mutable then
		expr.writeProtected = true
	end
--]]

	local t = type(expr)
	if t == 'table' then
		local m = getmetatable(expr)
		assert(m, "got back a result with no metatable")

		local modifiedChild
		-- bubble-in
		-- nobody's using this right now
		--[[
		local rules = self:lookup(m, true)
		if rules then
			for _,rule in ipairs(rules) do
				local foundRule = m.pushedRules and m.pushedRules[rule]
				if not foundRule then
					local name, func = next(rule)
					local newexpr = func(self, expr, ...)
					if newexpr then
						expr = newexpr
						m = getmetatable(expr)
						assert(m, "got back a result with no metatable")
						break
					end
				end
			end
		end
		--]]

		-- if it's an expression then apply to all children first
		if Expression:isa(m) then
			if expr then
				for i=1,#expr do
					local ch = expr[i]
					if debugVisitors then
						print(id, 'simplifying child #'..i)
					end
					local newch = self:apply(ch, ...)
					expr[i] = newch
					if not rawequal(ch, newch) then
						modifiedChild = true
					end
				end
			end
		end
		-- traverse class parentwise til a key in the lookup table is found
		-- stop at null

		-- bubble-out

		-- only here, copy hasBeen* flags if no children were modified
		if not modifiedChild then
			if origIsExpr then
				for k,v in pairs(orig) do
					if type(k) == 'string'
					and k:match'^hasBeen' then
						expr[k] = v
					end
				end
			end
		end

		-- if we found an entry then apply it
--DEBUG(@5):local rulesSrcNodeName = m.name
--DEBUG(@5):assert(rulesSrcNodeName ~= 'Expression')
		local rules = self:lookup(m)
		if rules then
			for _,rule in ipairs(rules) do
				-- TODO why pushedRules?  why not just ... push the rules?
				-- probably because subclasses flatten, so if you push a superclass from the table then the subclass will still have it.
				-- TODO iterate through subclasses?  you can use 'isaSet' defined in ext.class for this.
				if not m.pushedRules
				or not m.pushedRules[rule]
				then
					local name, func = next(rule)

--DEBUG(@5):local beforeCount = Expression.countNodes(expr)

					local newexpr = func(self, expr, ...)
					if newexpr then
						expr = newexpr

						if symmath.simplify.debugLoops == 'rules'
						and symmath.simplify.stack
						then
							symmath.simplify.stack:insert{m.name..':'..self.name..':'..name, symmath.clone(newexpr)}
						end

--DEBUG(@5):local afterCount = Expression.countNodes(expr)
--DEBUG(@5):local changeKey = (rulesSrcNodeName or '?') .. ' ' .. (self.name or '?') .. ' ' .. name
--DEBUG(@5):changeInNodes[changeKey] = (changeInNodes[changeKey] or 0) + afterCount - beforeCount
						-- if we change content then there's no guarantee the metatable -- or the rules -- will be the same
						-- we probably need to start again
						m = getmetatable(expr)
						assert(m, "got back a result with no metatable")
--DEBUG(@5):rulesSrcNodeName = m.name
--DEBUG(@5):assert(rulesSrcNodeName ~= 'Expression')
						break
					--[[ should I insert this in the stack even if it wasn't applied?
					-- yes?  since the function calls are inserted even if they don't produce anything new
					-- but i'll disable it, it inserts way too many, and the unused rules can be inferred by just scrolling down the rule list.
					else
						if symmath.simplify.debugLoops == 'rules'
						and symmath.simplify.stack
						then
							symmath.simplify.stack:insert{m.name..':'..self.name..':'..name..' not used', symmath.clone(expr)}
						end
					--]]
					end
				end
			end
		end
	end
	if debugVisitors then
		print(id, 'done pruning with', Verbose(expr))
	end
--DEBUG(@5):print('prune', require 'symmath.export.SingleLine'(x))
--DEBUG(@5):if next(changeInNodes) then
--DEBUG(@5):	print(self.name..' size', expr:countNodes(), 'changed by', require 'ext.tolua'(changeInNodes))
--DEBUG(@5):end

	if self.rememberVisit then
-- [[ cache visitors & simplification.  does this help?
		if not expr.mutable then
--DEBUG(@5):print(self.hasBeenField..' from '..symmath.export.SingleLine(orig)..' to '..symmath.export.SingleLine(expr))
			expr[self.hasBeenField] = true
		end
--]]
	end

	return expr
--DEBUG(@5):end, ...))
end

-- wrapping this so child classes can add prefix/postfix custom code apart from the recursive case
function Visitor:__call(expr, ...)
	return self:apply(expr, ...)
end

return Visitor
