local tableCommutativeEqual = require 'symmath.tableCommutativeEqual'
local function nodeCommutativeEqual(a,b)
	return tableCommutativeEqual(a, b)
end
return nodeCommutativeEqual
