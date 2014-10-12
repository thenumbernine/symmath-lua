--[[
local prune = require 'symmath.prune'
x = prune(x)

traverses x, child first, maps the nodes if they appear in the lookup table

the table can be expanded by adding an entry prune.lookupTable[class] to perform the necessary transformation
--]]

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
local Visitor = require 'symmath.Visitor'
local Prune = class(Visitor)

Prune.lookupTable = {

	[Derivative] = function(prune, expr)

		-- d/dx c = 0
		if expr.xs[1]:isa(Constant) then
			return Constant(0)
		end

		-- d/dx d/dy = d/dxy
		if expr.xs[1]:isa(Derivative) then
			return prune(Derivative(expr.xs[1].xs[1], unpack(
				table.append({unpack(expr.xs, 2)}, {unpack(expr.xs[1].xs, 2)})
			)))
		end

		-- apply differentiation
		-- don't do so if it's a diff of a variable that requests not to
		if not (expr.xs[1]:isa(Variable) 
		and expr.xs[1].deferDiff) 
		then
			-- ... and if we're not lazy-evaluating the derivative of this with respect to other variables ...
			if not expr.xs[1].diff then
				error("failed to differentiate "..tostring(expr.xs[1]).." with type "..type(expr.xs[1]))
			end
			return prune(expr.xs[1]:diff(unpack(expr.xs, 2)))
		end
	
		-- dx/dx = 1
		if expr.xs[1]:isa(Variable) then
			if #expr.xs == 2 
			and expr.xs[1] == expr.xs[2]
			then
				return Constant(1)
			end
		end
	end,
	
	[unmOp] = function(prune, expr)
		if expr.xs[1]:isa(unmOp) then
			return prune(expr.xs[1].xs[1]:clone())
		end
		return prune(Constant(-1) * expr.xs[1])
	end,
	
	[addOp] = function(prune, expr)
		assert(#expr.xs > 0)
		
		expr = expr:clone()
local symmath = require 'symmath'
local original = expr:clone()

		if #expr.xs == 1 then return expr.xs[1] end

		-- flatten additions
		-- (x + y) + z => x + y + z
		for i=#expr.xs,1,-1 do
			local ch = expr.xs[i]
			if ch:isa(addOp) then
				expr = expr:clone()
				-- this looks like a job for splice ...
				expr.xs:remove(i)
				for j=#ch.xs,1,-1 do
					local chch = assert(ch.xs[j])
					expr.xs:insert(i, chch)
				end
--print('addOp flatten')
				return prune(expr)
			end
		end
		
		-- push all Constants to the lhs, sum as we go
		local cval = 0
		for i=#expr.xs,1,-1 do
			if expr.xs[i]:isa(Constant) then
				cval = cval + expr.xs:remove(i).value
			end
		end
		
		-- if it's all constants then return what we got
		if #expr.xs == 0 then 
--print('addOp const1 + const2 => const', symmath.Verbose(original), '=>', symmath.Verbose(cval))
			return Constant(cval) 
		end
		
		-- re-insert if we have a Constant
		if cval ~= 0 then
			expr.xs:insert(1, Constant(cval))
		else
			-- if cval is zero and we're not re-inserting a constant
			-- then see if we have only one term ...
			if #expr.xs == 1 then 
--print('addOp returning zero')
				return prune(expr.xs[1]) 
			end
		end
		
		-- [[ x * c1 + x * c2 => x * (c1 + c2) ... for constants
		local muls = expr.xs:filter(function(x) return x:isa(mulOp) end)
		if #muls > 1 then	-- we have more than one multiplication going on ... see if we can combine them
			local baseConst = 0
			local baseTerms
			local didntFind
			for _,mul in ipairs(muls) do
				local nonConstTerms = mul.xs:filter(function(x) return not x:isa(Constant) end)
				if not baseTerms then
					baseTerms = nonConstTerms
				else
					if not tableCommutativeEqual(baseTerms, nonConstTerms) then
						didntFind = true
						break
					end
				end
				local constTerms = mul.xs:filter(function(x) return x:isa(Constant) end)

				local thisConst = 1
				for _,const in ipairs(constTerms) do
					thisConst = thisConst * const.value
				end
				
				baseConst = baseConst + thisConst
			end
			if not didntFind then
--print('addOp c1*x + c2*x = (c1+c2)*x')
				return prune(mulOp(baseConst, unpack(baseTerms)))
			end
		end
		--]]
		
		-- turn any a + (b * (c + d)) => a + (b * c) + (b * d)
		
		-- [[ if any two children are mulOps,
		--    and they have all children in common (with the exception of any constants)
		--  then combine them, and combine their constants
		-- x * c1 + x * c2 => x * (c1 + c2) (for c1,c2 constants)
		for i=1,#expr.xs-1 do
			local xI = expr.xs[i]
			local termsI
			if xI:isa(mulOp) then
				termsI = table(xI.xs)
			else
				termsI = table{xI}
			end
			for j=i+1,#expr.xs do
				local xJ = expr.xs[j]
				local termsJ
				if xJ:isa(mulOp) then
					termsJ = table(xJ.xs)
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
								constI.value = constI.value + ch.value
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
									constJ.value = constJ.value + ch.value
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
					--print('optimizing from '..tostring(expr))
					expr.xs:remove(j)
					expr.xs[i] = mulOp(Constant(constI.value + constJ.value), unpack(commonTerms))
					--print('optimizing to '..tostring(prune(expr)))
--print('flattening muls in add')
					return prune(expr)
				end
			end
		end
		--]]
		
		--[[ factor out divs ...
		local denom
		local denomIndex
		for i,x in ipairs(expr.xs) do
			if not x:isa(divOp) then
				denom = nil
				break
			else
				if not denom then
					denom = x.xs[2]
					denomIndex = i
				else
					if x.xs[2] ~= denom then
						denom = nil
						break
					end
				end
			end
		end
		if denom then
			expr.xs:remove(denomIndex)
			return prune(expr / denom)
		end
		--]]
		-- [[ divs: c + a/b => (c * b + a) / b
		for i,x in ipairs(expr.xs) do
			if x:isa(divOp) then
				assert(#x.xs == 2)
				local a,b = unpack(x.xs)
				expr.xs:remove(i)
--print('c+a/b => (c*b+a)/b')
				return prune((expr * b + a) / b)
			end
		end
		--]]
		
		-- trig identities

		-- cos(theta)^2 + sin(theta)^2 => 1
		-- TODO first get a working factor() function
		-- then replace all nodes of cos^2 + sin^2 with 1
		-- ... or of cos^2 with 1 - sin^2 and let the rest cancel out  (best to operate on one function rather than two)
		--  (that 2nd step possibly in a separate simplifyTrig() function of its own?)
		do
			local cos = require 'symmath.cos'
			local sin = require 'symmath.sin'
			local Function = require 'symmath.Function'
			local cosAngle, sinAngle
			local cosIndex, sinIndex
			for i=1,#expr.xs do
				local x = expr.xs[i]
				
				if x:isa(powOp)
				and x.xs[1]:isa(Function)
				and x.xs[2] == Constant(2)
				then
					if x.xs[1]:isa(cos) then
						if sinAngle then
							if sinAngle == x.xs[1].xs[1] then
								-- then remove sine and cosine and replace with a '1' and set modified
								expr.xs:remove(i)	-- remove largest index first
								expr.xs[sinIndex] = Constant(1)
--print('cos^2+sin^2=1')
								return prune(expr)
							end
						else
							cosIndex = i
							cosAngle = x.xs[1].xs[1]
						end
					elseif x.xs[1]:isa(sin) then
						if cosAngle then
							if cosAngle == x.xs[1].xs[1] then
								expr.xs:remove(i)
								expr.xs[cosIndex] = Constant(1)
--print('cos^2+sin^2=1')
								return prune(expr)
							end
						else
							sinIndex = i
							sinAngle = x.xs[1].xs[1]
						end
					end
				end
			end
		end
		
		return expr
	end,
	
	[subOp] = function(prune, expr)
		return prune(expr.xs[1] + (-expr.xs[2]))
	end,
	
	[mulOp] = function(prune, expr)

		assert(#expr.xs > 0)
		
		expr = expr:clone()
local symmath = require 'symmath'
local original = expr:clone()	
		
		-- flatten multiplications
		for i=#expr.xs,1,-1 do
			local ch = expr.xs[i]
			if ch:isa(mulOp) then
				-- this looks like a job for splice ...
				expr.xs:remove(i)
				for j=#ch.xs,1,-1 do
					local chch = ch.xs[j]
					expr.xs:insert(i, chch)
				end
--print('mulOp (a*b)*c => a*b*c', symmath.Verbose(original), '=>', symmath.Verbose(expr))
				return prune(expr)
			end
		end
		
		-- move unary minuses up
		--[[ pruning unmOp immediately
		do
			local unmOpCount = 0
			for i=1,#expr.xs do
				local ch = expr.xs[i]
				if ch:isa(unmOp) then
					unmOpCount = unmOpCount + 1
					expr.xs[i] = ch.xs[1]
				end
			end
			if unmOpCount % 2 == 1 then
				return -prune(expr)	-- move unm outside and simplify what's left
			elseif unmOpCount ~= 0 then
				return prune(expr)	-- got an even number?  remove it and simplify this
			end
		end
		--]]

		-- push all Constants to the lhs, sum as we go
		local cval = 1
		for i=#expr.xs,1,-1 do
			if expr.xs[i]:isa(Constant) then
				cval = cval * expr.xs:remove(i).value
			end
		end

		-- if it's all constants then return what we got
		if #expr.xs == 0 then 
--print('mulOp returning constant', symmath.Verbose(original), '=>', symmath.Verbose(Constant(cval)))
			return Constant(cval) 
		end
		
		if cval == 0 then 
--print('mulOp returning zero')
			return Constant(0) 
		end
		
		if cval ~= 1 then
			expr.xs:insert(1, Constant(cval))
		else
			if #expr.xs == 1 then 
--print('mulOp 1*a => a', symmath.Verbose(original), '=>', symmath.Verbose(expr.xs[1]))
				return prune(expr.xs[1]) 
			end
		end

		-- [[ a^m * a^n => a^(m + n)
		do
			local modified = false
			local i = 1
			while i <= #expr.xs do
				local x = expr.xs[i]
				local base
				local power
				if x:isa(powOp) then
					base = x.xs[1]
					power = x.xs[2]
				else
					base = x
					power = Constant(1)
				end
				
				if base then
					local j = i + 1
					while j <= #expr.xs do
						local x2 = expr.xs[j]
						local base2
						local power2
						if x2:isa(powOp) then
							base2 = x2.xs[1]
							power2 = x2.xs[2]
						else
							base2 = x2
							power2 = Constant(1)
						end
						if base2 == base then
							modified = true
							expr.xs:remove(j)
							j = j - 1
							power = power + power2
						end
						j = j + 1
					end
					if modified then
						expr.xs[i] = base ^ power
					end
				end
				i = i + 1
			end
			if modified then
--print('mulOp a^m * a^n => a^(m+n)', symmath.Verbose(original), '=>', symmath.Verbose(expr))
				return prune(expr)
			end
		end
		--]]
		
		-- [[ factor out denominators: a * b * (c / d) => (a * b * c) / d
		local denoms = table()
		for i=#expr.xs,1,-1 do
			local x = expr.xs[i]
			if x:isa(divOp) then
				expr.xs[i] = x.xs[1]
				denoms:insert(x.xs[2])
			end
		end
		if #denoms == 1 then
--print('mulOp a*(b/c) => (a*b)/c')
			return prune(expr / denoms[1])
		elseif #denoms > 1 then
--print('mulOp (a/b)*(c/d) => (a*c)/(b*d)')
			return prune(expr / mulOp(unpack(denoms)))
		end
		--]]
		
		return expr
	end,
	
	[divOp] = function(prune, expr)
		local symmath = require 'symmath'	-- for debug flags ...

		if symmath.simplifyDivisionByPower then
			return prune(mulOp(expr.xs[1], powOp(expr.xs[2], Constant(-1))))
		end
		
		-- x / 0 => Invalid
		if expr.xs[2] == Constant(0) then
			return Invalid()
		end
		
		if symmath.simplifyConstantPowers  then
			-- Constant / Constant => Constant
			if expr.xs[1]:isa(Constant) and expr.xs[2]:isa(Constant) then
				return Constant(expr.xs[1].value / expr.xs[2].value)
			end

			-- mul / Constant = 1/Constant * mul
			if expr.xs[1]:isa(mulOp) and expr.xs[2]:isa(Constant) then
				local m = expr.xs[1]:clone()
				return prune(mulOp(Constant(1/expr.xs[2].value), unpack(m.xs)))
			end
		end

		-- x / 1 => x
		if expr.xs[2] == Constant(1) then
			return expr.xs[1]
		end

		-- x / -1 => -1 * x
		if expr.xs[2] == Constant(-1) then
			return Constant(-1) * expr.xs[1]
		end
		
		-- 0 / x => 0
		if expr.xs[1] == Constant(0) then
			if expr.xs[1].value == 0 then
				return Constant(0)
			end
		end
		
		-- (a / b) / c => a / (b * c)
		if expr.xs[1]:isa(divOp) then
			return prune(expr.xs[1].xs[1] / (expr.xs[1].xs[2] * expr.xs[2]))
		end
		
		-- a / (b / c) => (a * c) / b
		if expr.xs[2]:isa(divOp) then
			local a, b = unpack(expr.xs)
			local b, c = unpack(b.xs)
			return prune((a * c) / b)
		end

		if expr.xs[1] == expr.xs[2] then
			return Constant(1)		-- ... for expr.xs[1] != 0
		end

	-- [[
		-- (r^m * a * b * ...) / (r^n * x * y * ...) => (r^(m-n) * a * b * ...) / (x * y * ...)
		do
			local modified
			local nums, denoms
			if expr.xs[1]:isa(mulOp) then
				nums = table(expr.xs[1].xs)
			else
				nums = table{expr.xs[1]}
			end
			if expr.xs[2]:isa(mulOp) then
				denoms = table(expr.xs[2].xs)
			else
				denoms = table{expr.xs[2]}
			end
			local function listToBasesAndPowers(list)
				local bases = table()
				local powers = table()
				for i=1,#list do
					local x = list[i]
					local base, power
					if x:isa(powOp) then
						base, power = unpack(x.xs)
					else
						base, power = x, Constant(1)
					end
					bases[i] = base
					powers[i] = power
				end
				return bases, powers
			end
			local numBases, numPowers = listToBasesAndPowers(nums)
			local denomBases, denomPowers = listToBasesAndPowers(denoms)
			for i=1,#nums do
				local j = 1
				while j <= #denoms do
					if numBases[i] == denomBases[j] then
						modified = true
						local resultPower = numPowers[i] - denomPowers[j]
						numPowers[i] = resultPower
						denoms:remove(j)
						denomBases:remove(j)
						denomPowers:remove(j)
						j=j-1
					end
					j=j+1
				end
			end
			if modified then
				if #numBases == 0 and #denomBases == 0 then return Constant(1) end

				-- can I construct these even if they have no terms?
				local num
				if #numBases > 0 then
					num = mulOp(unpack(numBases:map(function(v,i) return v ^ numPowers[i] end)))
				end
				local denom
				if #denomBases > 0 then
					denom = mulOp(unpack(denomBases:map(function(v,i) return v ^ numPowers[i] end)))
				end
				
				local result
				if #numBases == 0 then
					result = Constant(1) / denom
				elseif #denomBases == 0 then
					result = num
				else
					result = num / denom
				end
				
				return prune(result)
			end
		end
	--]]

	--[[
	
		-- x / x^a => x^(1-a)
		if expr.xs[2]:isa(powOp) and expr.xs[1] == expr.xs[2].xs[1] then
			return prune(expr.xs[1] ^ (1 - expr.xs[2].xs[2]))
		end
		
		-- x^a / x => x^(a-1)
		if expr.xs[1]:isa(powOp) and expr.xs[1].xs[1] == expr.xs[2] then
			return prune(expr.xs[1].xs[1] ^ (expr.xs[1].xs[2] - 1))
		end
		
		-- x^a / x^b => x^(a-b)
		if expr.xs[1]:isa(powOp)
		and expr.xs[2]:isa(powOp)
		and expr.xs[1].xs[1] == expr.xs[2].xs[1]
		then
			return prune(expr.xs[1].xs[1] ^ (expr.xs[1].xs[2] - expr.xs[2].xs[2]))
		end
	--]]

		return expr
	end,
	
	[powOp] = function(prune, expr)
		
		local symmath = require 'symmath'	-- for debug flags

		if symmath.simplifyConstantPowers then
			if expr.xs[1]:isa(Constant) and expr.xs[2]:isa(Constant) then
				return Constant(expr.xs[1].value ^ expr.xs[2].value)
			end
		end
		
		-- 1^a => 1
		if expr.xs[1] == Constant(1) then return Constant(1) end
		
		-- (-1)^odd = -1, (-1)^even = 1
		if expr.xs[1] == Constant(-1) and expr.xs[2]:isa(Constant) then
			local powModTwo = expr.xs[2].value % 2
			if powModTwo == 0 then return Constant(1) end
			if powModTwo == 1 then return Constant(-1) end
		end
		
		-- a^1 => a
		if expr.xs[2] == Constant(1) then return prune(expr.xs[1]) end
		
		-- a^0 => 1
		if expr.xs[2] == Constant(0) then return Constant(1) end
		
		-- (a ^ b) ^ c => a ^ (b * c)
		if expr.xs[1]:isa(powOp) then
			return prune(expr.xs[1].xs[1] ^ (expr.xs[1].xs[2] * expr.xs[2]))
		end
		
		-- (a * b) ^ c => a^c * b^c
		if expr.xs[1]:isa(mulOp) then
			return prune(mulOp(unpack(expr.xs[1].xs:map(function(v) return v ^ expr.xs[2] end))))
		end
		
		--[[ for simplification's sake ... (like -a => -1 * a)
		-- x^c => x*x*...*x (c times)
		if expr.xs[2]:isa(Constant)
		and expr.xs[2].value > 0 
		and expr.xs[2].value == math.floor(expr.xs[2].value)
		then
			local m = mulOp()
			for i=1,expr.xs[2].value do
				m.xs:insert( expr.xs[1]:clone())
			end
			
			return prune(m)
		end
		--]]

		return expr

	end,
}

-- return instanciated singletons of Visitor class children
return Prune()

