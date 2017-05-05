local class = require 'ext.class'
local table = require 'ext.table'
local Expression = require 'symmath.Expression'

local unm = class(Expression)
unm.precedence = 3	--4	--make it match mul and div so there aren't extra parenthesis around mul and div

function unm:evaluateDerivative(...)
	local x = unpack(self):clone()
	local diff = require 'symmath.Derivative'
	return -diff(x,...)
end

unm.visitorHandler = {
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
		if unm.is(expr[1]) then
			return prune:apply(expr[1][1]:clone())
		end
		return prune:apply(-1 * expr[1])
	end,

	Tidy = function(tidy, expr)
		local add = require 'symmath.op.add'
		
		-- --x => x
		if unm.is(expr[1]) then
			return tidy:apply(expr[1][1])
		end
		
		-- distribute through addition/subtraction
		if add.is(expr[1]) then
			return add(table.map(expr[1], function(x,k) 
				if type(k) ~= 'number' then return end
				return -x 
			end):unpack())
		end
	end,
}
-- ExpandPolynomial inherits from Expand
unm.visitorHandler.ExpandPolynomial = unm.visitorHandler.Expand

return unm