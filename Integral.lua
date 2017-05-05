local class = require 'ext.class'
local Expression = require 'symmath.Expression'

local Integral = class(Expression)
Integral.name = 'Integral'

-- Integral:init(expr, var[, start, finish])
function Integral:expr() return self[1] end
function Integral:var() return self[2] end
function Integral:start() return self[3] end
function Integral:finish() return self[4] end

Integral.visitorHandler = {
	-- TODO numerical integration methods
	Eval = function(eval, expr)
		error("cannot evaluate integral "..tostring(expr)..".  try replace()ing integrals.")
	end,

	Prune = function(prune, expr)
		local symmath = require 'symmath'
		local Constant = symmath.Constant
		local Variable = symmath.Variable
		local add = symmath.op.add
		local mul = symmath.op.mul
		local pow = symmath.op.pow
		local map = symmath.map
		local log = symmath.log
		local abs = symmath.abs
		
		local x = expr[2]
		
		-- TODO convert away divisions first ... convert into ^-1's
		
		if Constant.is(expr[1]) then
			return prune(expr[1] * x)
		end

		if Variable.is(expr[1]) then
			if expr[1] == x then
				return prune(expr[1]^2/2)
			else
				return prune(expr[1] * x)
			end
		end
	
		if add.is(expr[1]) then
			return add(range(#expr[1]):map(function(i)
				return prune(Integral(expr[1][i], table.unpack(expr, 2)))
			end):unpack())
		end

		if pow.is(expr[1])
		and expr[1][1] == x
		and Constant.is(expr[1][2])
		then
			if expr[1][2] == Constant(-1) then
				return prune(log(abs(x)))
			else
				return prune(x^(expr[1][2]+1)/(expr[1][2]+1))
			end
		end

		-- assuming it's already simplified ... ? so no x * x^2's exist?
		if mul.is(expr[1]) then
			local function find(a,b)
				local found = false
				map(a, function(x)
					if x == b then found = true end
				end)
				return found
			end
			local found = false
			local terms = table(expr[1])
			for i=1,#terms do
				if terms[i] == x then
					if found then return end
					-- integrating something times x ... 
					terms[i] = x^2/2
					found = true
				elseif pow.is(terms[i]) and terms[i][1] == x then
					-- integrating something times x^n
					if found then return end
					if terms[i][2] == Constant(-1) then
						terms[i] = prune(log(abs(x)))
					else
						terms[i] = prune(x^(terms[i][2]+1)/(terms[i][2]+1))
					end
					found = true
				elseif find(terms[i], x) then
					return
				end
			end
			if found then
				return prune(mul(terms:unpack()))
			end
		end
	end,
}

return Integral
