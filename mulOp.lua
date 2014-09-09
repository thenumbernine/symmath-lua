require 'ext'
local Constant = require 'symmath.Constant'
local BinaryOp = require 'symmath.BinaryOp'
local diff = require 'symmath.diff'
local prune = require 'symmath.prune'
local nodeCommutativeEqual = require 'symmath.nodeCommutativeEqual'

mulOp = class(BinaryOp)
mulOp.implicitName = true
mulOp.precedence = 3
mulOp.name = '*'

function mulOp:diff(...)
	local addOp = require 'symmath.addOp'
	local sumRes = addOp()
	for i=1,#self.xs do
		local termRes = mulOp()
		for j=1,#self.xs do
			if i == j then
				termRes:insertChild(diff(self.xs[j], ...))
			else
				termRes:insertChild(self.xs[j])
			end
		end
		sumRes:insertChild(termRes)
	end
--	sumRes = prune(sumRes)
	return sumRes
end

function mulOp:eval()
	local result = 1
	for _,x in ipairs(self.xs) do
		result = result * x:eval()
	end
	return result
end

function mulOp:expand()
	local res = self:applyDistribute()
	if res then return res end
	return self
end

function mulOp:prune()
	local unmOp = require 'symmath.unmOp'
	local powOp = require 'symmath.powOp'
	local divOp = require 'symmath.divOp'
	
	assert(#self.xs > 0)
	if #self.xs == 1 then return prune(self.xs[1]) end

	-- prune children
	for i=1,#self.xs do
		self.xs[i] = prune(self.xs[i])
	end
	
	-- flatten multiplications
	for i=#self.xs,1,-1 do
		local ch = self.xs[i]
		if ch:isa(mulOp) then
			-- this looks like a job for splice ...
			self:removeChild(i)
			for _,chch in ipairs(ch.xs) do
				self:insertChild(i, chch)
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
			cval = cval * self:removeChild(i).value
		end
	end

	-- if it's all constants then return what we got
	if #self.xs == 0 then return Constant(cval) end
	
	if cval == 0 then return Constant(0) end
	
	if cval ~= 1 then
		self:insertChild(1, Constant(cval))
	else
		if #self.xs == 1 then return prune(self.xs[1]) end
	end
	
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
						self:removeChild(j)
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
end

function mulOp:expand()
	local res = self:applyDistribute()
	if res then return res end
	return self
end

--[[
a * (b + c) * d * e becomes
(a * b * d * e) + (a * c * d * e)
--]]
function mulOp:applyDistribute()
	local addOp = require 'symmath.addOp'
	local subOp = require 'symmath.subOp'
	for i,x in ipairs(self.xs) do
		if x:isa(addOp) or x:isa(subOp) then
			local terms = table()
			for j,xch in ipairs(x.xs) do
				local term = self:clone()
				term.xs[i] = xch:clone()
				terms:insert(term)
			end
			return getmetatable(x)(unpack(terms))
		
			--[[
			local newSelf = getmetatable(x)(unpack(self.xs:filter(function(cx) 
				return cx ~= x
			end):map(function(cx)
				return mulOp(x:clone(), cx)
			end))
			--]]
			--[[
			local removedTerm = newSelf.xs:remove(i)
			print('removed ',removedTerm)
			local newe = expand(addOp(unpack(
				x.xs:map(function(addX)
					return mulOp(addX, unpack(newSelf))
				end)
			)))
			print('new expand',newe)
			return newe
			--]]
		end
	end
	
	--[[
	--do return self end

	-- distribute: a * (m + n) => a * m + a * n
	-- I have the opposite rule in addOp:prune, commented out
	-- to combine them both ...
	-- (a * (b + c * (d + e)) => (a * b + a * c * d + a * c * e)
	-- how about my canonical form is div, mul-non-const, add, mul-const
	-- ... such that if we have an add, mul-non-const then we know to perform the addOp:prune() on it
	-- however trig laws would need add, mul-non-const to optimize out correctly
	for i,x in ipairs(self.xs) do
		if x:isa(addOp) then
			self:removeChild(i)
		
			local result = addOp()
			for j,ch in ipairs(x.xs) do
				result.xs[j] = self * ch
			end
			--result = prune(result)
			return result
		end
	end
	--]]
end

mulOp.__eq = nodeCommutativeEqual

return mulOp

