local class = require 'ext.class'
local table = require 'ext.table'
local range = require 'ext.range'
local Binary = require 'symmath.op.Binary'
local primeFactors = require 'symmath.primeFactors'

local symmath

local div = class(Binary)
div.precedence = 3.5
div.name = '/'

function div:evaluateDerivative(deriv, ...)
	local a, b = self[1], self[2]
	a, b = a:cloneIfMutable(), b:cloneIfMutable()
	return (deriv(a, ...) * b - a * deriv(b, ...)) / (b * b)
end

function div:reverse(soln, index)
	local p,q = table.unpack(self)
	-- y = p(x) / q => p(x) = q * y
	if index == 1 then
		soln = soln * q:cloneIfMutable()
	-- y = p / q(x) => q(x) = p / y
	elseif index == 2 then
		soln = p:cloneIfMutable() / soln
	end
	return soln
end

function div:getRealDomain()
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
	self.cachedSet = I / I2
	return self.cachedSet
end

local function toProdList(x)
	symmath = symmath or require 'symmath'
	local mul = symmath.op.mul
	local Constant = symmath.Constant
	if mul:isa(x) then return table(x) end
	if Constant.isValue(x, 1) then return table() end
	return table{x}
end

local function fromProdList(x)
	symmath = symmath or require 'symmath'
	local mul = symmath.op.mul
	local Constant = symmath.Constant
	if #x == 0 then return Constant(1) end
	if #x == 1 then return x[1] end
	return mul(x:unpack())
end

div.rules = {
	DistributeDivision = {
		{apply = function(distributeDivision, expr)
			symmath = symmath or require 'symmath'
			local add = symmath.op.add
			local num, denom = expr[1], expr[2]
			if not add:isa(num) then return end
			return getmetatable(num)(range(#num):map(function(k)
				return (num[k] / denom):simplify()
			end):unpack())
		end},
	},

	Eval = {
		{apply = function(eval, expr)
			local a, b = table.unpack(expr)
			return eval:apply(a) / eval:apply(b)
		end},
	},

	--[[ here's me trying to better simplify fractions ...
	-- but it requires parent traversal first ...
	Expand = {
		{apply = function(expand, expr)
			return expand:apply(expr[1]) / expr[2]
		end},
	},
	--]]

	FactorDivision = {
		{apply = function(factorDivision, expr)
			symmath = symmath or require 'symmath'
			local Constant = symmath.Constant
			local mul = symmath.op.mul

			if Constant.isValue(expr[1], 1) then return end
		
			-- a/(b1 * ... * bn) => a * 1/b1 * ... * 1/bn
			if mul:isa(expr[2]) then
				local prod = mul(expr[1], range(#expr[2]):mapi(function(i)
					return 1 / expr[2][i]:clone()
				end):unpack())
				return factorDivision:apply(prod)
			end

			-- a/b => a * 1/b
			return factorDivision:apply(expr[1] * (Constant(1)/expr[2]))
		end},
	},

	Prune = {		
		{apply = function(prune, expr)
			symmath = symmath or require 'symmath'
			local unm = symmath.op.unm
			local add = symmath.op.add
			local mul = symmath.op.mul
			local div = symmath.op.div
			local pow = symmath.op.pow
			local Array = symmath.Array
			local Constant = symmath.Constant

			-- matrix/scalar
			do
				local a, b = table.unpack(expr)
				if Array:isa(a) and not Array:isa(b) then
					local result = a:clone()
					for i=1,#result do
						result[i] = result[i] / b
					end
					return prune:apply(result)
				end
			end

			-- x / 0 => Invalid
			if Constant.isValue(expr[2], 0) then
				return symmath.Invalid()
			end
			
			if symmath.simplifyConstantPowers  then
				-- Constant / Constant => Constant
				if Constant:isa(expr[1]) and Constant:isa(expr[2]) then
					return Constant(expr[1].value / expr[2].value)
				end

				-- q / Constant = 1/Constant * q
				if Constant:isa(expr[2]) then
					return prune:apply(
						Constant(1/expr[2].value) * expr[1]
					)
				end
		
				-- (c1 * m) / c2 => (c1 / c2) * m
				if mul:isa(expr[1]) and Constant:isa(expr[1][1]) and Constant:isa(expr[2]) then
					local rest = #expr[1] == 2 and expr[1][2] or mul(table.unpack(expr[1], 2))
					return Constant(expr[1][1].value / expr[2].value) * rest
				end
			
				-- c1 / (c2 * m) => (c1/c2) / m
				if Constant:isa(expr[1]) and mul:isa(expr[2]) and Constant:isa(expr[2][1]) then
					local rest = #expr[2] == 2 and expr[2][2] or mul(table.unpack(expr[2], 2))
					return Constant(expr[1].value / expr[2][1].value) / rest
				end
		
				-- (c1 * m1) / (c2 * m2) => ((c1/c2) * m1) / m2
				if mul:isa(expr[1]) and Constant:isa(expr[1][1])
				and mul:isa(expr[2]) and Constant:isa(expr[2][1])
				then
					local rest1 = #expr[1] == 2 and expr[1][2] or mul(table.unpack(expr[1], 2))
					local rest2 = #expr[2] == 2 and expr[2][2] or mul(table.unpack(expr[2], 2))
					return (Constant(expr[1][1].value / expr[2][1].value) * rest1) / rest2
				end
			end

			-- x / 1 => x
			if Constant.isValue(expr[2], 1) then
				return expr[1]
			end

			-- x / -1 => -1 * x
			if Constant:isa(expr[2]) and expr[2].value < 0 then
				return prune:apply(Constant(-1) * expr[1] / Constant(-expr[2].value))
			end
			
			-- 0 / x => 0
			if Constant.isValue(expr[1], 0) then
				if expr[1].value == 0 then
					return Constant(0)
				end
			end
			
			-- (a / b) / c => a / (b * c)
			if div:isa(expr[1]) then
				return prune:apply(expr[1][1] / (expr[1][2] * expr[2]))
			end
			
			-- a / (b / c) => (a * c) / b
			if div:isa(expr[2]) then
				local a, b = table.unpack(expr)
				local b, c = table.unpack(b)
				return prune:apply((a * c) / b)
			end

			if expr[1] == expr[2] then
				return Constant(1)		-- ... for expr[1] != 0
			end

			-- [[ 
			-- conjugates of square-roots in denominator
			-- a / (b + sqrt(c)) => a (b - sqrt(c)) / ((b + sqrt(c)) (b - sqrt(c))) => a (b - sqrt(c)) / (b^2 - c)
			--[=[ the (b + sqrt(c)) matches the remaining Wildcard 
			local a,b,c,d = expr:match(Wildcard(1) / ((Wildcard(2) + Wildcard(3) ^ div(1,2)) * Wildcard(4)))
			if a then
				print('a\n'..a..'\nb\n'..b..'\nc\n'..c..'\nd\n'..d)
				error'here'
			end
			--]=]
			local Wildcard = symmath.Wildcard
			local num, denom = table.unpack(expr)
			if mul:isa(denom) then
				for i=1,#denom do
					if add:isa(denom[i]) then
						local a, b, c = denom[i]:match(Wildcard(1) + Wildcard(2) * Wildcard(3) ^ div(1,2)) 
						if a then
							denom = denom:clone()
							table.remove(denom, i)
							table.insert(denom, (a^2 - b^2 * c))
							return prune:apply((expr[1] * (a - b * c ^ div(1,2))) / denom)
						end
					end
				end
			end
			--]]


			local num, denom = table.unpack(expr)
			local numlist = toProdList(num)
			local denomlist = toProdList(denom)
			local lists = {numlist, denomlist}
			local modified

			-- [[ put negative powers on the opposite side of the div
			-- div -> mul -> pow -> unm => switch side of div and negative pow
			local mul = symmath.op.mul
			local pow = symmath.op.pow
			local unm = symmath.op.unm
			for k=1,2 do
				local fromlist = lists[k]
				local tolist = lists[3-k]
				for i=#fromlist,1,-1 do
					if pow:isa(fromlist[i]) then
						if symmath.set.negativeReal:contains(fromlist[i][2]) then
							modified = true
							local repl = symmath.clone(table.remove(fromlist, i))
							if Constant:isa(repl[2]) then
								repl[2] = Constant(-repl[2].value)
							elseif unm:isa(repl[2]) then
								repl[2] = repl[2][1]
							elseif div:isa(repl[2]) then
								repl[2][1] = prune:apply(-repl[2][1])
							else
								repl[2] = prune:apply(-repl[2])
							end
							tolist:insert(repl)
						end
					end
				end
			end
			if modified then
				-- prune:apply() causes an infinite loop ... 
				--return prune:apply(fromProdList(numlist) / fromProdList(denomlist))
				return fromProdList(numlist) / fromProdList(denomlist)
			end
			--]]

			-- [[ any sqrt()s on the bottom, multiply by bottom and top 
			for i=1,#denomlist do
				if pow:isa(denomlist[i])
				and div:isa(denomlist[i][2])
				-- TODO any fraction, esp odd fractions
				and Constant.isValue(denomlist[i][2][1], 1)
				and Constant.isValue(denomlist[i][2][2], 2)
				then
					modified = true
					numlist:insert(denomlist[i])
					denomlist[i] = denomlist[i][1]
				end
			end
			if modified then
				return prune:apply(fromProdList(numlist) / fromProdList(denomlist))
				--return fromProdList(numlist) / fromProdList(denomlist)
			end
			--]]

			-- [[ a / (-c * b) => -a / (c * b)
			local num, denom = table.unpack(expr)
			if mul:isa(denom) then
				for i=1,#denom do
					if Constant:isa(denom[i])
					and denom[i].value < 0
					then
						denom = denom:clone()
						denom[i] = Constant(-denom[i].value)
						return prune:apply(-num / denom)
					end
				end
			end
			--]]

			-- (r^m * a * b * ...) / (r^n * x * y * ...) => (r^(m-n) * a * b * ...) / (x * y * ...)
			-- TODO combine this with the stuff in add.Factor somehow
			-- that builds lists of term=, power= as well
			do
				local modified
				local nums, denoms
				if mul:isa(expr[1]) then
					nums = table(expr[1])
				else
					nums = table{expr[1]}
				end
				if mul:isa(expr[2]) then
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
						if pow:isa(x) then
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
						if symmath.set.integer:contains(b) 
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
						if not Constant.isValue(numBases[i], 1)
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
							num = mul(num:unpack())
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
							denom = mul(denom:unpack())
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

			-- [[ a / b^(p/q) => (a / b^(p/q)) * (b^((q-p)/q) / b^((q-p)/q)) => (a * b^((q-p)/q)) / b
			local Wildcard = symmath.Wildcard
			local a, b, p, q = expr:match(Wildcard(1) / Wildcard(2) ^ (Wildcard(3) / Wildcard(4)))
			if a then
				if Constant.isValue(a, 1) then
					return prune:apply(b ^ ((q - p) / q) / b)
				else
					return prune:apply(a * b ^ ((q - p) / q) / b)
				end
			end
			--]]

			--[[ (a + b) / c => a/c + b/c ...
			local add = require 'symmath.op.add'
			if add:isa(expr[1]) then
				return prune:apply(add(
					table.mapi(expr[1], function(x)
						return x / expr[2]
					end):unpack()))
			end
			--]]

			-- this would be helpful if it wasn't evaluated after children, where exponent polys get distributed
			-- do I need a bubble-in/bubble-out callback?
			-- I just got this to call first by calling the *same* callback before and after child recursion
			-- that might be a bad idea, but it solves this problem.
			-- but that screws up things elsewhere ...
			--[[
			-- x / x^a => x^(1-a)
			if pow:isa(expr[2]) and expr[1] == expr[2][1] then
				return prune:apply(expr[1]:clone() ^ (1 - expr[2][2]:clone()))
			end
			
			-- x^a / x => x^(a-1)
			if pow:isa(expr[1]) and expr[1][1] == expr[2] then
				return prune:apply(expr[1][1]:clone() ^ (expr[1][2]:clone() - 1))
			end
			
			-- x^a / x^b => x^(a-b)
			if pow:isa(expr[1])
			and pow:isa(expr[2])
			and expr[1][1] == expr[2][1]
			then
				return prune:apply(expr[1][1]:clone() ^ (expr[1][2]:clone() - expr[2][2]:clone()))
			end
			--]]
		
			--[[ TODO attempt polynomial division?  or put that in :factor()?
			if add:isa(expr[1]) then
				local a,b = expr[1], expr[2]
				local q = Constant(0)
				local r = a
			end
			--]]
		
			--[[ cheat
			-- now that cos.rules.Prune has simplified all the cos^2's into sin^2's
			-- if there's a div that needs to be simplified, there could be some extra terms not simplified
			-- (1 - sin(theta)^2) / cos(theta) = cos(theta)^2 / cos(theta) = cos(theta)
			do
				local sin = require 'symmath.sin'
				local cos = require 'symmath.cos'
				if cos:isa(expr[2]) then
					local inside = expr[2][1]
					if expr[1]() == (1 - sin(inside)^2)() then
						return cos(inside)
					end
				end
			end
			--]]
		end},	

		-- this could go after the apply rule, but that ends with a subsequent prune(a)/prune(b) ..
		{logPow = function(prune, expr)
			symmath = symmath or require 'symmath'
			-- log(a) / b => log(a^(1/b))
			if symmath.log:isa(expr[1]) then
				local a = expr[1][1]
				local b = expr[2]
				return prune:apply(symmath.log(a ^ (1 / b)))
			end
		end},
	},

	Tidy = {
		{apply = function(tidy, expr)
			symmath = symmath or require 'symmath'
			local unm = symmath.op.unm
			local Constant = symmath.Constant
			
			local a, b = table.unpack(expr)
			local ua = unm:isa(a)
			local ub = unm:isa(b)
			if ua and ub then return tidy:apply(a[1] / b[1]) end
			if ua and Constant:isa(a[1]) then return tidy:apply(-(a[1] / b)) end
			if ub and Constant:isa(b[1]) then return tidy:apply(-(a / b[1])) end
		end},
	},
}

return div
