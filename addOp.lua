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
	for i=1,#self.xs do
		result.xs[i] = diff(self.xs[i]:clone(), ...)
	end
	return result
end

function addOp:eval()
	local result = 0
	for _,x in ipairs(self.xs) do
		result = result + x:eval()
	end
	return result
end

addOp.__eq = require 'symmath.nodeCommutativeEqual'

return addOp

