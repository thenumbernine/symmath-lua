local class = require 'ext.class'
local table = require 'ext.table'
local Function = require 'symmath.Function'
local abs = class(Function)
abs.name = 'abs'
abs.func = math.abs
function abs:evaluateDerivative(...)
	error('not just yet')
	-- TODO - heaviside step?  or conditions?
end
return abs
