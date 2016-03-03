local class = require 'ext.class'
local table = require 'ext.table'
local range = require 'ext.range'
local BinaryOp = require 'symmath.BinaryOp'

local divOp = class(BinaryOp)
divOp.precedence = 3.5
divOp.name = '/'

function divOp:evaluateDerivative(...)
	local a, b = self[1], self[2]
	a, b = a:clone(), b:clone()
	local diff = require 'symmath'.diff
	return (diff(a, ...) * b - a * diff(b, ...)) / (b * b)
end

divOp.visitorHandler = {
	DistributeDivision = function(distributeDivision, expr)
		local addOp = require 'symmath.addOp'
		local num, denom = expr[1], expr[2]
		if not addOp.is(num) then return end
		return getmetatable(num)(range(#num):map(function(k)
			return (num[k] / denom):simplify()
		end):unpack())
	end,

	Eval = function(eval, expr)
		local a, b = table.unpack(expr)
		return eval:apply(a) / eval:apply(b)
	end,

	FactorDivision = function(factorDivision, expr)
		local Constant = require 'symmath.Constant'
		if expr[1] == Constant(1) then return end
		return factorDivision:apply(expr[1] * (Constant(1)/expr[2]))
	end,

	Prune = function(prune, expr)
		local symmath = require 'symmath'	-- for debug flags ...
		local mulOp = symmath.mulOp
		local divOp = symmath.divOp
		local powOp = symmath.powOp
		local Array = symmath.Array
		local Constant = symmath.Constant

		-- matrix/scalar
		do
			local a, b = table.unpack(expr)
			if Array.is(a) and not Array.is(b) then
				local result = a:clone()
				for i=1,#result do
					result[i] = result[i] / b
				end
				return prune:apply(result)
			end
		end

		-- x / 0 => Invalid
		if expr[2] == Constant(0) then
			return Invalid()
		end
		
		if symmath.simplifyConstantPowers  then
			-- Constant / Constant => Constant
			if Constant.is(expr[1]) and Constant.is(expr[2]) then
				return Constant(expr[1].value / expr[2].value)
			end

			-- mul / Constant = 1/Constant * mul
			if mulOp.is(expr[1]) and Constant.is(expr[2]) then
				local m = expr[1]:clone()
				if #m == 0 then
					return prune:apply(Constant(1/expr[2].value))
				else
					return prune:apply(mulOp(Constant(1/expr[2].value), table.unpack(m)))
				end
			end
		end

		-- x / 1 => x
		if expr[2] == Constant(1) then
			return expr[1]
		end

		-- x / -1 => -1 * x
		if Constant.is(expr[2]) and expr[2].value < 0 then
			return prune:apply(Constant(-1) * expr[1] / Constant(-expr[2].value))
		end
		
		-- 0 / x => 0
		if expr[1] == Constant(0) then
			if expr[1].value == 0 then
				return Constant(0)
			end
		end
		
		-- (a / b) / c => a / (b * c)
		if divOp.is(expr[1]) then
			return prune:apply(expr[1][1] / (expr[1][2] * expr[2]))
		end
		
		-- a / (b / c) => (a * c) / b
		if divOp.is(expr[2]) then
			local a, b = table.unpack(expr)
			local b, c = table.unpack(b)
			return prune:apply((a * c) / b)
		end

		if expr[1] == expr[2] then
			return Constant(1)		-- ... for expr[1] != 0
		end

		-- (r^m * a * b * ...) / (r^n * x * y * ...) => (r^(m-n) * a * b * ...) / (x * y * ...)
		do
			local modified
			local nums, denoms
			if mulOp.is(expr[1]) then
				nums = table(expr[1])
			else
				nums = table{expr[1]}
			end
			if mulOp.is(expr[2]) then
				denoms = table(expr[2])
			else
				denoms = table{expr[2]}
			end
			
			local function listToBasesAndPowers(list)
				local bases = table()
				local powers = table()
				for i=1,#list do
					local x = list[i]
					local base, power
					if powOp.is(x) then
						base, power = table.unpack(x)
					else
						base, power = x, Constant(1)
					end
					bases[i] = assert(base)
					powers[i] = assert(power)
				end
				return bases, powers
			end
			
			local numBases, numPowers = listToBasesAndPowers(nums)
			local denomBases, denomPowers = listToBasesAndPowers(denoms)
		
			-- split any constant integers into its prime factorization
			for _,info in ipairs{
				{numBases, numPowers},
				{denomBases, denomPowers}
			} do
				local bases, powers = table.unpack(info)
				for i=#bases,1,-1 do
					local b = bases[i]
					if Constant.is(b)
					and b.value == math.floor(b.value + .5)	--integer
					and b.value ~= 0
					then
						bases:remove(i)
						local value = b.value
						local power = powers:remove(i)
						if value < 0 then	-- insert -1 if necessary
							bases:insert(i, Constant(-1))
							powers:insert(i, power:clone())
							value = -value
						end
						if value == 1 then
							bases:insert(i, Constant(1))
							powers:insert(i, power:clone())
						else
							local primeFactors = require 'symmath.primeFactors'
							local fs = primeFactors(value)	-- 1 returns a nil list
							for _,f in ipairs(fs) do
								bases:insert(i, f)
								powers:insert(i, power:clone())
							end
						end
					end
				end
			end

			-- TODO move minus sign to the top
			-- TODO if the coefficients are non-integers then just divide them

			-- from this point on, nums and denoms don't match up with numBases (specifically because of the prime factorization of integers)
			-- so don't worry about and don't use nums and denoms

			for i=1,#numBases do
				for j=#denomBases,1,-1 do
					if numBases[i] ~= Constant(1)
					and numBases[i] == denomBases[j] 
					then
						modified = true
						local resultPower = numPowers[i] - denomPowers[j]
						numPowers[i] = resultPower
						denomBases:remove(j)
						denomPowers:remove(j)
					end
				end
			end
			
			if modified then
				if #numBases == 0 and #denomBases == 0 then return Constant(1) end

				-- can I construct these even if they have no terms?
				local num
				if #numBases > 0 then
					num = numBases:map(function(v,i) 
						return v ^ numPowers[i]
					end)
					assert(#num > 0)
					if #num == 1 then
						num = num[1]
					else
						num = mulOp(num:unpack())
					end
				end
				local denom
				if #denomBases > 0 then
					denom = denomBases:map(function(v,i) 
						return v ^ denomPowers[i]
					end)
					assert(#denom > 0)
					if #denom == 1 then
						denom = denom[1]
					else
						denom = mulOp(denom:unpack())
					end
				end
				
				local result
				if #numBases == 0 then
					result = Constant(1) / denom
				elseif #denomBases == 0 then
					result = num
				else
					result = num / denom
				end

				return prune:apply(result)
			end
		end

		--[[ (a + b) / c => a/c + b/c ...
		local addOp = require 'symmath.addOp'
		if addOp.is(expr[1]) then
			return prune:apply(addOp(
				table.map(expr[1], function(x,k)
					if type(k) ~= 'number' then return end
					return x / expr[2]
				end):unpack()))
		end
		--]]

		--[[
		
		-- x / x^a => x^(1-a)
		if powOp.is(expr[2]) and expr[1] == expr[2][1] then
			return prune:apply(expr[1] ^ (1 - expr[2][2]))
		end
		
		-- x^a / x => x^(a-1)
		if powOp.is(expr[1]) and expr[1][1] == expr[2] then
			return prune:apply(expr[1][1] ^ (expr[1][2] - 1))
		end
		
		-- x^a / x^b => x^(a-b)
		if powOp.is(expr[1])
		and powOp.is(expr[2])
		and expr[1][1] == expr[2][1]
		then
			return prune:apply(expr[1][1] ^ (expr[1][2] - expr[2][2]))
		end
		--]]
	end,

	Tidy = function(tidy, expr)
		local symmath = require 'symmath'
		local unmOp = symmath.unmOp
		local Constant = symmath.Constant
		
		local a, b = table.unpack(expr)
		local ua = unmOp.is(a)
		local ub = unmOp.is(b)
		if ua and ub then return tidy:apply(a[1] / b[1]) end
		if ua and Constant.is(a[1]) then return tidy:apply(-(a[1] / b)) end
		if ub and Constant.is(b[1]) then return tidy:apply(-(a / b[1])) end
	end,
}

return divOp
