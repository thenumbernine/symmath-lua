require 'ext'

local Constant = require 'symmath.Constant'
local BinaryOp = require 'symmath.BinaryOp'
local log = require 'symmath.log'
local diff = require 'symmath.diff'

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
function powOp:diff(...)
	local a, b = unpack(self.xs)
	local x = a ^ b * (diff(b, ...) * log(a) + diff(a, ...) * b / a)
--	x = prune(x)
	return x
end

function powOp:eval()
	local a, b = unpack(self.xs)
	return a:eval() ^ b:eval()
end

function powOp:expand()
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
	return self
end

return powOp

