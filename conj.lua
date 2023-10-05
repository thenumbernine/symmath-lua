-- https://en.wikipedia.org/wiki/Complex_conjugate
local table = require 'ext.table'
local Function = require 'symmath.Function'
local complex = require 'complex'
local symmath

local conj = Function:subclass()

conj.name = 'conj'
-- hmmmm how about an overbar?
--conj.nameForExporterTable = {}
--conj.nameForExporterTable.LaTeX = '\\bar'

conj.realFunc = function(...) return ... end
conj.cplxFunc = complex.conj

function conj:evaluateDerivative(deriv, ...)
	local x = self[1]:clone()
	return conj(deriv(x, ...))
end

-- y = conj(x) => conj(y) = x
function conj:reverse(soln, index)
	return conj(soln)
end

conj.getRealDomain = require 'symmath.set.RealSubset'.getRealDomain_real
conj.getRealRange = require 'symmath.set.RealSubset'.getRealDomain_real

conj.evaluateLimit = require 'symmath.Limit'.evaluateLimit_continuousFunction

conj.rules = table(conj.rules, {
	Prune = {
		{apply = function(prune, expr)
			local x = expr[1]
			symmath = symmath or require 'symmath'
			local Constant = symmath.Constant
			local Variable = symmath.Variable
			local unm = symmath.op.unm
			local add = symmath.op.add
			local sub = symmath.op.sub
			local mul = symmath.op.mul
			local div = symmath.op.div
			local pow = symmath.op.pow
			
			if symmath.set.real:contains(x) then
				return x
			end

			if x == symmath.i then
				return -symmath.i
			end

			if Constant:isa(x) then
				if complex:isa(x.value) then
					return Complex(conj.cplxFunc(x.value))
				else
					-- ... real?  just return itself
					return x
				end
			end

			if unm:isa(x)
			or add:isa(x)
			or sub:isa(x)
			or mul:isa(x)
			then
				return prune(getmetatable(x)(table.mapi(x, function(xi)
					return conj(xi)
				end):unpack()))
			end
		
			if div:isa(x) then
				if x[2]:isValue(0) then
					-- don't evalute conj(x/0) yet ... hmmm
					return
				end
				return prune(div(conj(x[1]), conj(x[2])))
			end
		
			if pow:isa(x)
			and symmath.set.integer:contains(x[2])
			then
				return prune(pow(conj(x[1]), conj(x[2])))
			end
			
			-- TODO more 
		end},
	},
})

return conj
