local table = require 'ext.table'
local Expression = require 'symmath.Expression'
local symmath

local unm = Expression:subclass()
unm.precedence = 3	--4	--make it match mul and div so there aren't extra parenthesis around mul and div
unm.name = 'unm'	-- hmm, same name as sub ... is that a problem?

function unm:evaluateDerivative(deriv, ...)
	local x = table.unpack(self):clone()
	return -deriv(x, ...)
end

function unm:reverse(soln, index)
	return -soln
end

function unm:getRealRange()
	if self.cachedSet then return self.cachedSet end
	local I = self[1]:getRealRange()
	if I == nil then
		self.cachedSet = nil
		return nil
	end
	self.cachedSet = -I
	return self.cachedSet
end

unm.rules = {
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
		{doubleNegative = function(prune, expr)
			if unm:isa(expr[1]) then
				return prune:apply(expr[1][1]:clone())
			end
			return prune:apply(-1 * expr[1])
		end},

--[[ hmm, not needed as long as I use this x = x:itermul()() rule in div/Prune/negOverNeg
		{negOfMaybeNegOverMaybeNeg = function(prune, expr)
			-- a similar rule is in div that turns -a / -b => a/b
			-- but this one is directed at -(-a/b) => -(a/-b) => a/b
			local p, q = table.unpack(expr)
			local np = p:hasLeadingMinus()
			local nq = q:hasLeadingMinus()
			if np and not nq then
				return prune:apply(-p) / q
			elseif not np and nq then
				return p / prune:apply(-q)
			end
		end},
--]]

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
