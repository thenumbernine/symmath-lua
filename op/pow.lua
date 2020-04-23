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
function pow:evaluateDerivative(deriv, ...)
	local log = require 'symmath.log'
	local a, b = table.unpack(self)
	a, b = a:clone(), b:clone()

-- [[
	-- shorthand ...
	local Constant = require 'symmath.Constant'
	if Constant.is(b) then
		if Constant.is(a) then
			-- a & b are constant ... a^b is constant ... d/dx (a^b) = 0
			return Constant(0)
		end
	
		-- b is constant, a is not ... d/dx (a^b) = b a^(b-1) * d/dx(a)
		return b * a ^ Constant(b.value-1) * deriv(a, ...)
	elseif Constant.is(a) then
		-- a is constant, b is not
		-- d/dx a^b = d/dx exp(b log(a)) = log(a) d/dx(b) exp(b log(a)) = a^b log(a) d/dx(b)
		return a ^ b * log(a) * deriv(b, ...)
	end
--]]

	-- neither a nor b is constant
	return a ^ b * (deriv(b, ...) * log(a) + deriv(a, ...) * b / a)
end

-- just for this
-- temporary ...
function pow:expand()
	local Constant = require 'symmath.Constant'
	-- for certain small integer powers, expand 
	-- ... or should we have all integer powers expended under a different command?
	if require 'symmath.set.sets'.integer:contains(self[2])
	and self[2].value >= 0
	and self[2].value < 10
	then
		local result = Constant(1)
		for i=1,self[2].value do
			result = result * self[1]:clone()
		end
		return result:simplify()
	end
end

function pow:reverse(soln, index)
	local Constant = require 'symmath'.Constant
	local p,q = table.unpack(self)
	-- y = p(x)^q => y^(1/q) = p(x)
	if index == 1 then
		-- TODO for q is integer, include all 1/q roots
		-- here it is for square
		if Constant.isValue(q, 2) then
			return soln^(1/q), -soln^(1/q)
		end
		
		return soln^(1/q)
	-- y = p^q(x) => log(y) / log(p) = q(x)
	elseif index == 2 then
		local log = require 'symmath.log'
		return log(y) / log(p)
	end
end

function pow:getRealDomain()
	local I = self[1]:getRealDomain()
	if I == nil then return nil end
	local I2 = self[2]:getRealDomain()
	if I2 == nil then return nil end
	return I ^ I2
end

pow.rules = {
	Eval = {
		{apply = function(eval, expr)
			local a, b = table.unpack(expr)
			return eval:apply(a) ^ eval:apply(b)
		end},
	},

	Expand = {
		{apply = function(expand, expr)
			local div = require 'symmath.op.div'
			local mul = require 'symmath.op.mul'
			local Constant = require 'symmath.Constant'
			
			-- (a / b)^n => a^n / b^n
			-- not simplifying ...
			-- maybe this should go in factor() or expand()
			if div.is(expr[1]) then
				local num = expr[1][1]:clone() ^ expr[2]:clone()
				local denom = expr[1][2]:clone() ^ expr[2]:clone()
				local repl = num / denom
				return expand:apply(repl)
			end

			-- a^n => a*a*...*a,  n times, only for integer 2 <= n < 10
			-- hmm this can cause problems in some cases ... 
			-- comment this out to get schwarzschild_spherical_to_cartesian to work
			if require 'symmath.set.sets'.integer:contains(expr[2])
			and expr[2].value >= 2
			and expr[2].value < 10
			then
				local symmath = require 'symmath'
				if symmath.simplifyConstantPowers 
				and Constant.is(expr[1])
				then
					return Constant(expr[1].value ^ expr[2].value)
				end
				local new = setmetatable(range(expr[2].value):mapi(function(i)
					return expr[1]:clone()
				end), mul)
				return expand:apply(new)
			end
			--]]
		end},
	},

-- with this, polyCoeffs works
-- without this, equations look a whole lot cleaner during simplificaton
-- (and dividing polys works a bit better)
-- until factor() works, simplify() works better without this enabled ... but polyCoeffs() doesn't ... 
-- [[
	ExpandPolynomial = {
		{apply = function(expandPolynomial, expr)
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
	--print('pow a^0 => 1', require 'symmath.export.Verbose'(original), '=>', require 'symmath.export.Verbose'(Constant(1)))
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
		end},
	--]]
	},

	Prune = {
		{apply = function(prune, expr)
			local symmath = require 'symmath'	-- needed for flags
			local mul = symmath.op.mul
			local div = symmath.op.div
			local Constant = symmath.Constant

			local complex = require 'symmath.complex'

			if Constant.is(expr[1]) and Constant.is(expr[2]) then
				if symmath.simplifyConstantPowers
				-- TODO this replaces some cases below
				or require 'symmath.set.sets'.integer:contains(expr[1]) and expr[2].value > 0
				then
					return Constant(expr[1].value ^ expr[2].value)
				end
			end

			-- sqrt(something)
			if (
				-- expr[2] == frac(1,2) ... without extra object instanciation
				div.is(expr[2])
				and Constant.isValue(expr[2][1], 1)
				and Constant.isValue(expr[2][2], 2)
			) or Constant.isValue(expr[2], .5) then
				local x = expr[1]

				-- polynomials 
				-- quadratic so far
				-- sqrt(a^2 + 2ab + b^2) = a + b
				-- TODO now we have to consider domains ... this is only true for (a+b)>0 ... or two roots for +-
				-- ... hmm, this is looking very ugly and specific
				local function isSquare(x)
					return pow.is(x) and Constant.isValue(x[2], 2)
				end
				-- this matches the top of add.Factor
				if #x == 3 then
					local squares = table()
					local notsquares = table()
					for i,xi in ipairs(x) do
						(isSquare(xi) and squares or notsquares):insert(i)
					end
					if #squares == 2 then
						assert(#notsquares == 1)
						local a,c = x[squares[1]], x[squares[2]]
						local b = x[notsquares[1]]
						if b == symmath.op.mul(2, a[1], c[1]) then
							return prune:apply(a[1] + c[1])
						end
						if b == symmath.op.mul(Constant(-2), a[1], c[1]) then
							return prune:apply(a[1] - c[1])
						end
					end
				end
				
				-- dealing with constants
				local imag
				if symmath.op.unm.is(x) 
				and Constant.is(x[1])
				then
					x = x[1]
					imag = true
				end
				if Constant.is(x) and x.value < 0 then
					imag = not imag
					x = Constant(-x.value)
				end
				if require 'symmath.set.sets'.integer:contains(x) and x.value > 0 then
					local primes = require 'symmath.primeFactors'(x.value)
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
					
					local result
					if inside == 1 and outside == 1 then 
						result = Constant(1) 
					elseif outside == 1 then 
						result = Constant(inside)^div(1,2) 
					elseif inside == 1 then 
						result = Constant(outside) 
					else
						result = outside * inside^div(1,2)
					end
					if imag then result = symmath.i * result end
					return result
				end
			end
		
			-- 0^a = 0 for a>0
			if Constant.isValue(expr[1], 0) then
				if (Constant.is(expr[2]) and expr[2].value > 0) 
				or (
					div.is(expr[2]) 
					and Constant.is(expr[2][1]) 
					and Constant.is(expr[2][2]) 
					and (expr[2][1].value > 0) == (expr[2][2].value > 0)
				) then
					return Constant(0)
				end
			end

			-- 1^a => 1
			if Constant.isValue(expr[1], 1) then return Constant(1) end
			
			-- (-1)^odd = -1, (-1)^even = 1
			if Constant.isValue(expr[1], -1) and Constant.is(expr[2]) then
				local powModTwo = expr[2].value % 2
				if powModTwo == 0 then return Constant(1) end
				if powModTwo == 1 then return Constant(-1) end
			end
			
			-- a^1 => a
			if Constant.isValue(expr[2], 1) then return prune:apply(expr[1]) end
			
			-- a^0 => 1
			if Constant.isValue(expr[2], 0) then return Constant(1) end

			-- i^n
			if expr[1] == symmath.i 
			and require 'symmath.set.sets'.integer:contains(expr[2]) 
			then
				local v = expr[2].value % 4
				if v == 0 then
					return Constant(1)
				elseif v == 1 then
					return symmath.i
				elseif v == 2 then
					return Constant(-1)
				elseif v == 3 then
					return -symmath.i
				end
				-- fraction?
				if v < 0 or v >= 4 then
					return symmath.i^(v%4)
				end
			end
			
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

			-- exp(i*x) => cos(x) + i*sin(x)
			-- do this before a^-c => 1/a^c, 
			if symmath.e == expr[1] then
				local inside = expr[2]
				if symmath.op.mul.is(inside) then
					local j = table.find(inside, nil, function(y) return y == symmath.i end)
					if j then
						inside = inside:clone()
						table.remove(inside, j)
						if #inside == 1 then inside = inside[1] end
						return cos(inside) + i * sin(inside)
					end
				end
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

			-- e^log(x) == x
			if symmath.e == expr[1]
			and require 'symmath.log'.is(expr[2])
			then
				return prune:apply(expr[2][1])
			end
		end},
	},

	Tidy = {
		{apply = function(tidy, expr)
			local unm = require 'symmath.op.unm'
			local div = require 'symmath.op.div'
			local Constant = require 'symmath.Constant'
			local sqrt = require 'symmath.sqrt'

			-- [[ x^-a => 1/x^a ... TODO only do this when in a product?
			if unm.is(expr[2]) then
				return tidy:apply(Constant(1)/expr[1]^expr[2][1])
			end
			--]]
			
			if Constant.isValue(expr[2], .5)
			or (
				div.is(expr[2])
				and Constant.isValue(expr[2][1], 1)
				and Constant.isValue(expr[2][2], 2)
			) then
				return sqrt(expr[1])
			end
		end},
	},
}
-- ExpandPolynomial inherits from Expand
--pow.rules.ExpandPolynomial = pow.rules.Expand
-- but don't do it because it's overwritten for this class

return pow
