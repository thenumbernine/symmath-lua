-- https://en.wikipedia.org/wiki/Complex_conjugate
local table = require 'ext.table'
local Function = require 'symmath.Function'
local complex = require 'complex'
local symmath

local Re = Function:subclass()

Re.name = 'Re'

Re.realFunc = function(...) return ... end
Re.cplxFunc = function(c) return c.re end

function Re:evaluateDerivative(deriv, ...)
	local x = self[1]:clone()
	return Re(deriv(x, ...))
end

-- y = Re(x) => y + i * const = x
-- hmm this gives us multiple solutions ... how to incorporate that into the :reverse() and :solve() function?
function Re:reverse(soln, index)
	return soln
end

Re.getRealDomain = require 'symmath.set.RealSubset'.getRealDomain_real
Re.getRealRange = require 'symmath.set.RealSubset'.getRealDomain_real
Re.evaluateLimit = require 'symmath.Limit'.evaluateLimit_continuousFunction

Re.rules = table(Re.rules, {
	Prune = {
		{apply = function(prune, expr)
			local x = expr[1]
			symmath = symmath or require 'symmath'
			local Constant = symmath.Constant
			local Variable = symmath.Variable
			local add = symmath.op.add
			local sub = symmath.op.sub
			
			if symmath.set.real:contains(x) then
				return x
			end

			if x == symmath.i then
				return Constant(0)
			end

			if Constant:isa(x) then
				if complex:isa(x.value) then
					return Complex(Re.cplxFunc(x.value))
				else
					-- ... real?  just return itself
					return x
				end
			end
				
			if add:isa(x)
			or sub:isa(x)
			then
				return prune(getmetatable(x)(table.mapi(x, function(xi)
					return Re(xi)
				end):unpack()))
			end
			
			-- TODO more 
		end},
	},
})

return Re
