-- https://en.wikipedia.org/wiki/Complex_conjugate
local table = require 'ext.table'
local Function = require 'symmath.Function'
local complex = require 'complex'
local symmath

local Im = Function:subclass()

Im.name = 'Im'

Im.realFunc = function(...) return ... end
Im.cplxFunc = function(c) return c.re end

function Im:evaluateDerivative(deriv, ...)
	local x = self[1]:clone()
	return Im(deriv(x, ...))
end

-- y = Im(x) => i y + const = x
-- hmm this gives us multiple solutions ... how to incorporate that into the :reverse() and :solve() function?
function Im:reverse(soln, index)
	symmath = symmath or require 'symmath'
	return symmath.i * soln
end

Im.getRealDomain = require 'symmath.set.RealSubset'.getRealDomain_real
Im.getRealRange = require 'symmath.set.RealSubset'.getRealDomain_real
Im.evaluateLimit = require 'symmath.Limit'.evaluateLimit_continuousFunction

Im.rules = table(Im.rules, {
	Prune = {
		{apply = function(prune, expr)
			local x = expr[1]
			symmath = symmath or require 'symmath'
			local Constant = symmath.Constant
			local add = symmath.op.add
			local sub = symmath.op.sub
			
			if symmath.set.real:contains(x) then
				return Constant(0)
			end

			if x == symmath.i then
				return Constant(1)
			end

			if Constant:isa(x) then
				if complex:isa(x.value) then
					return Complex(Im.cplxFunc(x.value))
				else
					-- ... real?  just return zero
					return Constant(0)
				end
			end
				
			if add:isa(x)
			or sub:isa(x)
			then
				return prune(getmetatable(x)(table.mapi(x, function(xi)
					return Im(xi)
				end):unpack()))
			end
			
			-- TODO more 
		end},
	},
})

return Im
