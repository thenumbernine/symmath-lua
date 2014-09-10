require 'ext'
local Constant = require 'symmath.Constant'
local BinaryOp = require 'symmath.BinaryOp'
local diff = require 'symmath.diff'
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
				termRes.xs:insert(diff(self.xs[j], ...))
			else
				termRes.xs:insert(self.xs[j])
			end
		end
		sumRes.xs:insert(termRes)
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
			self.xs:remove(i)
		
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

