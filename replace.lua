--[[
expr = expression to change
find = sub-expression to find
repl = sub-expression to replace
cond(node) = condition per node, returns 'true' if we don't want to find/replace this tree

TODO rewrite to use symmath.map() ?
--]]
local function replaceRecurse(expr, find, repl, cond)
	local Constant = require 'symmath.Constant'
	if type(find) == 'number' then
		find = Constant(find)
	end
	if repl == nil then 
		error("expected to have something to replace, got nil")
	elseif type(repl) == 'number' then
		repl = Constant(repl)
	end

	-- cond returns true to short circuit search
	if cond and cond(expr) then return end

--[[ this is failing for numerical-relativity-codegen/show_flux_matrix.lua
	-- here I need to not just test equality, but also portions of equality
	-- esp for commutative equals operators 
	-- bleh, I hate implicitVars ...
	if rawget(getmetatable(expr), 'removeIfContains') then
		local status, removed = expr:removeIfContains(find)
		if status then
			-- bit of a hack
			local BinaryOp = require 'symmath.op.Binary'
			if BinaryOp.is(removed) and #removed == 0 then
				expr = repl
			else
				expr = removed
				table.insert(expr, repl)
			end	
		end
	end
--]]

	-- found find then replace
	if expr == find then return repl end
	
	-- recursive call
	local clone = require 'symmath.clone'
	local cloned
	for i=1,#expr do
		assert(expr[i])
		local replexpri = replace(expr[i], find, repl, cond)
		if replexpri then
			if not cloned then		-- clone before modifying children
				expr = clone(expr)
				cloned = true
			end
			expr[i] = replexpri
		end
	end
	if cloned then
		return expr
	end
end

local function replace(expr, ...)
	assert(expr)
	return replaceRecurse(expr, ...) or expr
end

return replace
