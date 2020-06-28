local class = require 'ext.class'
local table = require 'ext.table'
local range = require 'ext.range'
local Expression = require 'symmath.Expression'

local Integral = class(Expression)
Integral.name = 'Integral'

-- Integral:init(expr, var[, start, finish])
function Integral:expr() return self[1] end
function Integral:var() return self[2] end
function Integral:start() return self[3] end
function Integral:finish() return self[4] end

--[[
I need a new system for pattern-matching
--]]

Integral.rules = {
	-- TODO numerical integration methods
	Eval = {
		{apply = function(eval, expr)
			error("cannot evaluate integral "..tostring(expr)..".  try replace()ing integrals.")
		end},
	},

	Prune = {
		{apply = function(prune, expr)
			local symmath = require 'symmath'
			local Constant = symmath.Constant
			local Variable = symmath.Variable
			local add = symmath.op.add
			local mul = symmath.op.mul
			local div = symmath.op.div
			local pow = symmath.op.pow
			local map = symmath.map
			local log = symmath.log
			local exp = symmath.exp
			local abs = symmath.abs

			local int, x, start, finish = table.unpack(expr)

			if start and finish then
				local orig = expr
				expr = prune(Integral(int, x))
				-- TODO ... I would like to know if the result was integrated, but how
				-- if a scalar was factored out then expr won't necessarily be an integral - but one of its children will
				-- but if we simply detect a child integral to short-circuit then what if we are using an integral whose definition is another integral?
				local hasInt
				expr:map(function(ch) 
					hasInt = hasInt or Integral.is(ch) 
				end)
				-- and if we do want prune to map integrals to integrals, it would be nice to know the new integral (with constants factored out) so I can re-substitute the bounds
				--if hasInt then return expr end	-- loses the bounds
				-- so doing this saves us from errors, but prevents constants from being factored out
				if hasInt then return orig end

				-- but don't replace the variable of Integral's
				-- TODO and here we need function evaluation, 
				-- for a variable 'v' dependent on x, if we don't have an evaluation expression then we just simplify v - v = 0
				local function replaceDefinite(ex, with)
					return ex:replace(x, with, function(ei)
						return Integral.is(ei) 
					end)
				end
				local defFin = replaceDefinite(expr, finish)
				local defStart = replaceDefinite(expr, start)
				return defFin - defStart
			end
			
			-- TODO make this canonical form?
			int = int():factorDivision()

			if symmath.op.Equation.is(int) 
			or add.is(int)
			or symmath.Array.is(int)
			then
				return setmetatable(table.mapi(int, function(xi)
					return prune(Integral(xi, table.unpack(expr, 2)))
				end), getmetatable(int))
			end

			-- TODO convert away divisions first ... convert into ^-1's

			local Wildcard = require 'symmath.Wildcard'
			local sin = require 'symmath.sin'
			local cos = require 'symmath.cos'
			local sinh = require 'symmath.sinh'
			local cosh = require 'symmath.cosh'
			local div = require 'symmath.op.div'
			local frac = div


			-- int(c) = c x
			if int:match(Wildcard{1, cannotDependOn=x}) then
				return int * x
			end
			
			-- TODO Technically by this point we should have c * f(x), otherwise the previous capture should have got it
			-- which means I could simply test if this fails, to treat it like it is an integral of a constant.
			--
			-- int(c * f(x))
			local f, c = int:match(Wildcard{index=2, cannotDependOn=x} * Wildcard{1, dependsOn=x})
--local Verbose = require 'symmath.export.Verbose'
--print('f', f and Verbose(f) or tostring(f))
--print('c', c and Verbose(c) or tostring(c))
			if f then
				

				-- https://en.wikipedia.org/wiki/Lists_of_integrals


				-- int(c * x)
				if f == x then
					return (c / 2) * x^2
				end
			
				-- int(c * x^n)
				local n = f:match(x^Wildcard{1, cannotDependOn=x})
				if n then
					--int(c * x^-1)
					if Constant.isValue(n, -1) then
						return c * log(abs(x))
					else
						return (c / (n+1)) * x^(n+1)
					end
				end
			
				-- int(c / x)
				local d = f:match(1 / (Wildcard{1, cannotDependOn=x} * x))
				if d then
					return (c / d) * log(abs(x))
				end

				-- int(c / x^n)
				local d, n = f:match(1 / (Wildcard{1, cannotDependOn=x} * x^Wildcard{2, cannotDependOn=x}))
				if d then
					if Constant.isValue(n, 1) then
						return frac(c, d) * log(abs(x))
					else
						return (c / ((1-n) * d)) * x^(1-n)
					end
				end


				-- https://en.wikipedia.org/wiki/List_of_integrals_of_rational_functions

				
				local dg, g = f:match(Wildcard(1) / Wildcard(2))
				if dg then
					if Constant.isValue((g:diff(x) - dg)(), 0) then
						return c * log(abs(g))
					end
				end


				-- int(1/(x*(a*x+b)))
				-- if int is :simplify() then this will match:
				--local a, b = f:match(1 / (x * (Wildcard{1, cannotDependOn=x} * x + Wildcard{2, cannotDependOn=x})))
				-- but if int is :factorDivision() then this should match:
				local a, b = f:match(1 / (Wildcard{1, cannotDependOn=x} * x * x + Wildcard{2, cannotDependOn=x} * x))
				if a then
					return -frac(c, b) * log(abs((a * x + b) / x))
				end

				--[[ TODO this match is failing
				local a, b, c = f:match(x / (Wildcard{1, cannotDependOn=x} * x * x + Wildcard{2, cannotDependOn=x} * x + Wildcard{3, cannotDependOn=x}))
				if a then
				end
				--]]


				-- https://en.wikipedia.org/wiki/List_of_integrals_of_exponential_functions


				local a = f:match(exp(Wildcard{1, cannotDependOn=x} * x))
				if a then
					return frac(c, a) * exp(a * x)
				end

				-- int( dg/dx * exp(g(x)))
				local dg, g = f:match(Wildcard(1) * exp(Wildcard(2)))
				if dg then
					if Constant.isValue( (g:diff(x) - dg)(), 0) then
						local expg = exp(g)()
						--if f() == (dg * f)() then	-- TODO better equality test? 
						if Constant.isValue((f - dg * expg)(), 0) then
							return c * expg
						end
					end
				end

				-- int(c / n^x)
				local n = f:match(1 / Wildcard{1, cannotDependOn=x}^x)
				if n then
					return -c / (log(n) * n^x)
				end

				-- int(c * n^x)
				local n = f:match(Wildcard{1, cannotDependOn=x}^x)
				if n then
					return (c / log(n)) * n^x
				end


				-- https://en.wikipedia.org/wiki/List_of_integrals_of_trigonometric_functions
				
				-- ...involving only sine


				-- int(c*sin(a*x))
				local a = f:match(sin(Wildcard{1, cannotDependOn=x} * x))
				if a then
					return -frac(c,a) * cos(a * x)
				end
			
				-- int(c*sin(a*x)^2)
				local a = f:match(sin(Wildcard{1, cannotDependOn=x} * x)^2)
				if a then
					return c/2 * (x - 1/(2*a) * sin(2*a*x))
					-- equivalently:
					--return c/2 * (x - 1/a * sin(a*x) * cos(a*x))
				end

				-- int(c * x * sin(a * x))
				local a = f:match(x * sin(Wildcard{1, cannotDependOn=x} * x))
				if a then
					return sin(a * x) / a^2 - (x * cos(a * x)) / a
				end

				-- int(sin(b1*x) * sin(b2*x)), b1 != b2
				local b1, b2 = f:match(sin(Wildcard{1, cannotDependOn=x} * x) * sin(Wildcard{2, cannotDependOn=x} * x))
				if b1 then
					-- if b1 == b2 then it would simplify to sin(b1*x)^2 ... right?
					assert(b1 ~= b2)
					return sin((b2 - b1) * x)/(2 * (b2 - b1)) - sin((b2 + b1) * x)/(2 * (b2 + b1)) 
				end


				-- ...involving only cosine


				-- int(c*cos(a*x))
				local a = f:match(cos(Wildcard{1, cannotDependOn=x} * x))
				if a then
					return frac(c,a) * sin(a * x)
				end

				-- int(c*cos(a*x)^2)
				local a = f:match(cos(Wildcard{1, cannotDependOn=x} * x)^2)
				if a then
					return c/2 * (x + 1/(2*a) * sin(2*a*x))
					-- equivalently
					--return c/2 * (x + 1/a * sin(a*x) * cos(a*x))
				end

				-- int(c * x * cos(a * x))
				local a = f:match(x * cos(Wildcard{1, cannotDependOn=x} * x))
				if a then
					return cos(a * x) / a^2 + (x * sin(a * x)) / a
				end

				-- int(cos(a1*x) * cos(a2*x)), a1 != a2
				local a1, a2 = f:match(cos(Wildcard{1, cannotDependOn=x} * x) * cos(Wildcard{2, cannotDependOn=x} * x))
				if a1 then
					-- if a1 == a2 then it would simplify to cos(a1*x)^2 ... right?
					assert(a1 ~= a2)
					return sin((a2 - a1) * x)/(2 * (a2 - a1)) + sin((a2 + a1) * x)/(2 * (a2 + a1)) 
				end


				-- sine and cosine
				

				-- int(sin(a1*x) * cos(a2*x))
				local a1, a2 = f:match(sin(Wildcard{1, cannotDependOn=x} * x) * cos(Wildcard{2, cannotDependOn=x} * x))
				if a1 then
					if a1 == a2 then
						return sin(a1 * x)^2 / (2 * a1)
					else
						return cos((a1 - a2) * x) / (2 * (a1 - a2)) - cos((a1 + a2) * x) / (2 * (a1 + a2))
					end
				end

				-- int(tan(a * x))
				-- int(sin(a * x) / cos(a * x))
				local a = f:match(sin(Wildcard{1, cannotDependOn=x} * x) * (1 / cos(Wildcard{1, cannotDependOn=x} * x)))
				if a then
					return -frac(c, a) * log(abs(cos(a * x)))
				end

				-- int(cot(a * x))
				-- int(cos(a * x) / sin(a * x))
				local a = f:match(cos(Wildcard{1, cannotDependOn=x} * x) * (1 / sin(Wildcard{1, cannotDependOn=x} * x)))
				if a then
					return frac(c, a) * log(abs(sin(a * x)))
				end


				-- https://en.wikipedia.org/wiki/List_of_integrals_of_hyperbolic_functions
				-- hyperbolic sine


				-- int(c*sinh(a*x))
				local a = f:match(sinh(Wildcard{1, cannotDependOn=x} * x))
				if a then
					return frac(c,a) * cosh(a * x)
				end


				-- hyperbolic cosine


				-- int(c*cosh(a*x))
				local a = f:match(cosh(Wildcard{1, cannotDependOn=x} * x))
				if a then
					return frac(c,a) * sinh(a * x)
				end


				-- hyperbolic sine and hyperbolic cosine


				-- int(tanh(a*x))
				-- int(sinh(a*x)/cosh(a*x))
				local a = f:match(sinh(Wildcard{1, cannotDependOn=x} * x) * (1 / cosh(Wildcard{1, cannotDependOn=x} * x)))
				if a then
					return frac(c, a) * log(abs(cosh(a * x)))
				end

				-- int(coth(a*x))
				-- int(cosh(a*x)/sinh(a*x))
				local a = f:match(cosh(Wildcard{1, cannotDependOn=x} * x) * (1 / sinh(Wildcard{1, cannotDependOn=x} * x)))
				if a then
					return frac(c, a) * log(abs(sinh(a * x)))
				end

			end
		end},
	},
}

return Integral
