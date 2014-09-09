local tableCommutativeEqual = require 'symmath.tableCommutativeEqual'
local function nodeCommutativeEqual(a,b)
	return tableCommutativeEqual(a.xs, b.xs)
end
return nodeCommutativeEqual

