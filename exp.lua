local class = require 'ext.class'
local table = require 'ext.table'
local Function = require 'symmath.Function'

local exp = class(Function)
exp.name = 'exp'
--exp.func = math.exp
exp.func = require 'symmath.complex'.exp

function exp:evaluateDerivative(...)
	local x = table.unpack(self):clone()
	local diff = require 'symmath.Derivative'
	return diff(x,...) * self:clone()
end

function exp:reverse(soln, index)
	return require 'symmath.log'(soln)
end

return exp
