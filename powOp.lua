local class = require 'ext.class'
local table = require 'ext.table'
local BinaryOp = require 'symmath.BinaryOp'
local powOp = class(BinaryOp)

powOp.omitSpace = true
powOp.precedence = 5
powOp.name = '^'

--[[
d/dx(a^b)
d/dx(exp(log(a^b)))
d/dx(exp(b*log(a)))
exp(b*log(a)) * d/dx[b*log(a)]
a^b * (db/dx * log(a) + b * d/dx[log(a)])
a^b * (db/dx * log(a) + da/dx * b / a)
--]]
function powOp:evaluateDerivative(...)
	local symmath = require 'symmath'
	local log = symmath.log
	local diff = symmath.diff
	local a, b = table.unpack(self)
	a, b = a:clone(), b:clone()
	return a ^ b * (diff(b, ...) * log(a) + diff(a, ...) * b / a)
end

-- just for this
-- temporary ...
function powOp:expand()
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

powOp.visitorHandler = {
	Eval = function(eval, expr)
		local a, b = table.unpack(expr)
		return eval:apply(a) ^ eval:apply(b)
	end,
	
	-- this isn't here because factoring isnt fully implmented yet
	--[[ so until then I'll make it its own function ...
	Expand = function(expand, expr)
		local Constant = require 'symmath.Constant'
		-- for certain small integer powers, expand 
		-- ... or should we have all integer powers expended under a different command?
		if Constant.is(expr[2])
		and expr[2].value >= 0
		and expr[2].value < 10
		and expr[2].value == math.floor(expr[2].value)
		then
			local result = Constant(1)
			for i=1,expr[2].value do
				result = result * expr[1]:clone()
			end
			return result:simplify()
		end
	end,
	--]]

-- with this, polyCoeffs works
-- without this, equations look a whole lot cleaner during simplificaton
-- (and dividing polys works a bit better)
-- until factor() works, simplify() works better without this enabled ... but polyCoeffs() doesn't ... 
-- [[
	ExpandPolynomial = function(expandPolynomial, expr)
		local symmath = require 'symmath'
		local clone = symmath.clone
		local Constant = symmath.Constant
		
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
--print('powOp a^0 => 1', require 'symmath.tostring.Verbose'(original), '=>', require 'symmath.tostring.Verbose'(Constant(1)))
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
					local mulOp = require 'symmath.mulOp'
					expr = mulOp(terms:unpack())
				end
				
				if div then expr = 1/expr end
				
				return expandPolynomial:apply(expr)
			end
		end
	end,
--]]

	Prune = function(prune, expr)
		local symmath = require 'symmath'
		local mulOp = symmath.mulOp
		local divOp = symmath.divOp
		local Constant = symmath.Constant

		local function isInteger(x) return x == math.floor(x+.5) end
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
		and (expr[2] == divOp(1,2) or expr[2] == Constant(.5))
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
			if outside == 1 then return Constant(inside)^divOp(1,2) end
			if inside == 1 then return Constant(outside) end
			return Constant(outside) * Constant(inside)^divOp(1,2)
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
		if powOp.is(expr[1]) then
			return prune:apply(expr[1][1] ^ (expr[1][2] * expr[2]))
		end
		
		-- (a * b) ^ c => a^c * b^c
		if mulOp.is(expr[1]) then
			local result = table.map(expr[1], function(v,k)
				if type(k) ~= 'number' then return end
				return v ^ expr[2]
			end)
			assert(#result > 0)
			if #result == 1 then
				result = result[1]
			else
				result = mulOp(result:unpack())
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
			local m = mulOp()
			for i=1,expr[2].value do
				table.insert(m, expr[1]:clone())
			end
			
			return prune:apply(m)
		end
		--]]
	end,

	Tidy = function(tidy, expr)
		local symmath = require 'symmath'
		local unmOp = symmath.unmOp
		local Constant = symmath.Constant
		local sqrt = symmath.sqrt

		-- [[ x^-a => 1/x^a ... TODO only do this when in a product?
		if unmOp.is(expr[2]) then
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
--powOp.visitorHandler.ExpandPolynomial = powOp.visitorHandler.Expand
-- but don't do it because it's overwritten for this class

return powOp
