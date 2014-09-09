require 'ext'
local Constant = require 'symmath.Constant'
local BinaryOp = require 'symmath.BinaryOp'
local diff = require 'symmath.diff'
local prune = require 'symmath.prune'

local divOp = class(BinaryOp)
divOp.precedence = 3
divOp.name = '/'

function divOp:diff(...)
	local a, b = unpack(self.xs)
	local x = (diff(a, ...) * b - a * diff(b, ...)) / (b * b)
--	x = prune(x)
	return x
end

function divOp:eval()
	local a, b = unpack(self.xs)
	return a:eval() / b:eval()
end

-- [==[
function divOp:prune()
	local unmOp = require 'symmath.unmOp'
	local symmath = require 'symmath'	-- for debug flags ...
	
	if symmath.simplifyDivisionByPower then
		return simplify(mulOp(self.xs[1], powOp(self.xs[2], Constant(-1))))
	end

	-- prune children
	for i=1,#self.xs do
		self.xs[i] = prune(self.xs[i])
	end

	-- move unary minuses up
	do
		local unmOpCount = 0
		for i=1,#self.xs do
			local ch = self.xs[i]
			if ch:isa(unmOp) then
				unmOpCount = unmOpCount + 1
				self:setChild(i, ch.xs[1])
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
--]=]
end

return divOp

