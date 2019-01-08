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
			local pow = symmath.op.pow
			local map = symmath.map
			local log = symmath.log
			local abs = symmath.abs

			local int, x, start, finish = table.unpack(expr)

			if start and finish then
				expr = prune(Integral(int, x))
				return (expr:replace(x, finish) - expr:replace(x, start))()
			end

			int = int():factorDivision()

			-- TODO convert away divisions first ... convert into ^-1's
			
			if Constant.is(int) then
				return prune(int * x)
			end

			if Variable.is(int) then
				if int == x then
					return prune(int^2/2)
				else
					return prune(int * x)
				end
			end
		
			if add.is(int) then
				return add(range(#int):map(function(i)
					return prune(Integral(int[i], table.unpack(expr, 2)))
				end):unpack())
			end

			if pow.is(int)
			and int[1] == x
			and Constant.is(int[2])
			then
				if int[2] == Constant(-1) then
					return prune(log(abs(x)))
				else
					return prune(x^(int[2]+1)/(int[2]+1))
				end
			end

			-- assuming it's already simplified ... ? so no x * x^2's exist?
			if mul.is(int) then
				local function find(a,b)
					local found = false
					map(a, function(x)
						if x == b then found = true end
					end)
					return found
				end
				local found = false
				local terms = table(int)
				for i=1,#terms do
					if terms[i] == x then
						-- integrating something times x ... 
						terms[i] = x^2/2
						found = true
					elseif pow.is(terms[i]) and terms[i][1] == x then
						-- integrating something times x^n
						if terms[i][2] == Constant(-1) then
							terms[i] = prune(log(abs(x)))
						else
							terms[i] = prune(x^(terms[i][2]+1)/(terms[i][2]+1))
						end
						found = true
					elseif find(terms[i], x) then	-- a function of x not yet implemented
						return
					end
				end
				if found then
					return prune(mul(terms:unpack()))
				else
					return prune(mul(x, terms:unpack()))
				end
			end
		end},
	},
}

return Integral
