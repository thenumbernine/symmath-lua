local class = require 'ext.class'
local Function = require 'symmath.Function'
local cosh = class(Function)
cosh.name = 'cosh'
cosh.func = math.cosh
function cosh:evaluateDerivative(...)
	local x = table.unpack(self):clone()
	local sinh = require 'symmath.sinh'
	local diff = require 'symmath'.diff
	return diff(x,...) * sinh(x)
end
return cosh
