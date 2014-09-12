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
function powOp:diff(...)
	local a, b = unpack(self.xs)
	local diff = require 'symmath'.diff
	local x = a ^ b * (diff(b, ...) * log(a) + diff(a, ...) * b / a)
--	x = prune(x)
	return x
end

function powOp:eval()
	local a, b = unpack(self.xs)
	return a:eval() ^ b:eval()
end

return powOp

