local class = require 'ext.class'
local table = require 'ext.table'
local Function = require 'symmath.Function'

local abs = class(Function)
abs.name = 'abs'
--abs.func = math.abs
abs.func = require 'symmath.complex'.abs

function abs:evaluateDerivative(...)
	error('not just yet')
	-- TODO - heaviside step?  or conditions?
end

function abs:reverse(soln, index)
	-- y = |x| => x = y, x = -y
	return soln, -soln
end

return abs
