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
		
		-- same as in Derivative, conj, Im
		-- f({y_i}) = {f(y_i)}
		{arrays = function(prune, expr)
			symmath = symmath or require 'symmath'
			local Array = symmath.Array
			if Array:isa(expr[1]) then
				local res = expr[1]:clone()
				for i=1,#res do
					res[i] = prune:apply(getmetatable(expr)(res[i], table.unpack(expr, 2)))
				end
				return res
			end
		end},


		{apply = function(prune, expr)
			local x = expr[1]
			symmath = symmath or require 'symmath'
			local Constant = symmath.Constant
			local unm = symmath.op.unm
			local add = symmath.op.add
			local sub = symmath.op.sub
			local mul = symmath.op.mul
			
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
				
			if unm:isa(x)
			or add:isa(x)
			or sub:isa(x)
			then
				return prune(getmetatable(x)(table.mapi(x, function(xi)
					return Re(xi)
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
				
				-- Re(a * b) = a * Re(b) so long as a is real
				-- ofc that means they're just a * b anyways so ...
				if symmath.set.real:contains(x[1]) then
					return prune(x[1] * Re(prod(table.unpack(x, 2))))
				end
				-- same with right-multiply
				if symmath.set.real:contains(x[#x]) then
					return prune(Re(prod(table.unpack(x, 1, #x-1))) * x[#x])
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
				local Im = symmath.Im
				return prune(Re(a) * Re(b) - Im(a) * Im(b))
				--]]
			end
			
			-- TODO more 
		end},
	},
})

return Re
