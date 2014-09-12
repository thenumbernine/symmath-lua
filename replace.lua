--[[
expr = expression to change
find = sub-expression to find
repl = sub-expression to replace
callback(node) = callback per node, returns 'true' if we don't want to find/replace this tree
--]]
local function replace(expr, find, repl, callback)
	local clone = require 'symmath.clone'
	if callback and callback(expr) then return clone(expr) end
	if expr.xs then
		local xs = table()
		for i=1,#expr.xs do
			local ch = replace(expr.xs[i],find,repl,callback)
			if ch == find then
				xs:insert(clone(repl))
			else
				xs:insert(ch)
			end
		end
		return getmetatable(expr)(unpack(xs))
	else
		return clone(expr)
	end
end
return replace

