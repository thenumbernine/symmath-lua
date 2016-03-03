local class = require 'ext.class'
local BinaryOp = require 'symmath.BinaryOp'

local subOp = class(BinaryOp)
subOp.precedence = 2
subOp.name = '-'

function subOp:evaluateDerivative(...)
	local a, b = table.unpack(self)
	a, b = a:clone(), b:clone()
	local diff = require 'symmath'.diff
	local x = diff(a,...) - diff(b,...)
	return x
end

subOp.visitorHandler = {
	Eval = function(eval, expr)
		local result = eval:apply(expr[1])
		for i=2,#expr do
			result = result - eval:apply(expr[i])
		end
		return result
	end,
	
	Expand = function(expand, expr)
		local addOp = require 'symmath.addOp'
		
		--assert(#expr > 1) -- TODO
		if #expr == 1 then return expand:apply(expr[1]) end

		if #expr == 2 then
			expr = expr[1] + -expr[2]
		else
			expr = expr[1] + -addOp(table.unpack(expr[2]))
		end
		return expand:apply(expr)
	end,
	
	Prune = function(prune, expr)
		return prune:apply(expr[1] + (-expr[2]))
	end,
}
-- ExpandPolynomial inherits from Expand
subOp.visitorHandler.ExpandPolynomial = subOp.visitorHandler.Expand

return subOp
