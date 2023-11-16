local math = require 'ext.math'	--math.factorial
local Function = require 'symmath.Function'
local symmath

local factorial = Function:subclass()
factorial.name = 'factorial'
factorial.realFunc = math.factorial
factorial.cplxFunc = math.factorial

function factorial:evaluateDerivative(deriv, ...)
	local x = table.unpack(self):clone()
	symmath = symmath or require 'symmath'
	return deriv(x, ...) * error'TODO'
end

function factorial:reverse(soln, index)
	-- TODO
end

-- domain of factorial ... is positive ... integers?
-- but Gamma function ... is reals?
factorial.getRealDomain = require 'symmath.set.RealSubset'.getRealDomain_real
factorial.getRealRange = require 'symmath.set.RealSubset'.getRealDomain_real

factorial.evaluateLimit = require 'symmath.Limit'.evaluateLimit_continuousFunction

factorial.rules = {
	Prune = {
		{apply = function(prune, expr)
			symmath = symmath or require 'symmath'
			local Constant = symmath.Constant
		
			local x = expr[1]
			if Constant:isa(x) then
				return Constant(math.factorial(x.value))
			end
		end},
	},
}

return factorial
