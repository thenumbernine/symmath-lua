require 'ext'

local Constant = require 'symmath.Constant'
local BinaryOp = require 'symmath.BinaryOp'
local log = require 'symmath.log'

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
function powOp:evaluateDerivative(...)
	local a, b = table.unpack(self)
	a, b = a:clone(), b:clone()
	local diff = require 'symmath'.diff
	return a ^ b * (diff(b, ...) * log(a) + diff(a, ...) * b / a)
end

-- just for this
-- temporary ...
function powOp:expand()
	-- for certain small integer powers, expand 
	-- ... or should we have all integer powers expended under a different command?
	if self[2]:isa(Constant)
	and self[2].value >= 0
	and self[2].value < 10
	and self[2].value == math.floor(self[2].value)
	then
		local result = Constant(1)
		for i=1,self[2].value do
			result = result * self[1]:clone()
		end
		return result:simplify()
	end
end

return powOp

