local class = require 'ext.class'
local table = require 'ext.table'
local range = require 'ext.range'
local Binary = require 'symmath.op.Binary'

local pow = class(Binary)
pow.omitSpace = true
pow.precedence = 5
pow.name = '^'

--[[
d/dx(a^b)
d/dx(exp(log(a^b)))
d/dx(exp(b*log(a)))
exp(b*log(a)) * d/dx[b*log(a)]
a^b * (db/dx * log(a) + b * d/dx[log(a)])
a^b * (db/dx * log(a) + da/dx * b / a)
--]]
function pow:evaluateDerivative(...)
	local log = require 'symmath.log'
	local diff = require 'symmath.Derivative'
	local a, b = table.unpack(self)
	a, b = a:clone(), b:clone()
	return a ^ b * (diff(b, ...) * log(a) + diff(a, ...) * b / a)
end

-- just for this
-- temporary ...
function pow:expand()
	local Constant = require 'symmath.Constant'
	-- for certain small integer powers, expand 
	-- ... or should we have all integer powers expended under a different command?
	if Constant.is(self[2])
	and self[2].value >= 0
	and self[2].value < 10
	and self[2].value == math.floor(self[2].value)
	then
		local result = Constant(1)
		for i=1,self[2].value do
			result = result * self[1]:clone()
		end
		return result:simplify()
	end
end

function pow:reverse(soln, index)
	local p,q = table.unpack(self)
	-- y = p(x)^q => y^(1/q) = p(x)
	if index == 1 then
		return soln^(1/q)
	-- y = p^q(x) => log(y) / log(p) = q(x)
	elseif index == 2 then
		local log = require 'symmath.log'
		return log(y) / log(p)
	end
end

pow.visitorHandler = {
	Eval = function(eval, expr)
		local a, b = table.unpack(expr)
		return eval:apply(a) ^ eval:apply(b)
	end,
	
	Expand = function(expand, expr)
		local div = require 'symmath.op.div'
		local mul = require 'symmath.op.mul'
		local Constant = require 'symmath.Constant'
		
		-- (a / b)^n => a^n / b^n
		-- not simplifying ...
		-- maybe this should go in factor() or expand()
		if div.is(expr[1]) then
			return expand:apply(expr[1][1]:clone() ^ expr[2]:clone() 
				/ expr[1][2]:clone() ^ expr[2]:clone())
		end

		-- a^n => a*a*...*a,  n times, only for integer 2 <= n < 10
		-- hmm this can cause problems in some cases ... 
		-- comment this out to get schwarzschild_spherical_to_cartesian to work
		if Constant.is(expr[2])
		and expr[2].value >= 2
		and expr[2].value < 10
		and expr[2].value == math.floor(expr[2].value)
		then
			return expand:apply(mul(range(expr[2].value):map(function(i)
				return expr[1]:clone()
			end):unpack()))
		end
		--]]	
	end,

-- with this, polyCoeffs works
-- without this, equations look a whole lot cleaner during simplificaton
-- (and dividing polys works a bit better)
-- until factor() works, simplify() works better without this enabled ... but polyCoeffs() doesn't ... 
-- [[
	ExpandPolynomial = function(expandPolynomial, expr)
		local clone = require 'symmath.clone'
		local Constant = require 'symmath.Constant'
		
		expr = clone(expr)
--local original = clone(expr)
		local maxPowerExpand = 10
		if Constant.is(expr[2]) then
			local value = expr[2].value
			local absValue = math.abs(value)
			if absValue < maxPowerExpand then
				local num, frac, div
				if value < 0 then
					div = true
					frac = math.ceil(value) - value
					num = -math.ceil(value)
				elseif value > 0 then
					frac = value - math.floor(value)
					num = math.floor(value)
				else
--print('pow a^0 => 1', require 'symmath.tostring.Verbose'(original), '=>', require 'symmath.tostring.Verbose'(Constant(1)))
					return Constant(1)
				end
				local terms = table()
				for i=1,num do
					terms:insert(expr[1]:clone())
				end
				if frac ~= 0 then
					terms:insert(expr[1]:clone()^frac)
				end
			
				assert(#terms > 0)
				
				if #terms == 1 then
					expr = terms[1]
				else
					local mul = require 'symmath.op.mul'
					expr = mul(terms:unpack())
				end
				
				if div then expr = 1/expr end
				
				return expandPolynomial:apply(expr)
			end
		end
	end,
--]]

	Prune = function(prune, expr)
		local symmath = require 'symmath'	-- needed for flags
		local mul = symmath.op.mul
		local div = symmath.op.div
		local Constant = symmath.Constant

		local complex = require 'symmath.complex'
		local function isInteger(x) 
			if complex.is(x) then x = complex.unpack(x) end	
			return x == math.floor(x+.5) 
		end
		local function isPositiveInteger(x) return isInteger(x) and x > 0 end

		if Constant.is(expr[1]) and Constant.is(expr[2]) then
			if symmath.simplifyConstantPowers
			-- TODO this replaces some cases below
			or isInteger(expr[1].value) and isPositiveInteger(expr[2].value)
			then
				return Constant(expr[1].value ^ expr[2].value)
			end
		end
	
		if Constant.is(expr[1]) and isPositiveInteger(expr[1].value)
		and (expr[2] == div(1,2) or expr[2] == Constant(.5))
		then
			local primes = require 'symmath.primeFactors'(expr[1].value)
			local outside = 1
			local inside = 1
			for i=#primes-1,1,-1 do
				if primes[i] == primes[i+1] then
					outside = outside * primes[i]
					primes:remove(i)
					primes:remove(i)
				end
			end
			local inside = 1
			for i=1,#primes do
				inside = inside * primes[i]
			end
			if inside == 1 and outside == 1 then return Constant(1) end
			if outside == 1 then return Constant(inside)^div(1,2) end
			if inside == 1 then return Constant(outside) end
			return Constant(outside) * Constant(inside)^div(1,2)
		end
	
		-- 0^a = 0 for a>0
		if expr[1] == Constant(0) 
		and Constant.is(expr[2])
		and expr[2].value > 0
		then
			return Constant(0)
		end

		-- 1^a => 1
		if expr[1] == Constant(1) then return Constant(1) end
		
		-- (-1)^odd = -1, (-1)^even = 1
		if expr[1] == Constant(-1) and Constant.is(expr[2]) then
			local powModTwo = expr[2].value % 2
			if powModTwo == 0 then return Constant(1) end
			if powModTwo == 1 then return Constant(-1) end
		end
		
		-- a^1 => a
		if expr[2] == Constant(1) then return prune:apply(expr[1]) end
		
		-- a^0 => 1
		if expr[2] == Constant(0) then return Constant(1) end
		
		-- (a ^ b) ^ c => a ^ (b * c)
		-- unless b is 2 and c is 1/2 ...
		-- in fact, only if c is integer
		-- in fact, better add complex numbers
		if pow.is(expr[1]) then
			return prune:apply(expr[1][1] ^ (expr[1][2] * expr[2]))
		end
		
		-- (a * b) ^ c => a^c * b^c
		if mul.is(expr[1]) then
			local result = table.map(expr[1], function(v,k)
				if type(k) ~= 'number' then return end
				return v ^ expr[2]
			end)
			assert(#result > 0)
			if #result == 1 then
				result = result[1]
			else
				result = mul(result:unpack())
			end
			return prune:apply(result)
		end
	
		-- a^(-c) => 1/a^c
		if Constant.is(expr[2]) and expr[2].value < 0 then
			return prune:apply(Constant(1)/(expr[1]^Constant(-expr[2].value)))
		end

		--[[ for simplification's sake ... (like -a => -1 * a)
		-- x^c => x*x*...*x (c times)
		if Constant.is(expr[2])
		and expr[2].value > 0 
		and expr[2].value == math.floor(expr[2].value)
		then
			local m = mul()
			for i=1,expr[2].value do
				table.insert(m, expr[1]:clone())
			end
			
			return prune:apply(m)
		end
		--]]

		-- trigonometric
		local sin = require 'symmath.sin'
		local cos = require 'symmath.cos'
		if cos.is(expr[1])
		and Constant.is(expr[2])
		then
			local n = expr[2].value
			if n >= 2
			and n <= 10
			and n == math.floor(n)
			then
				local th = expr[1][1]
				return prune:apply((1 - sin(th:clone())^2) * cos(th:clone())^(n-2))
			end
		end

	end,

	Tidy = function(tidy, expr)
		local unm = require 'symmath.op.unm'
		local Constant = require 'symmath.Constant'
		local sqrt = require 'symmath.sqrt'

		-- [[ x^-a => 1/x^a ... TODO only do this when in a product?
		if unm.is(expr[2]) then
			return tidy:apply(Constant(1)/expr[1]^expr[2][1])
		end
		--]]
		
		if expr[2] == Constant(.5)
		or expr[2] == Constant(1)/Constant(2)
		then
			return sqrt(expr[1])
		end
	end,

}
-- ExpandPolynomial inherits from Expand
--pow.visitorHandler.ExpandPolynomial = pow.visitorHandler.Expand
-- but don't do it because it's overwritten for this class

return pow
