--[[
local prune = require 'symmath.prune'
x = prune(x)

traverses x, child first, maps the nodes if they appear in the lookup table

the table can be expanded by adding an entry prune.lookupTable[class] to perform the necessary transformation
--]]

local tableCommutativeEqual = require 'symmath.tableCommutativeEqual'

local prune = {}

prune.lookupTable = {
	
	[require 'symmath.Derivative'] = function(prune, self)
		local Constant = require 'symmath.Constant'
		local Derivative = require 'symmath.Derivative'
		local simplify = require 'symmath.simplify'

		if self.xs[1]:isa(Constant) then
			return Constant(0)
		end

		if self.xs[1]:isa(Derivative) then
			return simplify(Derivative(self.xs[1].xs[1], unpack(
				table.append({unpack(self.xs, 2)}, {unpack(self.xs[1].xs, 2)})
			)))
		end
	
		-- might need to be pruned again, might not ...
		return self:distribute()
	end,
	
	[require 'symmath.unmOp'] = function(prune, self)
		local Constant = require 'symmath.Constant'
		return prune(Constant(-1) * self.xs[1])
	end,
	
	[require 'symmath.addOp'] = function(prune, self)
		local Constant = require 'symmath.Constant'
		local addOp = require 'symmath.addOp'
		local mulOp = require 'symmath.mulOp'
		
		assert(#self.xs > 0)
		
		if #self.xs == 1 then return self.xs[1] end

		-- flatten additions
		for i=#self.xs,1,-1 do
			local ch = self.xs[i]
			if ch:isa(addOp) then
				-- this looks like a job for splice ...
				self.xs:remove(i)
				for j=#ch.xs,1,-1 do
					local chch = assert(ch.xs[j])
					self.xs:insert(i, chch)
				end
			end
		end
		
		-- push all Constants to the lhs, sum as we go
		local cval = 0
		for i=#self.xs,1,-1 do
			if self.xs[i]:isa(Constant) then
				cval = cval + self.xs:remove(i).value
			end
		end
		
		-- if it's all constants then return what we got
		if #self.xs == 0 then return Constant(cval) end
		
		-- re-insert if we have a Constant
		if cval ~= 0 then
			self.xs:insert(1, Constant(cval))
		else
			-- if cval is zero and we're not re-inserting a constant
			-- then see if we have only one term ...
			if #self.xs == 1 then return prune(self.xs[1]) end
		end
		
		-- [[ x * c1 + x * c2 => x * (c1 + c2) ... for constants
		local muls = self.xs:filter(function(x) return x:isa(mulOp) end)
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
				return prune(mulOp(baseConst, unpack(baseTerms)))
			end
		end
		--]]
		
		-- turn any a + (b * (c + d)) => a + (b * c) + (b * d)
		
		-- [[ if any two children are mulOps,
		--    and they have all children in common (with the exception of any constants)
		--  then combine them, and combine their constants
		-- x * c1 + x * c2 => x * (c1 + c2) (for c1,c2 constants)
		for i=1,#self.xs-1 do
			local xI = self.xs[i]
			local termsI
			if xI:isa(mulOp) then
				termsI = table(xI.xs)
			else
				termsI = table{xI}
			end
			for j=i+1,#self.xs do
				local xJ = self.xs[j]
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
					--print('optimizing from '..tostring(self))
					self.xs:remove(j)
					self.xs[i] = mulOp(Constant(constI.value + constJ.value), unpack(commonTerms))
					--print('optimizing to '..tostring(prune(self)))
					return prune(self)
				end
			end
		end
		--]]
		
		--[[ factor out divs ...
		local denom
		local denomIndex
		for i,x in ipairs(self.xs) do
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
			self.xs:remove(denomIndex)
			return prune(self / denom)
		end
		--]]
		
		-- trig identities

		-- cos(theta)^2 + sin(theta)^2 => 1
		-- TODO first get a working factor() function
		-- then replace all nodes of cos^2 + sin^2 with 1
		-- ... or of cos^2 with 1 - sin^2 and let the rest cancel out  (best to operate on one function rather than two)
		--  (that 2nd step possibly in a separate simplifyTrig() function of its own?)
		do
			local powOp = require 'symmath.powOp'
			local cos = require 'symmath.cos'
			local sin = require 'symmath.sin'
			local cosAngle, sinAngle
			local cosIndex, sinIndex
			for i=1,#self.xs do
				local x = self.xs[i]
				
				if x:isa(powOp)
				and x.xs[1]:isa(Function)
				and x.xs[2] == Constant(2)
				then
					if x.xs[1]:isa(cos) then
						if sinAngle then
							if sinAngle == x.xs[1].xs[1] then
								-- then remove sine and cosine and replace with a '1' and set modified
								self.xs:remove(i)	-- remove largest index first
								self.xs[sinIndex] = Constant(1)
								return prune(self)
							end
						else
							cosIndex = i
							cosAngle = x.xs[1].xs[1]
						end
					elseif x.xs[1]:isa(sin) then
						if cosAngle then
							if cosAngle == x.xs[1].xs[1] then
								self.xs:remove(i)
								self.xs[cosIndex] = Constant(1)
								return prune(self)
							end
						else
							sinIndex = i
							sinAngle = x.xs[1].xs[1]
						end
					end
				end
			end
		end
		
		return self

	end,
	
	[require 'symmath.subOp'] = function(prune, self)
		return prune(self.xs[1] + (-self.xs[2]))
	end,
	
	[require 'symmath.mulOp'] = function(prune, self)
		local Constant = require 'symmath.Constant'
		local unmOp = require 'symmath.unmOp'
		local powOp = require 'symmath.powOp'
		local divOp = require 'symmath.divOp'
		
		assert(#self.xs > 0)
		
		-- flatten multiplications
		for i=#self.xs,1,-1 do
			local ch = self.xs[i]
			if ch:isa(mulOp) then
				-- this looks like a job for splice ...
				self.xs:remove(i)
				for j=#ch.xs,1,-1 do
					local chch = ch.xs[j]
					self.xs:insert(i, chch)
				end
			end
		end
		
		-- move unary minuses up
		do
			local unmOpCount = 0
			for i=1,#self.xs do
				local ch = self.xs[i]
				if ch:isa(unmOp) then
					unmOpCount = unmOpCount + 1
					self.xs[i] = ch.xs[1]
				end
			end
			if unmOpCount % 2 == 1 then
				return prune(-self)
			elseif unmOpCount ~= 0 then
				return prune(self)
			end
		end

		-- push all Constants to the lhs, sum as we go
		local cval = 1
		for i=#self.xs,1,-1 do
			if self.xs[i]:isa(Constant) then
				cval = cval * self.xs:remove(i).value
			end
		end

		-- if it's all constants then return what we got
		if #self.xs == 0 then return Constant(cval) end
		
		if cval == 0 then return Constant(0) end
		
		if cval ~= 1 then
			self.xs:insert(1, Constant(cval))
		else
			if #self.xs == 1 then return prune(self.xs[1]) end
		end
		
		-- one node left?  use it itself
		if #self.xs == 1 then return self.xs[1] end
		
		-- [[ a^m * a^n => a^(m + n)
		do
			local modified = false
			local i = 1
			while i <= #self.xs do
				local x = self.xs[i]
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
					while j <= #self.xs do
						local x2 = self.xs[j]
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
							self.xs:remove(j)
							j = j - 1
							power = power + power2
						end
						j = j + 1
					end
					if modified then
						self.xs[i] = base ^ power
					end
				end
				i = i + 1
			end
			if modified then
				return prune(self)
			end
		end
		--]]
		
		-- [[ factor out denominators: a * b * (c / d) => (a * b * c) / d
		local denoms = table()
		for i=#self.xs,1,-1 do
			local x = self.xs[i]
			if x:isa(divOp) then
				self.xs[i] = x.xs[1]
				denoms:insert(x.xs[2])
			end
		end
		if #denoms > 0 then
			return prune(self / mulOp(unpack(denoms)))
		end
		--]]
		
		--[[ moved to expand()
		do
			local res = self:applyDistribute()
			if res then return res end
		end
		--]]
			
		return self
	end,
	
	[require 'symmath.divOp'] = function(prune, self)
		local symmath = require 'symmath'	-- for debug flags ...
		local Constant = require 'symmath.Constant'
		local unmOp = require 'symmath.unmOp'
		local divOp = require 'symmath.divOp'
		
		if symmath.simplifyDivisionByPower then
			return simplify(mulOp(self.xs[1], powOp(self.xs[2], Constant(-1))))
		end

		-- move unary minuses up
		do
			local unmOpCount = 0
			for i=1,#self.xs do
				local ch = self.xs[i]
				if ch:isa(unmOp) then
					unmOpCount = unmOpCount + 1
					self.xs[i] = ch.xs[1]
				end
			end
			if unmOpCount % 2 == 1 then
				return prune(-self)
			elseif unmOpCount ~= 0 then
				return prune(self)
			end
		end
		
		-- x / 0 => Invalid
		if self.xs[2] == Constant(0) then
			return Invalid()
		end
		
		-- Constant / Constant => Constant
		if symmath.simplifyConstantPowers  then
			if self.xs[1]:isa(Constant) and self.xs[2]:isa(Constant) then
				return Constant(self.xs[1].value / self.xs[2].value)
			end
		end
		
		-- 0 / x => 0
		if self.xs[1]:isa(Constant) then
			if self.xs[1].value == 0 then
				return Constant(0)
			end
		end
		
		-- (a / b) / c => a / (b * c)
		if self.xs[1]:isa(divOp) then
			return prune(self.xs[1].xs[1] / (self.xs[1].xs[2] * self.xs[2]))
		end
		
		-- a / (b / c) => (a * c) / b
		if self.xs[2]:isa(divOp) then
			return prune((self.xs[1] * self.xs[2].xs[1]) / self.xs[2].xs[2])
		end

		if self.xs[1] == self.xs[2] then
			return Constant(1)		-- ... for self.xs[1] != 0
		end

	--[[
		-- (r^m * a * b * ...) / (r^n * x * y * ...) => (r^(m-n) * a * b * ...) / (x * y * ...)
		do
			local modified
			local nums, denoms
			if self.xs[1]:isa(mulOp) then
				nums = table(self.xs[1].xs)
			else
				nums = table{self.xs[1]}
			end
			if self.xs[2]:isa(mulOp) then
				denoms = table(self.xs[2].xs)
			else
				denoms = table{self.xs[2]}
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
		-- x / x => 1
		if self.xs[1] == self.xs[2] then
			if self.xs[1] == Constant(0) then
				-- undefined...
			else
				return Constant(1)
			end
		end
		
		-- x / x^a => x^(1-a)
		if self.xs[2]:isa(powOp) and self.xs[1] == self.xs[2].xs[1] then
			return prune(self.xs[1] ^ (1 - self.xs[2].xs[2]))
		end
		
		-- x^a / x => x^(a-1)
		if self.xs[1]:isa(powOp) and self.xs[1].xs[1] == self.xs[2] then
			return prune(self.xs[1].xs[1] ^ (self.xs[1].xs[2] - 1))
		end
		
		-- x^a / x^b => x^(a-b)
		if self.xs[1]:isa(powOp)
		and self.xs[2]:isa(powOp)
		and self.xs[1].xs[1] == self.xs[2].xs[1]
		then
			return prune(self.xs[1].xs[1] ^ (self.xs[1].xs[2] - self.xs[2].xs[2]))
		end
	--]]

		return self
	end,
	
	[require 'symmath.powOp'] = function(prune, self)
		local Constant = require 'symmath.Constant'
		local mulOp = require 'symmath.mulOp'
		local powOp = require 'symmath.powOp'
		local symmath = require 'symmath'	-- for debug flags
		
		if symmath.simplifyConstantPowers then
			if self.xs[1]:isa(Constant) and self.xs[2]:isa(Constant) then
				return Constant(self.xs[1].value ^ self.xs[2].value)
			end
		end
		
		-- 1^a => 1
		if self.xs[1] == Constant(1) then return Constant(1) end
		
		-- (-1)^odd = -1, (-1)^even = 1
		if self.xs[1] == Constant(-1) and self.xs[2]:isa(Constant) then
			local powModTwo = self.xs[2].value % 2
			if powModTwo == 0 then return Constant(1) end
			if powModTwo == 1 then return Constant(-1) end
		end
		
		-- a^1 => a
		if self.xs[2] == Constant(1) then return prune(self.xs[1]) end
		
		-- a^0 => 1
		if self.xs[2] == Constant(0) then return Constant(1) end
		
		-- (a ^ b) ^ c => a ^ (b * c)
		if self.xs[1]:isa(powOp) then
			return prune(self.xs[1].xs[1] ^ (self.xs[1].xs[2] * self.xs[2]))
		end
		
		-- (a * b) ^ c => a^c * b^c
		if self.xs[1]:isa(mulOp) then
			return prune(mulOp(unpack(self.xs[1].xs:map(function(v) return v ^ self.xs[2] end))))
		end
		
		--[[ for simplification's sake ... (like -a => -1 * a)
		-- x^c => x*x*...*x (c times)
		if self.xs[2]:isa(Constant)
		and self.xs[2].value > 0 
		and self.xs[2].value == math.floor(self.xs[2].value)
		then
			local m = mulOp()
			for i=1,self.xs[2].value do
				m.xs:insert( self.xs[1]:clone())
			end
			
			return prune(m)
		end
		--]]

		return self

	end,
}

--[[
transform expr by whatever rules are provided in lookupTable
--]]
function prune:apply(expr, ...)
	local Expression = require 'symmath.Expression'
	local t = type(expr)
	if t == 'table' then
		local m = getmetatable(expr)
		-- if it's an expression then apply to all children first
		if m:isa(Expression) then
			-- I could use symmath.map to do this, but then I'd have to cache ... in a table (and nils might cause me to miss objects unless I called table.maxn ... )
			if expr.xs then
				for i=1,#expr.xs do
					expr.xs[i] = self:apply(expr.xs[i], ...)
				end
			end
		end
		-- traverse class parentwise til a key in the lookup table is found
		-- stop at null
		while m and not self.lookupTable[m] do
			m = m.super
		end
		-- if we found an entry then apply it
		if self.lookupTable[m] then
			return self.lookupTable[m](self, expr, ...) or expr
		end
	end
	return expr
end

setmetatable(prune, {
	__call = function(self, ...)
		return self:apply(...)
	end
})

return prune

