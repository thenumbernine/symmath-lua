--[[
expr = expression to change
find = sub-expression to find
repl = sub-expression to replace
cond(node) = condition per node, returns 'true' if we don't want to find/replace this tree

TODO rewrite to use symmath.map() ?
--]]
local function replace(expr, find, repl, cond)
	local Constant = require 'symmath.Constant'
	if type(find) == 'number' then
		find = Constant(find)
	end
	if repl == nil then 
		error("expected to have something to replace, got nil")
	elseif type(repl) == 'number' then
		repl = Constant(repl)
	end
	
	local clone = require 'symmath.clone'
	
	-- cond returns true to short circuit search
	if cond and cond(expr) then return clone(expr) end
	
	-- found find then replace
	if expr == find then return clone(repl) end
	
	-- recursive call
	expr = clone(expr)
	for i=1,#expr do
		expr[i] = replace(expr[i], find, repl, cond)
	end
	return expr
end

return replace
