require 'ext'
local BinaryOp = require 'symmath.BinaryOp'
local nodeCommutativeEqual = require 'symmath.nodeCommutativeEqual'
local diff = require 'symmath.diff'

-- equality
-- I would use binary operators for this, but Lua's overloading requires the return value be a boolean
local EquationOp = class(BinaryOp)
EquationOp.__eq = nodeCommutativeEqual

function EquationOp:diff(...)
	local result = getmetatable(self)()
	for i=1,#self.xs do
		result.xs[i] = diff(self.xs[i], ...)
	end
	return result
end

return EquationOp

