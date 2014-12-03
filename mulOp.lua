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

-- now that we've got matrix multilpication, this becomes more difficult...
-- non-commutative objects (matrices) need to be compared in-order
-- commutative objects can be compared in any order
mulOp.__eq = function(a,b)
	-- order-independent
	local a = table(a)
	local b = table(b)
	for ai=#a,1,-1 do
		-- non-commutative compare...
		if not a[ai].mulNonCommutative then
			-- table.find uses == uses __eq which ... should ... only pick bi if it is mulNonCommutative as well (crossing fingers, it's based on the equality implementation)
			local bi = b:find(a[ai])
			if bi then
				a:remove(ai)
				b:remove(bi)
			end
		end
	end
	-- now compare what's left in-order (since it's non-commutative)
	if #a ~= #b then return false end
	for i=1,#a do
		if a[i] ~= b[i] then return false end
	end
	return true
end

return mulOp

