local class = require 'ext.class'
local table = require 'ext.table'
local range = require 'ext.range'
local Binary = require 'symmath.op.Binary'
local complex = require 'symmath.complex'
local primeFactors = require 'symmath.primeFactors'
local symmath

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
	symmath = symmath or require 'symmath'
	local log = symmath.log
	local a, b = table.unpack(self)
	a, b = a:clone(), b:clone()

-- [[
	-- shorthand ...
	local Constant = symmath.Constant
	if Constant:isa(b) then
		if Constant:isa(a) then
			-- a & b are constant ... a^b is constant ... d/dx (a^b) = 0
			return Constant(0)
		end
	
		-- b is constant, a is not ... d/dx (a^b) = b a^(b-1) * d/dx(a)
		return b * a ^ Constant(b.value-1) * deriv(a, ...)
	elseif Constant:isa(a) then
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
	symmath = symmath or require 'symmath'
	local Constant = symmath.Constant
	if not Constant:isa(self[2]) then return end
	local n = self[2].value
	-- for certain small integer powers, expand 
	-- ... or should we have all integer powers expended under a different command?
	if symmath.set.integer:contains(self[2])
	and n >= 0
	and n < 10
	then
		local result = Constant(1)
		for i=1,n do
			result = result * self[1]
		end
		return result
	end
end

function pow:reverse(soln, index)
	symmath = symmath or require 'symmath'
	local Constant = symmath.Constant
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
		local log = symmath.log
		return log(y) / log(p)
	end
end

function pow:getRealDomain()
	if self.cachedSet then return self.cachedSet end
	local I = self[1]:getRealDomain()
	if I == nil then 
		self.cachedSet = nil
		return nil 
	end
	local I2 = self[2]:getRealDomain()
	if I2 == nil then 
		self.cachedSet = nil
		return nil 
	end
	self.cachedSet = I ^ I2
	return self.cachedSet
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
			symmath = symmath or require 'symmath'
			local div = symmath.op.div
			local mul = symmath.op.mul
			local Constant = symmath.Constant
			
			-- (a / b)^n => a^n / b^n
			-- not simplifying ...
			-- maybe this should go in factor() or expand()
			if div:isa(expr[1]) then
				local num = expr[1][1] ^ expr[2]
				local denom = expr[1][2] ^ expr[2]
				local repl = num / denom
				return expand:apply(repl)
			end

			-- a^n => a*a*...*a,  n times, only for integer 2 <= n < 10
			-- hmm this can cause problems in some cases ... 
			-- comment this out to get schwarzschild_spherical_to_cartesian to work
			if symmath.set.integer:contains(expr[2])
			and expr[2].value >= 2
			and expr[2].value < 10
			then
				if symmath.simplifyConstantPowers 
				and Constant:isa(expr[1])
				then
					return Constant(expr[1].value ^ expr[2].value)
				end
				return setmetatable(table{expr[1]}:rep(expr[2].value), mul)
			end
		end},
	},

-- with this, polyCoeffs works
-- without this, equations look a whole lot cleaner during simplificaton
-- (and dividing polys works a bit better)
-- until factor() works, simplify() works better without this enabled ... but polyCoeffs() doesn't ... 
-- [[
	ExpandPolynomial = {
		{apply = function(expandPolynomial, expr)
			symmath = symmath or require 'symmath'
			local clone = symmath.clone
			local Constant = symmath.Constant
			
			expr = clone(expr)
	--local original = clone(expr)
			local maxPowerExpand = 10
			if Constant:isa(expr[2]) then
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
						local mul = symmath.op.mul
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
			symmath = symmath or require 'symmath'	-- needed for flags
			local mul = symmath.op.mul
			local div = symmath.op.div
			local Constant = symmath.Constant
			local sets = symmath.set


-- [[ here is me trying to solve a sqrt problem
			-- x^(1/2) 
			-- TODO x^(p/q) 
			if (
				div:isa(expr[2])
				and Constant.isValue(expr[2][1], 1)
				and Constant.isValue(expr[2][2], 2)
			) or Constant.isValue(expr[2], .5) then
				local x = expr[1]
				local add = symmath.op.add
				if mul:isa(x)
				and #x == 2
				and Constant.isValue(x[1], -1)
				and add:isa(x[2])
				then
					local dstr = x:distribute()
					if dstr then return prune:apply(dstr^div(1,2)) end
				end
			end
--]]



			-- Hmm, i want the inside to distribute before the outside
			--  so (-1*-a)^(1/2) => sqrt(a)
			-- and not sqrt(-1)*sqrt(-a) = i*i*sqrt(a) = -sqrt(a)
			--expr = expr:clone()
			--expr[1] = expr[1]()
			-- But doing this doens't work.  It leaves some extra (-1)^2 terms on the inside.

			if Constant:isa(expr[1]) and Constant:isa(expr[2]) then
				if symmath.simplifyConstantPowers
				-- TODO this replaces some cases below
				or sets.integer:contains(expr[1]) and expr[2].value > 0
				then
					return Constant(expr[1].value ^ expr[2].value)
				end
			end
			
			-- this all matches the top of add.Factor

			-- x^(1/2)
			if (
				div:isa(expr[2])
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
					return pow:isa(x) and Constant.isValue(x[2], 2)
				end
				
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
			end


			-- x^(1/2) 
			-- TODO x^(p/q) 
			if (
				div:isa(expr[2])
				and Constant.isValue(expr[2][1], 1)
				and Constant.isValue(expr[2][2], 2)
			) or Constant.isValue(expr[2], .5) then
				local x = expr[1]

				-- dealing with constants
				local imag
				if symmath.op.unm:isa(x) 
				and Constant:isa(x[1])
				then
					x = x[1]
					imag = true
				end
				if Constant:isa(x) 
				and x.value < 0 
				-- and q is even
				then
					imag = not imag
					x = Constant(-x.value)
				end
				if sets.integer:contains(x) 
				and x.value > 0 
				then
					local primes = primeFactors(x.value)
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
				if (Constant:isa(expr[2]) and expr[2].value > 0) 
				or (
					div:isa(expr[2]) 
					and Constant:isa(expr[2][1]) 
					and Constant:isa(expr[2][2]) 
					and (expr[2][1].value > 0) == (expr[2][2].value > 0)
				) then
					return Constant(0)
				end
			end

			-- 1^a => 1
			if Constant.isValue(expr[1], 1) then return Constant(1) end
			
			-- (-1)^odd = -1, (-1)^even = 1
			if Constant.isValue(expr[1], -1) and Constant:isa(expr[2]) then
				local powModTwo = expr[2].value % 2
				if powModTwo == 0 then return Constant(1) end
				if powModTwo == 1 then return Constant(-1) end
			end
			
			-- a^1 => a
			if Constant.isValue(expr[2], 1) then return prune:apply(expr[1]) end
			
			-- a^0 => 1
			if Constant.isValue(expr[2], 0) then return Constant(1) end

			if expr[1] == symmath.i then
				-- i^n
				if Constant:isa(expr[2])
				and sets.integer:contains(expr[2]) 
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
			
				-- sqrt(i) = sqrt(2) + i sqrt(2)
				if div:isa(expr[2])
				and Constant.isValue(expr[2][1], 1)
				and Constant.isValue(expr[2][2], 2)
				then
					local sqrt = symmath.sqrt
					return div(1,sqrt(2)) + symmath.i * div(1,sqrt(2))
				end
			end
			
			-- (a ^ b) ^ c => a ^ (b * c)
			-- unless b is 2 and c is 1/2 ...
			-- in fact, only if c is integer
			-- in fact, better add complex numbers
			if pow:isa(expr[1]) then
				return prune:apply(expr[1][1] ^ (expr[1][2] * expr[2]))
			end
			
			-- (a * b) ^ c => a^c * b^c
			if mul:isa(expr[1]) then
				local result = table.mapi(expr[1], function(v)
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
				if symmath.op.mul:isa(inside) then
					local j = table.find(inside, nil, function(y) return y == symmath.i end)
					if j then
						inside = inside:clone()
						table.remove(inside, j)
						if #inside == 1 then inside = inside[1] end
						return symmath.cos(inside) + symmath.i * symmath.sin(inside)
					end
				elseif inside == symmath.i then
					return symmath.cos(Constant(1)) + symmath.i * symmath.sin(Constant(1))
				end
			end
		
			-- a^(-c) => 1/a^c
			if Constant:isa(expr[2]) and expr[2].value < 0 then
				return prune:apply(Constant(1)/(expr[1]^Constant(-expr[2].value)))
			end

			--[[ for simplification's sake ... (like -a => -1 * a)
			-- x^c => x*x*...*x (c times)
			if Constant:isa(expr[2])
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
			and symmath.log:isa(expr[2])
			then
				return prune:apply(expr[2][1])
			end
		end},
	},

	Tidy = {
		{apply = function(tidy, expr)
			symmath = symmath or require 'symmath'	-- needed for flags
			local sets = symmath.set
			local unm = symmath.op.unm
			local div = symmath.op.div
			local Constant = symmath.Constant
			local sqrt = symmath.sqrt
			local cbrt = symmath.cbrt

			-- [[ x^-a => 1/x^a ... TODO only do this when in a product?
			if unm:isa(expr[2]) then
				return tidy:apply(Constant(1)/expr[1]^expr[2][1])
			end
			--]]

			-- x^(p/q) = x^((qk+m)/q)
			-- p, q are integer Lua numbers
			local function checkNthRoot(expr, p, q)
				local m = p % q
				local k = (p - m) / q
				-- x^(p/q) = x^((qk+m)/q)
				local f = ({
					[2] = sqrt,
					[3] = cbrt,
				})[q]
				if f then
					-- TODO a n'th root Expression ?
					if m == 0 then
						-- x^((qk)/q) => x^k
						if k == 0 then return Constant(1) end	-- shouldn't occur
						if k == 1 then return expr end
						return expr ^ k
					elseif m == 1 then
						-- x^((qk+1)/q) => x^k f(x)
						if k == 0 then return f(expr) end
						if k == 1 then return expr * f(expr) end
						return expr ^ k * f(expr)
					else	-- m >= 2
						-- x^((qk+m)/q) => x^k f(x^m)
						if k == 0 then return f(expr ^ m) end
						if k == 1 then return expr * f(expr ^ m) end
						return expr ^ k * f(expr ^ m)
					end
				end
		
			end

			-- x ^ (p/q)
			-- p/q for p,q integers
			if div:isa(expr[2])
			and Constant:isa(expr[2][1])
			and sets.integer:contains(expr[2][1])
			and Constant:isa(expr[2][2])
			and sets.integer:contains(expr[2][2])
			-- TODO alternatively c ^ d where d = Constant with d.value == p/q?
			--  but how often can we detect the accuracy of that?  only for powers-of-two
			then
				local p = expr[2][1].value
				local q = expr[2][2].value
				local result = checkNthRoot(expr[1], p, q)
				if result then return result end
			end
	
			-- I'm not sure how many numbers I should entertain here
			-- I should do like Maxima and try to auto-deduce the fraction upon Constant construction (though that seems iffy for any rounded constants)
			-- That's why I only want to test for rational numbers from a few cases 
			if Constant:isa(expr[2]) then
				for q=2,3 do
					for p=1,q-1 do
						if expr[2].value == p/q then
							local result = checkNthRoot(expr[1], p, q)
							if result then return result end
						end
					end
				end
			end
		end},
	},
}
-- ExpandPolynomial inherits from Expand
--pow.rules.ExpandPolynomial = pow.rules.Expand
-- but don't do it because it's overwritten for this class

return pow
