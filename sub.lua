local class = require 'ext.class'
local BinaryOp = require 'symmath.BinaryOp'

local sub = class(BinaryOp)
sub.precedence = 2
sub.name = '-'

function sub:evaluateDerivative(...)
	local a, b = table.unpack(self)
	a, b = a:clone(), b:clone()
	local diff = require 'symmath.Derivative'
	local x = diff(a,...) - diff(b,...)
	return x
end

sub.visitorHandler = {
	Eval = function(eval, expr)
		local result = eval:apply(expr[1])
		for i=2,#expr do
			result = result - eval:apply(expr[i])
		end
		return result
	end,
	
	Expand = function(expand, expr)
		local add = require 'symmath.add'
		
		--assert(#expr > 1) -- TODO
		if #expr == 1 then return expand:apply(expr[1]) end

		if #expr == 2 then
			expr = expr[1] + -expr[2]
		else
			expr = expr[1] + -add(table.unpack(expr[2]))
		end
		return expand:apply(expr)
	end,
	
	Prune = function(prune, expr)
		return prune:apply(expr[1] + (-expr[2]))
	end,
}
-- ExpandPolynomial inherits from Expand
sub.visitorHandler.ExpandPolynomial = sub.visitorHandler.Expand

return sub
