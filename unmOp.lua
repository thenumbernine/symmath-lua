local class = require 'ext.class'
local Expression = require 'symmath.Expression'

local unmOp = class(Expression)
unmOp.precedence = 3	--4	--make it match mul and div so there aren't extra parenthesis around mul and div

function unmOp:evaluateDerivative(...)
	local x = unpack(self):clone()
	local diff = require 'symmath'.diff
	return -diff(x,...)
end

unmOp.visitorHandler = {
	Eval = function(eval, expr)
		return -eval:apply(expr[1])
	end,

	Expand = function(expand, expr)
		return expand:apply(-1 * expr[1])
	end,
	
	FactorDivision = function(factorDivision, expr)
		return factorDivision:apply(-1 * expr[1])
	end,

	Prune = function(prune, expr)
		if unmOp.is(expr[1]) then
			return prune:apply(expr[1][1]:clone())
		end
		return prune:apply(-1 * expr[1])
	end,

	Tidy = function(tidy, expr)
		local addOp = require 'symmath.addOp'
		
		-- --x => x
		if unmOp.is(expr[1]) then
			return tidy:apply(expr[1][1])
		end
		
		-- distribute through addition/subtraction
		if addOp.is(expr[1]) then
			return addOp(table.map(expr[1], function(x,k) 
				if type(k) ~= 'number' then return end
				return -x 
			end):unpack())
		end
	end,
}
-- ExpandPolynomial inherits from Expand
unmOp.visitorHandler.ExpandPolynomial = unmOp.visitorHandler.Expand

return unmOp
