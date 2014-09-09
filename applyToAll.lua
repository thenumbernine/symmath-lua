local map = require 'symmath.map'
local function applyToAll(funcName, tree, ...)
	local args = {...}
	return map(tree, function(x)
		if x[funcName] then
			return x[funcName](x, unpack(args))
		end
	end)
end
return applyToAll

