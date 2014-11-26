--[[
expr = expression to change
callback(node) = callback that returns nil if it leaves the tree untouched, returns a value if it wishes to change the tree
--]]
local function map(expr, callback)
	-- clone
	if expr.clone then expr = expr:clone() end
	-- process children
	if expr then
		for i=1,#expr do
			expr[i] = map(expr[i], callback)
		end
	end
	-- process this node
	expr = callback(expr) or expr
	-- done
	return expr
end

return map

