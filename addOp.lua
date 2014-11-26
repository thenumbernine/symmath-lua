require 'ext'
local BinaryOp = require 'symmath.BinaryOp'
local Function = require 'symmath.Function'
local Constant = require 'symmath.Constant'
local tableCommutativeEqual = require 'symmath.tableCommutativeEqual'

local addOp = class(BinaryOp)
addOp.precedence = 2
addOp.name = '+'

function addOp:evaluateDerivative(...)
	local diff = require 'symmath'.diff
	local result = addOp()
	for i=1,#self do
		result[i] = diff(self[i]:clone(), ...)
	end
	return result
end

addOp.__eq = require 'symmath.nodeCommutativeEqual'

return addOp

