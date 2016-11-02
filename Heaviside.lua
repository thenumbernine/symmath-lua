local class = require 'ext.class'
local table = require 'ext.table'
local Function = require 'symmath.Function'
local Heaviside = class(Function)
Heaviside.name = 'Heaviside'
Heaviside.code = 'function(x) return x >= 0 and 1 or 0 end'
function Heaviside:evaluateDerivative(...)
	return symmath.Constant(0)
end
return Heaviside
