--[[
local prune = require 'symmath.prune'
x = prune(x)

traverses x, child first, maps the nodes if they appear in the lookup table

the table can be expanded by adding an entry prune.lookupTable[class] to perform the necessary transformation
--]]
local class = require 'ext.class'
local unmOp = require 'symmath.unmOp'
local addOp = require 'symmath.addOp'
local subOp = require 'symmath.subOp'
local mulOp = require 'symmath.mulOp'
local divOp = require 'symmath.divOp'
local powOp = require 'symmath.powOp'
local Constant = require 'symmath.Constant'
local Derivative = require 'symmath.Derivative'
local Variable = require 'symmath.Variable'
local tableCommutativeEqual = require 'symmath.tableCommutativeEqual'
local Visitor = require 'symmath.visitor.Visitor'

local Prune = class(Visitor)
Prune.name = 'Prune'

Prune.lookupTable = {

	[Derivative] = function(prune, expr)

		-- d/dx{y_i} = {dy_i/dx}
		do
			local Array = require 'symmath.Array'
			if expr[1]:isa(Array) then
				local res = expr[1]:clone()
				for i=1,#res do
					res[i] = prune:apply(res[i]:diff(table.unpack(expr, 2)))
				end
				return res
			end
		end

		-- d/dx c = 0
		if expr[1]:isa(Constant) then
			return Constant(0)
		end

		-- d/dx d/dy = d/dxy
		if expr[1]:isa(Derivative) then
			return prune:apply(Derivative(expr[1][1], table.unpack(
				table.append({table.unpack(expr, 2)}, {table.unpack(expr[1], 2)})
			)))
		end

		-- apply differentiation
		-- don't do so if it's a diff of a variable that requests not to
		-- [[
		if expr[1]:isa(Variable)
		then
			local var = expr[1]
			-- dx/dx = 1
			if #expr == 2 and var == expr[2] then
				return Constant(1)
			end
			--dx/dy = 0 unless x is a function of y
			for i=2,#expr do
				local wrt = expr[i]

				-- and what about 2nd derivatives too?	
				
				if not var.dependentVars:find(wrt) then
					return Constant(0)
				end
			end
		end
		--]]

		if expr[1].evaluateDerivative then
			local result = expr[1]:clone()
			for i=2,#expr do
				-- TODO one at a time ...
				result = prune:apply(result:evaluateDerivative(expr[i]))
			end
			return result
		end
	end,
	
	[unmOp] = function(prune, expr)
		if expr[1]:isa(unmOp) then
			return prune:apply(expr[1][1]:clone())
		end
		return prune:apply(Constant(-1) * expr[1])
	end,
	
	[addOp] = function(prune, expr, ...)
		-- flatten additions
		-- (x + y) + z => x + y + z
		for i=#expr,1,-1 do
			local ch = expr[i]
			if ch:isa(addOp) then
				expr = expr:clone()
				-- this looks like a job for splice ...
				table.remove(expr, i)
				for j=#ch,1,-1 do
					local chch = assert(ch[j])
					table.insert(expr, i, chch)
				end
				return prune:apply(expr)
			end
		end
		
		-- c1 + x1 + c2 + x2 => (c1+c2) + x1 + x2
		local cval = 0
		for i=#expr,1,-1 do
			if expr[i]:isa(Constant) then
				cval = cval + table.remove(expr, i).value
			end
		end
		
		-- if it's all constants then return what we got
		if #expr == 0 then 
			return Constant(cval) 
		end
		
		-- re-insert if we have a Constant
		if cval ~= 0 then
			table.insert(expr, 1, Constant(cval))
		else
			-- if cval is zero and we're not re-inserting a constant
			-- then see if we have only one term ...
			if #expr == 1 then 
				return prune:apply(expr[1]) 
			end
		end

		-- any overloaded subclass simplification
		-- specifically used for vector/matrix addition
		-- only operate on neighboring elements - don't assume commutativitiy, and that we can exchange elements to be arbitrary neighbors
		for i=#expr,2,-1 do
			local rhs = expr[i]
			local lhs = expr[i-1]
			
			local result
			if lhs.pruneAdd then
				result = lhs.pruneAdd(lhs, rhs)
			elseif rhs.pruneAdd then
				result = rhs.pruneAdd(lhs, rhs)
			end
			if result then
				table.remove(expr, i)
				expr[i-1] = result
				if #expr == 1 then
					expr = expr[1]
				end
				return prune:apply(expr)
			end
		end

		-- [[ x * c1 + x * c2 => x * (c1 + c2) ... for constants
		do
			local muls = table()
			local nonMuls = table()
			for i,x in ipairs(expr) do
				if x:isa(mulOp) then
					muls:insert(x)
				else
					nonMuls:insert(x)
				end
			end
			if #muls > 1 then	-- we have more than one multiplication going on ... see if we can combine them
				local baseConst = 0
				local baseTerms
				local didntFind
				for _,mul in ipairs(muls) do
					local nonConstTerms = table.filter(mul, function(x,k) 
						if type(k) ~= 'number' then return end
						return not x:isa(Constant) 
					end)
					if not baseTerms then
						baseTerms = nonConstTerms
					else
						if not tableCommutativeEqual(baseTerms, nonConstTerms) then
							didntFind = true
							break
						end
					end
					local constTerms = table.filter(mul, function(x,k) 
						if type(k) ~= 'number' then return end
						return x:isa(Constant) 
					end)

					local thisConst = 1
					for _,const in ipairs(constTerms) do
						thisConst = thisConst * const.value
					end
					
					baseConst = baseConst + thisConst
				end
				if not didntFind then
					local terms = table{baseConst, baseTerms:unpack()}
					assert(#terms > 0)	-- at least baseConst should exist
					if #terms == 1 then
						terms = terms[1]
					else
						terms = mulOp(terms:unpack())
					end

					local expr
					if #nonMuls == 0 then
						expr = terms
					else
						expr = addOp(terms, nonMuls:unpack())
					end

					return prune:apply(expr)
				end
			end
		end
		--]]

		-- TODO shouldn't this be regardless of the outer addOp ?
		-- turn any a + (b * (c + d)) => a + (b * c) + (b * d)
		-- [[ if any two children are mulOps,
		--    and they have all children in common (with the exception of any constants)
		--  then combine them, and combine their constants
		-- x * c1 + x * c2 => x * (c1 + c2) (for c1,c2 constants)
		for i=1,#expr-1 do
			local xI = expr[i]
			local termsI
			if xI:isa(mulOp) then
				termsI = table(xI)
			else
				termsI = table{xI}
			end
			for j=i+1,#expr do
				local xJ = expr[j]
				local termsJ
				if xJ:isa(mulOp) then
					termsJ = table(xJ)
				else
					termsJ = table{xJ}
				end

				local fail
				
				local commonTerms = table()

				local constI
				for _,ch in ipairs(termsI) do
					if not termsJ:find(ch) then
						if ch:isa(Constant) then
							if not constI then
								constI = Constant(ch.value)
							else
								constI.value = constI.value * ch.value
							end
						else
							fail = true
							break
						end
					else
						commonTerms:insert(ch)
					end
				end
				if not constI then constI = Constant(1) end
				
				local constJ
				if not fail then
					for _,ch in ipairs(termsJ) do
						if not termsI:find(ch) then
							if ch:isa(Constant) then
								if not constJ then
									constJ = Constant(ch.value)
								else
									constJ.value = constJ.value * ch.value
								end
							else
								fail = true
								break
							end
						end
					end
				end
				if not constJ then constJ = Constant(1) end
				
				if not fail then
					table.remove(expr, j)
					if #commonTerms == 0 then
						expr[i] = Constant(constI.value + constJ.value)
					else
						expr[i] = mulOp(Constant(constI.value + constJ.value), table.unpack(commonTerms))
					end
					if #expr == 1 then expr = expr[1] end
					return prune:apply(expr)
				end
			end
		end
		--]]
		
		--[[ factor out divs ...
		local denom
		local denomIndex
		for i,x in ipairs(expr) do
			if not x:isa(divOp) then
				denom = nil
				break
			else
				if not denom then
					denom = x[2]
					denomIndex = i
				else
					if x[2] ~= denom then
						denom = nil
						break
					end
				end
			end
		end
		if denom then
			table.remove(expr, denomIndex)
			return prune:apply(expr / denom)
		end
		--]]
		-- [[ divs: c + a/b => (c * b + a) / b
		for i,x in ipairs(expr) do
			if x:isa(divOp) then
				assert(#x == 2)
				local a,b = table.unpack(x)
				table.remove(expr, i)
				if #expr == 1 then expr = expr[1] end
				local expr = (expr * b + a) / b
				return prune:apply(expr)
			end
		end
		--]]


		-- trigonometry identities

		-- cos(theta)^2 + sin(theta)^2 => 1
		-- TODO first get a working factor() function
		-- then replace all nodes of cos^2 + sin^2 with 1
		-- ... or of cos^2 with 1 - sin^2 and let the rest cancel out  (best to operate on one function rather than two)
		--  (that 2nd step possibly in a separate simplifyTrig() function of its own?)
		do
			local cos = require 'symmath.cos'
			local sin = require 'symmath.sin'
			local Function = require 'symmath.Function'
		
			local function checkAddOp(ch)
				local cosAngle, sinAngle
				local cosIndex, sinIndex
				for i,x in ipairs(ch) do
					
					if x:isa(powOp)
					and x[1]:isa(Function)
					and x[2] == Constant(2)
					then
						if x[1]:isa(cos) then
							if sinAngle then
								if sinAngle == x[1][1] then
									-- then remove sine and cosine and replace with a '1' and set modified
									table.remove(expr, i)	-- remove largest index first
									expr[sinIndex] = Constant(1)
									if #expr == 1 then expr = expr[1] end
									return expr
								end
							else
								cosIndex = i
								cosAngle = x[1][1]
							end
						elseif x[1]:isa(sin) then
							if cosAngle then
								if cosAngle == x[1][1] then
									table.remove(expr, i)
									expr[cosIndex] = Constant(1)
									if #expr == 1 then expr = expr[1] end
									return expr
								end
							else
								sinIndex = i
								sinAngle = x[1][1]
							end
						end
					end
				end
			end
		
			local cos = require 'symmath.cos'
			local sin = require 'symmath.sin'
			local Function = require 'symmath.Function'
			local map = require 'symmath.map'

			-- using factor outright causes simplification loops ...
			-- how about only using it if we find a cos or a sin in our tree?
			local foundTrig = false
			map(expr, function(node)
				if node:isa(cos) or node:isa(sin) then
					foundTrig = true
				end
			end)

			if foundTrig then
				local result = checkAddOp(expr)
				if result then
					return prune:apply(result) 
				end

				-- this is factoring ... and pruning ... 
				-- such that it is recursively calling this function for its simplification
				local f = require 'symmath.factor'(expr)
				if f then
					return f
				end
			end	

--[[
			if f:isa(mulOp) then	-- should always be a mulOp unless there was nothing to factor
				for _,ch in ipairs(f) do
					if ch:isa(addOp) then
						local result = checkAddOp(ch)
						if result then 
							return prune:apply(result) 
						end
					end
				end
			end
--]]
		end
	end,
	
	[subOp] = function(prune, expr)
		return prune:apply(expr[1] + (-expr[2]))
	end,
	
	[mulOp] = function(prune, expr)
		assert(#expr > 0)
		
		-- flatten multiplications
		for i=#expr,1,-1 do
			local ch = expr[i]
			if ch:isa(mulOp) then
				-- this looks like a job for splice ...
				table.remove(expr, i)
				for j=#ch,1,-1 do
					local chch = ch[j]
					table.insert(expr, i, chch)
				end
				return prune:apply(expr)
			end
		end
		
		-- move unary minuses up
		--[[ pruning unmOp immediately
		do
			local unmOpCount = 0
			for i=1,#expr do
				local ch = expr[i]
				if ch:isa(unmOp) then
					unmOpCount = unmOpCount + 1
					expr[i] = ch[1]
				end
			end
			if unmOpCount % 2 == 1 then
				return -prune:apply(expr)	-- move unm outside and simplify what's left
			elseif unmOpCount ~= 0 then
				return prune:apply(expr)	-- got an even number?  remove it and simplify this
			end
		end
		--]]

		-- push all Constants to the lhs, sum as we go
		local cval = 1
		for i=#expr,1,-1 do
			if expr[i]:isa(Constant) then
				cval = cval * table.remove(expr, i).value
			end
		end

		-- if it's all constants then return what we got
		if #expr == 0 then 
			return Constant(cval) 
		end
		
		if cval == 0 then 
			return Constant(0) 
		end
		
		if cval ~= 1 then
			table.insert(expr, 1, Constant(cval))
		else
			if #expr == 1 then 
				return prune:apply(expr[1]) 
			end
		end

		-- [[ and now for Matrix*Matrix multiplication ...
		for i=#expr,2,-1 do
			local rhs = expr[i]
			local lhs = expr[i-1]
		
			local result
			if lhs.pruneMul then
				result = lhs.pruneMul(lhs, rhs)
			elseif rhs.pruneMul then
				result = rhs.pruneMul(lhs, rhs)
			end
			if result then
				table.remove(expr, i)
				expr[i-1] = result
				if #expr == 1 then expr = expr[1] end
				return prune:apply(expr)
			end
		end
		--]]

		-- [[ a^m * a^n => a^(m + n)
		do
			local modified = false
			local i = 1
			while i <= #expr do
				local x = expr[i]
				local base
				local power
				if x:isa(powOp) then
					base = x[1]
					power = x[2]
				else
					base = x
					power = Constant(1)
				end
				
				if base then
					local j = i + 1
					while j <= #expr do
						local x2 = expr[j]
						local base2
						local power2
						if x2:isa(powOp) then
							base2 = x2[1]
							power2 = x2[2]
						else
							base2 = x2
							power2 = Constant(1)
						end
						if base2 == base then
							modified = true
							table.remove(expr, j)
							j = j - 1
							power = power + power2
						end
						j = j + 1
					end
					if modified then
						expr[i] = base ^ power
					end
				end
				i = i + 1
			end
			if modified then
				if #expr == 1 then expr = expr[1] end
				return prune:apply(expr)
			end
		end
		--]]
		
		-- [[ factor out denominators
		-- a * b * (c / d) => (a * b * c) / d
		--  generalization:
		-- a^m * b^n * (c/d)^p = (a^m * b^n * c^p) / d^p
		do
			local uniqueDenomIndexes = table()
			
			local denoms = table()
			local powers = table()
			local bases = table()
			
			for i=1,#expr do
				-- decompose expressions of the form 
				--  (base / denom) ^ power
				local base = expr[i]
				local power = Constant(1)
				local denom = Constant(1)

				if base:isa(powOp) then
					base, power = table.unpack(base)
				end
				if base:isa(divOp) then
					base, denom = table.unpack(base)
				end
				if denom ~= Constant(1) then
					uniqueDenomIndexes:insert(i)
				end

				denoms:insert(denom)
				powers:insert(power)
				bases:insert(base)
			end
			
			if #uniqueDenomIndexes > 0 then	
				
				local num
				if #bases == 1 then
					num = bases[1]
					if powers[1] ~= Constant(1) then
						num = num ^ powers[1]
					end
				else
					num = bases:map(function(base,i)
						if powers[i] == Constant(1) then
							return base
						else
							return base ^ powers[i]
						end
					end)
					assert(#num > 0)
					if #num == 1 then
						num = num[1]
					else
						num = mulOp(num:unpack())
					end
				end
				
				local denom
				if #uniqueDenomIndexes == 1 then
					local i = uniqueDenomIndexes[1]
					denom = denoms[i]
					if powers[i] ~= Constant(1) then
						denom = denom^powers[i]
					end
				elseif #denoms > 1 then
					denom = mulOp(table.unpack(uniqueDenomIndexes:map(function(i)
						if powers[i] == Constant(1) then
							return denoms[i]
						else
							return denoms[i]^powers[i]
						end
					end)))
				end
				
				local expr = num
				if denom ~= Constant(1) then
					expr = expr / denom
				end
				return prune:apply(expr)
			end
		end
		--]]
	end,
	
	[divOp] = function(prune, expr)
		local symmath = require 'symmath'	-- for debug flags ...
		
		-- matrix/scalar
		do
			local a, b = table.unpack(expr)
			local Array = require 'symmath.Array'
			if a:isa(Array)
			and not b:isa(Array)
			then
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
			if expr[1]:isa(Constant) and expr[2]:isa(Constant) then
				return Constant(expr[1].value / expr[2].value)
			end

			-- mul / Constant = 1/Constant * mul
			if expr[1]:isa(mulOp) and expr[2]:isa(Constant) then
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
		if expr[2]:isa(Constant)
		and expr[2].value < 0
		then
			return prune:apply(Constant(-1) * expr[1] / Constant(-expr[2].value))
		end
		
		-- 0 / x => 0
		if expr[1] == Constant(0) then
			if expr[1].value == 0 then
				return Constant(0)
			end
		end
		
		-- (a / b) / c => a / (b * c)
		if expr[1]:isa(divOp) then
			return prune:apply(expr[1][1] / (expr[1][2] * expr[2]))
		end
		
		-- a / (b / c) => (a * c) / b
		if expr[2]:isa(divOp) then
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
			if expr[1]:isa(mulOp) then
				nums = table(expr[1])
			else
				nums = table{expr[1]}
			end
			if expr[2]:isa(mulOp) then
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
					if x:isa(powOp) then
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
					if b:isa(Constant) 
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
		if expr[1]:isa(addOp) then
			return prune:apply(addOp(
				table.map(expr[1], function(x,k)
					if type(k) ~= 'number' then return end
					return x / expr[2]
				end):unpack()))
		end
		--]]

		--[[
		
		-- x / x^a => x^(1-a)
		if expr[2]:isa(powOp) and expr[1] == expr[2][1] then
			return prune:apply(expr[1] ^ (1 - expr[2][2]))
		end
		
		-- x^a / x => x^(a-1)
		if expr[1]:isa(powOp) and expr[1][1] == expr[2] then
			return prune:apply(expr[1][1] ^ (expr[1][2] - 1))
		end
		
		-- x^a / x^b => x^(a-b)
		if expr[1]:isa(powOp)
		and expr[2]:isa(powOp)
		and expr[1][1] == expr[2][1]
		then
			return prune:apply(expr[1][1] ^ (expr[1][2] - expr[2][2]))
		end
		--]]
	end,
	
	[powOp] = function(prune, expr)
		
		local symmath = require 'symmath'	-- for debug flags
		
		local function isInteger(x) return x == math.floor(x+.5) end
		local function isPositiveInteger(x) return isInteger(x) and x > 0 end

		if expr[1]:isa(Constant) and expr[2]:isa(Constant) then
			if symmath.simplifyConstantPowers
			-- TODO this replaces some cases below
			or isInteger(expr[1].value) and isPositiveInteger(expr[2].value)
			then
				return Constant(expr[1].value ^ expr[2].value)
			end
		end
	
		if expr[1]:isa(Constant) and isPositiveInteger(expr[1].value)
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
		and expr[2]:isa(Constant)
		and expr[2].value > 0
		then
			return Constant(0)
		end

		-- 1^a => 1
		if expr[1] == Constant(1) then return Constant(1) end
		
		-- (-1)^odd = -1, (-1)^even = 1
		if expr[1] == Constant(-1) and expr[2]:isa(Constant) then
			local powModTwo = expr[2].value % 2
			if powModTwo == 0 then return Constant(1) end
			if powModTwo == 1 then return Constant(-1) end
		end
		
		-- a^1 => a
		if expr[2] == Constant(1) then return prune:apply(expr[1]) end
		
		-- a^0 => 1
		if expr[2] == Constant(0) then return Constant(1) end
		
		-- (a ^ b) ^ c => a ^ (b * c)
		if expr[1]:isa(powOp) then
			return prune:apply(expr[1][1] ^ (expr[1][2] * expr[2]))
		end
		
		-- (a * b) ^ c => a^c * b^c
		if expr[1]:isa(mulOp) then
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
		if expr[2]:isa(Constant) and expr[2].value < 0 then
			return prune:apply(Constant(1)/(expr[1]^Constant(-expr[2].value)))
		end

		--[[ for simplification's sake ... (like -a => -1 * a)
		-- x^c => x*x*...*x (c times)
		if expr[2]:isa(Constant)
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

	[require 'symmath.sqrt'] = function(prune, expr)
		return prune:apply(expr[1]^divOp(1,2))
	end,
}

return Prune
