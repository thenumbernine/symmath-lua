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
			
			-- TODO make this canonical form
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

			-- assuming it's already simplified ... ? so no x * x^2's exist?
			local function isDepOfX(a)
				return a:dependsOn(x)
			end

			local function getDepAndNonDep(int)
				local dep = table()
				local nondep = table()
				local function check(xi)
					if isDepOfX(xi) then
						dep:insert(xi)
					else
						nondep:insert(xi)
					end
				end
				if mul.is(int) then
					for i=1,#int do
						check(int[i])
					end
				else
					check(int)
				end
				return dep, nondep
			end

			-- separate expr into terms dependent on x and otherwise
			local dep, nondep = getDepAndNonDep(int)
		
			local function mulWithNonDep(y)
				if #nondep == 0 then return y end
				if #nondep == 1 then return nondep[1] * y end
				nondep:insert(y)
				return setmetatable(nondep, mul)
			end

			local function tableToTerm(t)
				if #t == 0 then
					return 1
				elseif #t == 1 then
					return t[1]
				else
					return setmetatable(t, mul)
				end
			end			
				
			local sin = require 'symmath.sin'
			local cos = require 'symmath.cos'
			local sinh = require 'symmath.sinh'
			local cosh = require 'symmath.cosh'

			if #dep == 0 then
				return mulWithNonDep(x)
			elseif #dep == 1 then	-- integrals of single f(x)
				local d = dep[1]

				-- int(x,x) = x^2/2
				if d == x then
					return mulWithNonDep(x^2/2)
				end
				
				if pow.is(d) then	-- int(f(x)^g(x),x)

					-- int(x^n, x)
					if d[1] == x
					and Constant.is(d[2])
					then
						local n = d[2].value
						if n == -1 then
							-- int(x^-1,x) = log|x|
							return mulWithNonDep(log(abs(x)))
						else
							-- int(x^n,x) = 1/(n+1) x^(n+1) for n ~= -1
							return mulWithNonDep(x^(n+1)/(n+1))
						end
					end

					-- int(n^x,x) = int(exp(log(n^x)),x) = int(exp(x log(n)),x) = 1/log(n) exp(x log(n)) = 1/log(n) n^x
					if d[2] == x
					and Constant.is(d[1])
					then
						local n = d[1]
						return mulWithNonDep(n^x/log(n))
					end

					-- int(sin(x)^2,x) = x/2 - 1/4a sin(2 a x)
					if sin.is(d[1]) 
					and Constant.isValue(d[2], 2)
					then
						local dep, nondep = getDepAndNonDep(d[1][1])
						assert(#dep > 0)
						if #dep == 1 and dep[1] == x then
							local a = tableToTerm(nondep)
							return x/2 - sin(2 * a * x)/(4 * a)
						end
					end

					-- int(cos(x)^2,x) = x/2 + 1/4a sin(2 a x)
					if cos.is(d[1]) 
					and Constant.isValue(d[2], 2)
					then
						local dep, nondep = getDepAndNonDep(d[1][1])
						assert(#dep > 0)
						if #dep == 1 and dep[1] == x then
							local a = tableToTerm(nondep)
							return x/2 + sin(2 * a * x)/(4 * a)
						end
					end

				-- TODO f(x)^g(x) 
				
				elseif div.is(d) then	-- int(f(x)/g(x), x)
					if Constant.isValue(d[1], 1) then	-- int(1/f(x), x)
						local e = d[2]
						
						local depe, nondepe = getDepAndNonDep(e)
						-- int(1/(cx),x) = 1/c ln|x|
						--if e == x then
						if #depe == 1 
						and depe[1] == x 
						then
							return mulWithNonDep(log(abs(x))) / tableToTerm(nondepe)
						end

						-- int(1/(x*(ax+b)) = -1/b ln|(ax+b)/x|
						-- This is just a single entry from https://en.wikipedia.org/wiki/List_of_integrals_of_rational_functions
						-- TODO implement them all
						if add.is(e)
						and #e == 2
						then
							local depe21, nondepe21 = getDepAndNonDep(e[1])
							local depe22, nondepe22 = getDepAndNonDep(e[2])
							if #depe22 == 2 
							and depe22[1] == x 
							and depe22[2] == x
							then
								depe21, nondepe21, depe22, nondepe22 = depe22, nondepe22, depe21, nondepe21
							end
							-- a x + b
							if #depe21 == 2 
							and depe21[1] == x
							and depe21[2] == x
							and #depe22 == 1
							and depe22[1] == x
							then
								-- e == a*x*x + b*x
								local a = tableToTerm(nondepe21)
								local b = tableToTerm(nondepe22)
							
								return -1/b * log(abs((a*x+b)/x))
							end
						end

						-- int(1/f(x)^g(x),x)
						if pow.is(e) then
							-- int(1/x^n,x)
							if e[1] == x
							and Constant.is(e[2])
							then
								local n = e[2]
								if n == 1 then
									return mulWithNonDep(log(abs(x)))
								else
									return mulWithNonDep(x^(1-n)/(1-n))
								end
							end
						
							-- int(1/n^x,x)
							if e[2] == x
							and Constant.is(e[1])
							then
								local n = e[1]
								return mulWithNonDep(-1/(n^x*log(n)))
							end
						end
					end
				else
					-- int(f(x),x)
					
					local function handle(getIntF)
						local dep, nondep = getDepAndNonDep(d[1])
						assert(#dep > 0)
						if #dep == 1 and dep[1] == x then
							-- int(f(a x),x) = 1/a F(a x)
							return (1/tableToTerm(nondep)) * mulWithNonDep(getIntF(d[1]))
						end
					end
				
					for _,p in ipairs{
						{sin, function(x) return -cos(x) end},	-- int(sin(x),x) = -cos(x)
						{cos, sin},			-- int(cos(x),x) = sin(x)
						{sinh, cosh},
						{cosh, sinh},
						-- int(tanh(x)) = log(cosh(x)) ... but I'm keeping them separated atm
						-- hmm, once again, I am tempted to just (1) get rid of collapsing of mul(mul(a,b),c) -> mul(a,b,c) and (2) just implement everything as tree rules so sinh(x)/cosh(x) => tanh(x) and (3) try hard not to create any loops in that graph
					} do
						local f, F = table.unpack(p)
						if f.is(d) then
							local result = handle(F)
							if result then return result end
						end
					end
				end
			elseif #dep == 2 then
				if sin.is(dep[1]) and sin.is(dep[2]) then
					local dep1, nondep1 = getDepAndNonDep(dep[1][1])
					local dep2, nondep2 = getDepAndNonDep(dep[2][1])
					if #dep1 == 1 and dep1[1] == x and #dep2 == 1 and dep2[1] == x then
						-- int(sin(a x) * sin(b x), x), a != b = 1/(2 (a - b)) sin((a - b) x) + 1/(2(a + b)) sin((a + b) x)
						-- NOTICE that 'a != b' should be a constraint on the range on the result
						local a1 = tableToTerm(nondep1)
						local a2 = tableToTerm(nondep2)
						assert(a1 ~= a2)
						return sin((a2 - a1) * x)/(2 * (a2 - a1)) 
								- sin((a2 + a1) * x)/(2 * (a2 + a1)) 
					end
				elseif cos.is(dep[1]) and cos.is(dep[2]) then
					local dep1, nondep1 = getDepAndNonDep(dep[1][1])
					local dep2, nondep2 = getDepAndNonDep(dep[2][1])
					if #dep1 == 1 and dep1[1] == x and #dep2 == 1 and dep2[1] == x then	
						local a1 = tableToTerm(nondep1)
						local a2 = tableToTerm(nondep2)
						assert(a1 ~= a2)
						-- int(cos(a x) * cos(b x), x)
						return sin((a2 - a1) * x)/(2 * (a2 - a1)) 
								+ sin((a2 + a1) * x)/(2 * (a2 + a1)) 
					end
				elseif sin.is(dep[1]) and cos.is(dep[2])	-- sin(f(x)) * cos(g(x))
				or cos.is(dep[1]) and sin.is(dep[2])		-- cos(f(x)) * sin(g(x))
				then
					local dep1, nondep1 = getDepAndNonDep(dep[1][1])
					local dep2, nondep2 = getDepAndNonDep(dep[2][1])
					if cos.is(dep[1]) and sin.is(dep[2]) then
						dep1, dep2 = dep2, dep1
						nondep1, nondep2 = nondep2, nondep1
					end
					-- sin(f(x)) * cos(g(x))
					if #dep1 == 1 and dep1[1] == x
					and #dep2 == 1 and dep2[1] == x
					then
						-- sin(a*x) * cos(b*x)
						local a1 = tableToTerm(nondep1)
						local a2 = tableToTerm(nondep2)
						if a1 == a2 then
							-- int(sin(a x) * cos(a x), x)
							return sin(a1 * x)^2 / (2 * a1)
						else
							-- int(sin(a1 x) * cos(a2 x), x)
							return -cos((a1 - a2) * x) / (2 * (a1 - a2))
									- cos((a1 + a2) * x) / (2 * (a1 + a2))
						end
					end	
				
				-- cos(f(x)) * (g(x) / h(x))
				elseif (cos.is(dep[1]) and div.is(dep[2]))
				or (cos.is(dep[2]) and div.is(dep[1]))
				then
					if cos.is(dep[2]) and div.is(dep[1]) then
						dep[1], dep[2] = dep[2], dep[1]
					end
					local dep11, nondep11 = getDepAndNonDep(dep[1][1])	-- f(x)
					local dep21, nondep21 = getDepAndNonDep(dep[2][1])	-- g(x)
					local dep22, nondep22 = getDepAndNonDep(dep[2][2])	-- h(x)

					if #dep11 == 1		--   f(x) = b x
					and dep11[1] == x	-- _/
					and #dep21 == 0		-- g(x) = c
					and #dep22 == 1		--   h(x) == sin(x)
					and sin.is(dep22[1])	-- _/
					then
						local dep221, nondep221 = getDepAndNonDep(dep[2][2][1])	-- sin(k(x))
						
						-- k(x) == e x, so h(x) = d sin(e x)
						if #dep221 == 1
						and dep221[1] == x
						then
							-- a cos(b * x) * (c / (d * sin(e * x)))
							local a = tableToTerm(nondep)			-- usu 1
							local b = tableToTerm(nondep11)
							local c = tableToTerm(nondep21)			-- usu 1
							local d = tableToTerm(nondep22)			-- usu 1
							local e = tableToTerm(nondep221)

							if b == e then
								return ((a * c) / (b * d)) * log(abs(sin(b * x)))
							end
						end
					end


				-- sin(f(x)) * (g(x) / h(x))
				elseif (sin.is(dep[1]) and div.is(dep[2]))
				or (sin.is(dep[2]) and div.is(dep[1]))
				then
					if sin.is(dep[2]) and div.is(dep[1]) then
						dep[1], dep[2] = dep[2], dep[1]
					end
					local dep11, nondep11 = getDepAndNonDep(dep[1][1])	-- f(x)
					local dep21, nondep21 = getDepAndNonDep(dep[2][1])	-- g(x)
					local dep22, nondep22 = getDepAndNonDep(dep[2][2])	-- h(x)

					if #dep11 == 1		--   f(x) = b x
					and dep11[1] == x	-- _/
					and #dep21 == 0		-- g(x) = c
					and #dep22 == 1		--   h(x) == cos(x)
					and cos.is(dep22[1])	-- _/
					then
						local dep221, nondep221 = getDepAndNonDep(dep[2][2][1])	-- cos(k(x))
						
						-- k(x) == e x, so h(x) = d cos(e x)
						if #dep221 == 1
						and dep221[1] == x
						then
							-- a sin(b * x) * (c / (d * cos(e * x)))
							local a = tableToTerm(nondep)			-- usu 1
							local b = tableToTerm(nondep11)
							local c = tableToTerm(nondep21)			-- usu 1
							local d = tableToTerm(nondep22)			-- usu 1
							local e = tableToTerm(nondep221)

							if b == e then
								return -((a * c) / (b * d)) * log(abs(cos(b * x)))
							end
						end
					end

				-- sinh(f(x)) * (g(x) / h(x))
				elseif (sinh.is(dep[1]) and div.is(dep[2]))
				or (sinh.is(dep[2]) and div.is(dep[1]))
				then
					if sinh.is(dep[2]) and div.is(dep[1]) then
						dep[1], dep[2] = dep[2], dep[1]
					end
					local dep11, nondep11 = getDepAndNonDep(dep[1][1])	-- f(x)
					local dep21, nondep21 = getDepAndNonDep(dep[2][1])	-- g(x)
					local dep22, nondep22 = getDepAndNonDep(dep[2][2])	-- h(x)

					if #dep11 == 1		--   f(x) = b x
					and dep11[1] == x	-- _/
					and #dep21 == 0		-- g(x) = c
					and #dep22 == 1		--   h(x) == cosh(x)
					and cosh.is(dep22[1])	-- _/
					then
						local dep221, nondep221 = getDepAndNonDep(dep[2][2][1])	-- cosh(k(x))
						
						-- k(x) == e x, so h(x) = d cosh(e x)
						if #dep221 == 1
						and dep221[1] == x
						then
							-- a sinh(b * x) * (c / (d * cosh(e * x)))
							local a = tableToTerm(nondep)			-- usu 1
							local b = tableToTerm(nondep11)
							local c = tableToTerm(nondep21)			-- usu 1
							local d = tableToTerm(nondep22)			-- usu 1
							local e = tableToTerm(nondep221)

							if b == e then
								return ((a * c) / (b * d)) * log(cosh(b * x))
							end
						end
					end

				-- cosh(f(x)) * (g(x) / h(x))
				elseif (cosh.is(dep[1]) and div.is(dep[2]))
				or (cosh.is(dep[2]) and div.is(dep[1]))
				then
					if cosh.is(dep[2]) and div.is(dep[1]) then
						dep[1], dep[2] = dep[2], dep[1]
					end
					local dep11, nondep11 = getDepAndNonDep(dep[1][1])	-- f(x)
					local dep21, nondep21 = getDepAndNonDep(dep[2][1])	-- g(x)
					local dep22, nondep22 = getDepAndNonDep(dep[2][2])	-- h(x)

					if #dep11 == 1		--   f(x) = b x
					and dep11[1] == x	-- _/
					and #dep21 == 0		-- g(x) = c
					and #dep22 == 1		--   h(x) == sinh(x)
					and sinh.is(dep22[1])	-- _/
					then
						local dep221, nondep221 = getDepAndNonDep(dep[2][2][1])	-- sinh(k(x))
						
						-- k(x) == e x, so h(x) = d sinh(e x)
						if #dep221 == 1
						and dep221[1] == x
						then
							-- a cosh(b * x) * (c / (d * sinh(e * x)))
							local a = tableToTerm(nondep)			-- usu 1
							local b = tableToTerm(nondep11)
							local c = tableToTerm(nondep21)			-- usu 1
							local d = tableToTerm(nondep22)			-- usu 1
							local e = tableToTerm(nondep221)

							if b == e then
								return ((a * c) / (b * d)) * log(abs(sinh(b * x)))
							end
						end
					end				

				end

			elseif #dep > 2 then	-- TODO any integrals of f1(x) * ... * fn(x)
			end

--[[ bugs in here
			-- factor out terms that don't depend on the integratable variable
			-- but leave the integral of whatever's left unresolved
			if #dep == 1 then
				return mulWithNonDep(Integral(dep[1], table.unpack(expr, 2)))
			else
				return mulWithNonDep(Integral(setmetatable(dep, mul), table.unpack(expr, 2)))
			end
--]]		
		end},
	},
}

return Integral
