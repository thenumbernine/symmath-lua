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
	
	local modified

-- [[ this is failing for numerical-relativity-codegen/show_flux_matrix.lua
	-- here I need to not just test equality, but also portions of equality
	-- esp for commutative equals operators 
	-- bleh, I hate implicitVars ...
	if rawget(getmetatable(expr), 'removeIfContains') then
		local status, removed = expr:removeIfContains(find)
		-- "removed" was originally most likely a BinOp
		-- but its children have been removed
		-- therefore it could reach an invalid state of having 0 or 1 children 
		if status then
--print("# children left", #removed, '<br>')
			-- bit of a hack
			local BinaryOp = require 'symmath.op.Binary'
			if BinaryOp.is(removed) then
				if #removed == 0 then
					expr = repl
				else
					expr = removed
					table.insert(expr, repl)
				end	
			end	
			modified = true
		end
--print("expr is now",expr,'<br>')	
	end
--]]

	-- found find then replace
	if expr == find then return repl end
	
	-- recursive call
	local clone = require 'symmath.clone'
	for i=1,#expr do
		if expr[i] == nil then
			print('this had a nil: '..require 'ext.tolua'(expr))
			print('when replacing '..tostring(find))
			print(' with '..tostring(repl))
			error'here'
		end
		local replexpri = replace(expr[i], find, repl, cond)
		if replexpri then
			if not modified then		-- clone before modifying children
				expr = clone(expr)
				modified = true
			end
			expr[i] = replexpri
		end
	end
	if modified then
		return expr
	end
end

local function replace(expr, ...)
	assert(expr)
	return replaceRecurse(expr, ...) or expr
end

return replace
