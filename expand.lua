local unmOp = require 'symmath.unmOp'
local mulOp = require 'symmath.mulOp'
local powOp = require 'symmath.powOp'
local Constant = require 'symmath.Constant'
local Visitor = require 'symmath.Visitor'
local Expand = class(Visitor)

Expand.lookupTable = {
	[unmOp] = function(expand, self)
		return expand(Constant(-1) * self.xs[1])
	end,
	[mulOp] = function(expand, self)
		return self:applyDistribute()
	end,
	[powOp] = function(expand, self)
		local maxPowerExpand = 10
		if self.xs[2]:isa(Constant) then
			local value = self.xs[2].value
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
					return Constant(1)
				end
				local terms = table()
				for i=1,num do
					terms:insert(self.xs[1]:clone())
				end
				if frac ~= 0 then
					terms:insert(self.xs[1]:clone()^frac)
				end
				if div then
					return Constant(1)/mulOp(unpack(terms))
				else
					return mulOp(unpack(terms))
				end
			end
		end
	end,
}

return Expand()

