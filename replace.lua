--[[
expr = expression to change
find = sub-expression to find
repl = sub-expression to replace
cond(node) = condition per node, returns 'true' if we don't want to find/replace this tree

TODO rewrite to use symmath.map() ?
TODO rewrite to use symmath.match() ?  But match() returns matched objects ... I don't think it returns indexes/paths into expression trees to look them up (for the sake of replacing them)
--]]
local function replaceRecurse(expr, find, repl, cond)
	local Constant = require 'symmath.Constant'
	if Constant.isNumber(find) then
		find = Constant(find)
	end
	if repl == nil then
		error("expected to have something to replace, got nil")
	elseif Constant.isNumber(repl) then
		repl = Constant(repl)
	end

	-- cond returns true to short circuit search
	if cond and cond(expr) then return end

	local modified

-- [[  TODO (a + a + b + b):replace(a + b, x) will fail
	local replacedAll, replacedIndex
	-- here I need to not just test equality, but also portions of equality
	-- esp for commutative equals operators
	if expr.removeIfContains then
		local status, removed = expr:removeIfContains(find)
		-- "removed" was originally most likely a BinOp
		-- but its children have been removed
		-- therefore it could reach an invalid state of having 0 or 1 children
		if status then
--DEBUG(@5):print("# children left", #removed, '<br>')
			-- bit of a hack
			local BinaryOp = require 'symmath.op.Binary'
			if BinaryOp:isa(removed) then
				if #removed == 0 then
					expr = repl
					replacedAll = true
				else
					expr = removed
					table.insert(expr, repl)
					replacedIndex = #expr
				end
			end
			modified = true
		end
--DEBUG(@5):print("expr is now",expr,'<br>')
	end
	if replacedAll then return expr end
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
		-- don't recursively apply our replace() to the replaced result
		if i ~= replacedIndex then
			local replexpri = replaceRecurse(expr[i], find, repl, cond)
			if replexpri then
				if not modified then		-- clone before modifying children
					expr = clone(expr)
					modified = true
				end
				expr[i] = replexpri
			end
		end
	end
	if modified then
		return expr
	end
end

local function replace(expr, ...)
	assert(expr)
	local result = replaceRecurse(expr, ...)
	if not result then return expr end
	result = result:flatten() or result
	return result
end

return replace
