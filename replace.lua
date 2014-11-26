--[[
expr = expression to change
find = sub-expression to find
repl = sub-expression to replace
callback(node) = callback per node, returns 'true' if we don't want to find/replace this tree

TODO rewrite to use symmath.map() ?
--]]
local function replace(expr, find, repl, callback)
	local clone = require 'symmath.clone'
	
	-- callback saya to short circuit search
	if callback and callback(expr) then return clone(expr) end
	
	-- found find then replace
	if expr == find then return clone(repl) end
	
	-- recursive call
	expr = clone(expr)
	for i=1,#expr do
		expr[i] = replace(expr[i], find, repl, callback)
	end
	return expr
end
return replace

