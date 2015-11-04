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
	local sums = table()
	for i=1,#self do
		local terms = table()
		for j=1,#self do
			if i == j then
				terms:insert(diff(self[j]:clone(), ...))
			else
				terms:insert(self[j]:clone())
			end
		end
		if #terms == 1 then
			sums:insert(terms[1])
		else
			sums:insert(mulOp(terms:unpack()))
		end
	end
	if #sums == 1 then
		return sums[1]
	else
		return addOp(sums:unpack())
	end
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

