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
				expr = prune(Integral(int, x))
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
				return (defFin - defStart)()
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
				local found = false
				map(a, function(ai)
					if ai == x then found = true return end
					if Variable.is(ai) and table.find(ai.dependentVars, x) then found = true return end
				end)
				return found
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
					-- int(x^n,x) = {
					-- 		1/(n+1) x^(n+1) 	for x ~= -1
					--		log|x| 				for x == -1
					if d[1] == x
					and Constant.is(d[2])
					then
						local n = d[2].value
						if n == -1 then
							return mulWithNonDep(log(abs(x)))
						else
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
					and Constant.is(d[2])
					and d[2].value == 2
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
					and Constant.is(d[2])
					and d[2].value == 2
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
					if Constant.is(d[1]) and d[1].value == 1 then	-- int(1/f(x), x)
						local e = d[2]
						-- int(1/x,x)
						if e == x then
							return mulWithNonDep(log(abs(x)))
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
				elseif sin.is(dep[1]) and cos.is(dep[2])
				or cos.is(dep[1]) and sin.is(dep[2])
				then
					local dep1, nondep1 = getDepAndNonDep(dep[1][1])
					local dep2, nondep2 = getDepAndNonDep(dep[2][1])
					if cos.is(dep[1]) and sin.is(dep[2]) then
						dep1, dep2 = dep2, dep1
						nondep1, nondep2 = nondep2, nondep1
					end
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
			
			elseif #dep > 2 then	-- TODO any integrals of f1(x) * ... * fn(x)
			end

			-- factor out terms that don't depend on the integratable variable
			-- but leave the integral of whatever's left unresolved
			if #dep == 1 then
				return mulWithNonDep(Integral(dep[1], table.unpack(expr, 2)))
			else
				return mulWithNonDep(Integral(setmetatable(dep, mul), table.unpack(expr, 2)))
			end
		end},
	},
}

return Integral
