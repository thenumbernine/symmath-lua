local class = require 'ext.class'
local table = require 'ext.table'
local Expression = require 'symmath.Expression'
local symmath

local unm = class(Expression)
unm.precedence = 3	--4	--make it match mul and div so there aren't extra parenthesis around mul and div
unm.name = 'unm'	-- hmm, same name as sub ... is that a problem?

function unm:evaluateDerivative(deriv, ...)
	local x = unpack(self):clone()
	return -deriv(x, ...)
end

function unm:reverse(soln, index)
	return -soln
end

function unm:getRealDomain()
	if self.cachedSet then return self.cachedSet end
	local I = self[1]:getRealDomain()
	if I == nil then 
		self.cachedSet = nil 
		return nil
	end
	self.cachedSet = -I
	return self.cachedSet
end

unm.rules = {
	Eval = {
		{apply = function(eval, expr)
			return -eval:apply(expr[1])
		end},
	},

	Expand = {
		{apply = function(expand, expr)
			return expand:apply(-1 * expr[1])
		end},
	},

	FactorDivision = {
		{apply = function(factorDivision, expr)
			return factorDivision:apply(-1 * expr[1])
		end},
	},

	Prune = {
		{apply = function(prune, expr)
			if unm:isa(expr[1]) then
				return prune:apply(expr[1][1]:clone())
			end
			return prune:apply(-1 * expr[1])
		end},
	},

	Tidy = {
		{apply = function(tidy, expr)
			symmath = symmath or require 'symmath'
			local add = symmath.op.add
			
			-- --x => x
			if unm:isa(expr[1]) then
				return tidy:apply(expr[1][1])
			end
			
			-- distribute through addition/subtraction
			if add:isa(expr[1]) then
				return add(table.mapi(expr[1], function(x) return -x end):unpack())
			end
		end},
	},
}
-- ExpandPolynomial inherits from Expand
unm.rules.ExpandPolynomial = unm.rules.Expand

return unm
