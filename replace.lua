--[[
expr = expression to change
find = sub-expression to find
repl = sub-expression to replace
callback(node) = callback per node, returns 'true' if we don't want to find/replace this tree

TODO rewrite to use symmath.map() ?
--]]
local function replace(expr, find, repl, callback)
	local clone = require 'symmath.clone'
	if callback and callback(expr) then return clone(expr) end
	if #expr > 0 then
		local newChildren = table()
		for i=1,#expr do
			local ch = replace(expr[i], find, repl, callback)
			if ch == find then
				newChildren:insert(clone(repl))
			else
				newChildren:insert(ch)
			end
		end
		return getmetatable(expr)(unpack(newChildren))
	else
		return clone(expr)
	end
end
return replace

