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
	for i=1,#self do
		local termRes = mulOp()
		for j=1,#self do
			if i == j then
				table.insert(termRes, diff(self[j]:clone(), ...))
			else
				table.insert(termRes, self[j]:clone())
			end
		end
		table.insert(sumRes, termRes)
	end
	return sumRes
end

mulOp.__eq = nodeCommutativeEqual

return mulOp

