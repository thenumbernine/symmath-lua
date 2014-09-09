require 'ext'

local BinaryOp = require 'symmath.BinaryOp'
local diff = require 'symmath.diff'

local modOp = class(BinaryOp)
modOp.precedence = 3
modOp.name = '%'

--[[
d/dx[a%b] is da/dx, except when a = b * k for some integer k
--]]
function modOp:diff(...)
	local a, b = unpack(self.xs)
	local x = diff(a, ...)
	return x
end

function modOp:eval()
	local a, b = unpack(self.xs)
	return a:eval() % b:eval()
end

return modOp

