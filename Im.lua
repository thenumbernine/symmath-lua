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
--print('prune Im ', expr)			
			local x = expr[1]
			symmath = symmath or require 'symmath'
			local Constant = symmath.Constant
			local unm = symmath.op.unm
			local add = symmath.op.add
			local sub = symmath.op.sub
			local mul = symmath.op.mul
			
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
				
			if unm:isa(x)
			or add:isa(x)
			or sub:isa(x)
			then
				return prune(getmetatable(x)(table.mapi(x, function(xi)
					return Im(xi)
				end):unpack()))
			end
			
			-- special case for prune()'s of -x
			if mul:isa(x) then
				--[[ only works for reals on the left or right side of the muls
				local function prod(...)
					if select('#', ...) == 1 then return ... end
					return mul(...)
				end
				-- TODO this won't get any in the middle ...
				
				-- Im(a * b) = a * Im(b) so long as a is real
				-- ofc that means they're just a * b anyways so ...
				if symmath.set.real:contains(x[1]) then
					return prune(x[1] * Im(prod(table.unpack(x, 2))))
				end
				-- same with right-multiply
				if symmath.set.real:contains(x[#x]) then
					return prune(Im(prod(table.unpack(x, 1, #x-1))) * x[#x])
				end
				--]]
				-- [[ more flexible, but costs more operations ...
				local a, b
				if #x == 2 then
					a, b = table.unpack(x)
				else
					a = x[1]
					b = mul(table.unpack(x, 2))
				end
				local Re = symmath.Re
				return prune(Re(a) * Im(b) + Im(a) * Re(b))
				--]]
			end

			-- TODO more 
		end},
	},
})

return Im
