local class = require 'ext.class'
local table = require 'ext.table'
local Function = require 'symmath.Function'

local log = class(Function)
log.name = 'log'
--log.func = math.log
log.func = require 'symmath.complex'.log

function log:evaluateDerivative(...)
	local x = table.unpack(self):clone()
	local diff = require 'symmath.Derivative'
	return diff(x,...) / x
end

function log:reverse(soln, index)
	return require 'symmath.exp'(soln)
end

return log
