require 'ext'
local Constant = require 'symmath.Constant'
local BinaryOp = require 'symmath.BinaryOp'
local nodeCommutativeEqual = require 'symmath.nodeCommutativeEqual'

mulOp = class(BinaryOp)
mulOp.implicitName = true
mulOp.precedence = 3
mulOp.name = '*'

function mulOp:evaluateDerivative(...)
	local diff = require 'symmath'.diff
	local addOp = require 'symmath.addOp'
	local sumRes = addOp()
	for i=1,#self.xs do
		local termRes = mulOp()
		for j=1,#self.xs do
			if i == j then
				termRes.xs:insert(diff(self.xs[j]:clone(), ...))
			else
				termRes.xs:insert(self.xs[j]:clone())
			end
		end
		sumRes.xs:insert(termRes)
	end
	return sumRes
end

function mulOp:eval()
	local result = 1
	for _,x in ipairs(self.xs) do
		result = result * x:eval()
	end
	return result
end

mulOp.__eq = nodeCommutativeEqual

return mulOp

