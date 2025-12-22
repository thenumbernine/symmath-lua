local table = require 'ext.table'
local Expression = require 'symmath.Expression'

local Integral = Expression:subclass()

Integral.name = 'Integral'
Integral.nameForExporterTable = {}
Integral.nameForExporterTable.Language = 'integrate'

Integral.precedence = 3.5	-- wrap + and unm

-- Integral:init(expr, var[, start, finish])
function Integral:expr() return self[1] end
function Integral:var() return self[2] end
function Integral:start() return self[3] end
function Integral:finish() return self[4] end

--[[
I need a new system for pattern-matching
--]]

Integral.rules = {
	Prune = {
		{apply = function(prune, expr)
			local symmath = require 'symmath'
			local Constant = symmath.Constant
			local add = symmath.op.add
			local log = symmath.log
			local exp = symmath.exp
			local sqrt = symmath.sqrt
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
					hasInt = hasInt or Integral:isa(ch)
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
						return Integral:isa(ei)
					end)
				end
				local defFin = replaceDefinite(expr, finish)
				local defStart = replaceDefinite(expr, start)
				return defFin - defStart
			end

			-- TODO make this canonical form?
			int = int():factorDivision()

			if symmath.op.Equation:isa(int)
			or symmath.Array:isa(int)
			then
				return setmetatable(table.mapi(int, function(xi)
					return prune(Integral(xi, table.unpack(expr, 2)))
				end), getmetatable(int))
			end

			if add:isa(int) then
				return add(table.mapi(int, function(xi)
					return prune(Integral(xi, table.unpack(expr, 2)))
				end):unpack())
			end

			-- TODO convert away divisions first ... convert into ^-1's

			local Wildcard = require 'symmath.Wildcard'
			local sin = require 'symmath.sin'
			local cos = require 'symmath.cos'
			local sinh = require 'symmath.sinh'
			local cosh = require 'symmath.cosh'
			local div = require 'symmath.op.div'
			local frac = div
			local Derivative = symmath.Derivative


			-- int(c) = c x
			if int:match(Wildcard{1, cannotDependOn=x}) then
				return int * x
			end

			-- TODO Technically by this point we should have c * f(x), otherwise the previous capture should have got it
			-- which means I could simply test if this fails, to treat it like it is an integral of a constant.
			--
			-- int(c * f(x))
			local f, c = int:match(Wildcard{index=2, cannotDependOn=x} * Wildcard{1, dependsOn=x})
--DEBUG(@5):local Verbose = require 'symmath.export.Verbose'
--DEBUG(@5):print('f', f and Verbose(f) or tostring(f))
--DEBUG(@5):print('c', c and Verbose(c) or tostring(c))
			if f then


				-- https://en.wikipedia.org/wiki/Lists_of_integrals


				-- int(c * x)
				if f == x then
					return (c / 2) * x^2
				end

				do	-- int(c * x^n)
					local n = f:match(x^Wildcard{1, cannotDependOn=x})
					if n then
						--int(c * x^-1)
						if Constant.isValue(n, -1) then
							return c * log(abs(x))
						else
							return (c / (n+1)) * x^(n+1)
						end
					end
				end

				do	-- int(c / x)
					local d = f:match(1 / (Wildcard{1, cannotDependOn=x} * x))
					if d then
						return (c / d) * log(abs(x))
					end
				end

				do	-- int(c / x^n)
					local d, n = f:match(1 / (Wildcard{1, cannotDependOn=x} * x^Wildcard{2, cannotDependOn=x}))
					if d then
						if Constant.isValue(n, 1) then
							return frac(c, d) * log(abs(x))
						else
							return (c / ((1-n) * d)) * x^(1-n)
						end
					end
				end

				-- int(c * f:diff(x, ...), x) => c * f:diff(...)
				-- TODO only when f.dependentVars is x alone
				-- but in that case, the rest of the ...'s had better be x's as well, or else the derivative will evaluate to zero
				-- TODO how about instead int(c * Derivative(f, ...)) => Derivative(c * int(f))
				if Derivative:isa(f) then
					local index
					for i=2,#f do
						if f[i] == x then
							index = i
							break
						end
					end
					if index then
						-- no other derivatives?  return the object of differentiation
						if #f == 2 then
							return c * f[1]
						-- other derivs?  remove this and preserve the rest
						else
							f = f:clone()
							table.remove(f, index)
							return c * f
						end
					end
				end


				-- https://en.wikipedia.org/wiki/List_of_integrals_of_rational_functions


				do	-- int(f'(x)/f(x))
					local dgpat, g = f:match(Wildcard(1) * (1 / Wildcard(2)))
--DEBUG(@5):print('dgpat', dgpat and Verbose(dgpat) or tostring(dgpat))
--DEBUG(@5):print('g', g and Verbose(g) or tostring(g))
					if dgpat then
						local dgcalc = g:diff(x)()
						if not Constant.isValue(dgcalc, 0) then
							local ratio = (dgcalc / dgpat)()
--DEBUG(@5):print('ratio', ratio and Verbose(ratio) or tostring(ratio))
							if not ratio:dependsOn(x) then
								return frac(c, ratio) * log(abs(g))
							end
						end
					end
				end

				do	-- TODO when do we want powers in the denominator and when do we want expanded terms?
					-- this is 1/(x^2 + W(1)), next is 1/(x*x + x*W(1)), the difference is whether the 'x' could be factored out and then re-distributed
					local a = f:match(1 / (x^2 + Wildcard{1, cannotDependOn=x}))
					if a then
--						if symmath.set.negativeReal:contains(a) then
							local sqrtnega = sqrt(-a)()
							return frac(c, 2*sqrtnega) * log(abs( (x - sqrtnega)/(x + sqrtnega) ))
--						end
--						local sqrta = sqrt(a)()
--						return frac(c, sqrta) * atan(frac(x, sqrta))
					end
				end

				do	-- int(1/(x*(a*x+b)))
					-- if int is :simplify() then this will match:
					--local a, b = f:match(1 / (x * (Wildcard{1, cannotDependOn=x} * x + Wildcard{2, cannotDependOn=x})))
					-- but if int is :factorDivision() then this should match:
					local a, b = f:match(1 / (Wildcard{1, cannotDependOn=x} * x * x + Wildcard{2, cannotDependOn=x} * x))
					if a then
						return -frac(c, b) * log(abs((a * x + b) / x))
					end
				end

				--[[ this is an ugly conditional one
				-- I should get better conditional (/piecewise?) expressions working before embarking on this.
				local a, b, d = f:match(x / (Wildcard{1, cannotDependOn=x} * x * x + Wildcard{2, cannotDependOn=x} * x + Wildcard{3, cannotDependOn=x}))
				if a then

				end
				--]]


				-- https://en.wikipedia.org/wiki/List_of_integrals_of_exponential_functions

				do
					local a = f:match(exp(Wildcard{1, cannotDependOn=x} * x))
					if a then
						return frac(c, a) * exp(a * x)
					end
				end

				do	-- int( dg/dx * exp(g(x)))
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
				end

				do	-- int(c / n^x)
					local n = f:match(1 / Wildcard{1, cannotDependOn=x}^x)
					if n then
						return -c / (log(n) * n^x)
					end
				end

				do	-- int(c * n^x)
					local n = f:match(Wildcard{1, cannotDependOn=x}^x)
					if n then
						return (c / log(n)) * n^x
					end
				end


				-- https://en.wikipedia.org/wiki/List_of_integrals_of_trigonometric_functions

				-- ...involving only sine


				do	-- int(c*sin(a*x))
					local a = f:match(sin(Wildcard{1, cannotDependOn=x} * x))
					if a then
						return -frac(c,a) * cos(a * x)
					end
				end

				do	-- int(c*sin(a*x)^2)
					local a = f:match(sin(Wildcard{1, cannotDependOn=x} * x)^2)
					if a then
						return c/2 * (x - 1/(2*a) * sin(2*a*x))
						-- equivalently:
						--return c/2 * (x - 1/a * sin(a*x) * cos(a*x))
					end
				end

				do	-- int(c * x * sin(a * x))
					local a = f:match(x * sin(Wildcard{1, cannotDependOn=x} * x))
					if a then
						return sin(a * x) / a^2 - (x * cos(a * x)) / a
					end
				end

				do	-- int(sin(b1*x) * sin(b2*x)), b1 != b2
					local b1, b2 = f:match(sin(Wildcard{1, cannotDependOn=x} * x) * sin(Wildcard{2, cannotDependOn=x} * x))
					if b1 then
						-- if b1 == b2 then it would simplify to sin(b1*x)^2 ... right?
						assert(b1 ~= b2)
						return sin((b2 - b1) * x)/(2 * (b2 - b1)) - sin((b2 + b1) * x)/(2 * (b2 + b1))
					end
				end


				-- ...involving only cosine


				do	-- int(c*cos(a*x))
					local a = f:match(cos(Wildcard{1, cannotDependOn=x} * x))
					if a then
						return frac(c,a) * sin(a * x)
					end
				end

				do	-- int(c*cos(a*x)^2)
					local a = f:match(cos(Wildcard{1, cannotDependOn=x} * x)^2)
					if a then
						return c/2 * (x + 1/(2*a) * sin(2*a*x))
						-- equivalently
						--return c/2 * (x + 1/a * sin(a*x) * cos(a*x))
					end
				end

				do	-- int(c * x * cos(a * x))
					local a = f:match(x * cos(Wildcard{1, cannotDependOn=x} * x))
					if a then
						return cos(a * x) / a^2 + (x * sin(a * x)) / a
					end
				end

				do	-- int(cos(a1*x) * cos(a2*x)), a1 != a2
					local a1, a2 = f:match(cos(Wildcard{1, cannotDependOn=x} * x) * cos(Wildcard{2, cannotDependOn=x} * x))
					if a1 then
						-- if a1 == a2 then it would simplify to cos(a1*x)^2 ... right?
						assert(a1 ~= a2)
						return sin((a2 - a1) * x)/(2 * (a2 - a1)) + sin((a2 + a1) * x)/(2 * (a2 + a1))
					end
				end


				-- sine and cosine


				do	-- int(sin(a1*x) * cos(a2*x))
					local a1, a2 = f:match(sin(Wildcard{1, cannotDependOn=x} * x) * cos(Wildcard{2, cannotDependOn=x} * x))
					if a1 then
						if a1 == a2 then
							return sin(a1 * x)^2 / (2 * a1)
						else
							return cos((a1 - a2) * x) / (2 * (a1 - a2)) - cos((a1 + a2) * x) / (2 * (a1 + a2))
						end
					end
				end

				do	-- int(tan(a * x))
					-- int(sin(a * x) / cos(a * x))
					local a = f:match(sin(Wildcard{1, cannotDependOn=x} * x) * (1 / cos(Wildcard{1, cannotDependOn=x} * x)))
					if a then
						return -frac(c, a) * log(abs(cos(a * x)))
					end
				end

				do	-- int(cot(a * x))
					-- int(cos(a * x) / sin(a * x))
					local a = f:match(cos(Wildcard{1, cannotDependOn=x} * x) * (1 / sin(Wildcard{1, cannotDependOn=x} * x)))
					if a then
						return frac(c, a) * log(abs(sin(a * x)))
					end
				end


				-- https://en.wikipedia.org/wiki/List_of_integrals_of_hyperbolic_functions
				-- hyperbolic sine


				do	-- int(c*sinh(a*x))
					local a = f:match(sinh(Wildcard{1, cannotDependOn=x} * x))
					if a then
						return frac(c,a) * cosh(a * x)
					end
				end


				-- hyperbolic cosine


				do	-- int(c*cosh(a*x))
					local a = f:match(cosh(Wildcard{1, cannotDependOn=x} * x))
					if a then
						return frac(c,a) * sinh(a * x)
					end
				end


				-- hyperbolic sine and hyperbolic cosine


				do	-- int(cosh(a*x)*sinh(b*x))
					-- = (a*sinh(a*x)*sinh(b*x) - b*cosh(a*x)*cosh(b*x))/(a^2 - b^2) for a != b
					-- = cosh(a*x)^2 / (2 * a) for a == b
					local a, b = f:match(cosh(Wildcard{1, cannotDependOn=x} * x) * sinh(Wildcard{2, cannotDependOn=x} * x))
					if a and b then
						if a == b then
							return (c / (2 * a)) * cosh(a * x)^2
						else
							return (c / (a^2 - b^2)) * (a * sinh(a * x) * sinh(b * x) - b * cosh(a * x) * cosh(b * x))
						end
					end
				end

				do	-- int(tanh(a*x))
					-- int(sinh(a*x)/cosh(a*x))
					local a = f:match(sinh(Wildcard{1, cannotDependOn=x} * x) * (1 / cosh(Wildcard{1, cannotDependOn=x} * x)))
					if a then
						return frac(c, a) * log(abs(cosh(a * x)))
					end
				end

				do	-- int(coth(a*x))
					-- int(cosh(a*x)/sinh(a*x))
					local a = f:match(cosh(Wildcard{1, cannotDependOn=x} * x) * (1 / sinh(Wildcard{1, cannotDependOn=x} * x)))
					if a then
						return frac(c, a) * log(abs(sinh(a * x)))
					end
				end

				do	-- int(sinh(a*x)^2*cosh(a*x))
					-- = sinh(a*x)^3 / (3*a) for a = b
					local a, b = f:match(sinh(Wildcard{2, cannotDependOn=x} * x)^2 * cosh(Wildcard{1, cannotDependOn=x} * x))
					if a and b then
						if a == b then
							return sinh(a*x)^3 / (3 * a)
						end
					end
				end
			end
		end},
	},
}

return Integral
