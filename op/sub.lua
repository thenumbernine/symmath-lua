local Binary = require 'symmath.op.Binary'
local symmath

local sub = Binary:subclass()
sub.precedence = 2
sub.name = '-'

function sub:evaluateDerivative(deriv, ...)
	local result = table()
	for i=1,#self do
		result[i] = deriv(self[i]:clone(), ...)
	end
	return sub(result:unpack())
end

function sub:reverse(soln, index)
	-- y = a_1(x) - a_2 - ... - a_n
	-- => a_1(x) = y + a_2 + ... + a_n
	-- y = a_1 - a_2 - ... - a_j(x) - ... - a_n
	-- => a_j(x) = -y + a_1 - a_2 - ... - a_j-1 - a_j+1 - a_n
	-- so to move to the opposite side of an equation, we sub the first and add the rest
	-- but then, if we're solving for bcd etc, then we negatie the solution
	for k=1,#self do
		if k ~= index then
			if k == 1 then
				soln = soln - self[k]:clone()
			else
				soln = soln + self[k]:clone()
			end
		end
	end
	if index > 1 then soln = -soln end
	return soln
end

function sub:getRealRange()
	if self.cachedSet then return self.cachedSet end
	local I = self[1]:getRealRange()
	if I == nil then
		self.cachedSet = nil
		return nil
	end
	for i=2,#self do
		local I2 = self[i]:getRealRange()
		if I2 == nil then return nil end
		I = I - I2
	end
	self.cachedSet = I
	return self.cachedSet
end

sub.rules = {
	Expand = {
		{apply = function(expand, expr)
			symmath = symmath or require 'symmath'
			local add = symmath.op.add

			--assert(#expr > 1) -- TODO
			if #expr == 1 then
				return expand:apply(expr[1])
			end

			if #expr == 2 then
				expr = expr[1] + -expr[2]
			else
				expr = expr[1] + -add(table.unpack(expr[2]))
			end
			return expand:apply(expr)
		end},
	},

	Prune = {
		{apply = function(prune, expr)
			return prune:apply(expr[1] + (-expr[2]))
		end},
	},
}
-- ExpandPolynomial inherits from Expand
sub.rules.ExpandPolynomial = sub.rules.Expand

return sub
