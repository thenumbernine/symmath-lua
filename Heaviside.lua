local class = require 'ext.class'
local table = require 'ext.table'
local Function = require 'symmath.Function'

local Heaviside = class(Function)

Heaviside.name = 'Heaviside'
Heaviside.nameForExporterTable = {}
Heaviside.nameForExporterTable.LaTeX = '\\mathcal{H}'
Heaviside.code = 'function(x) return x >= 0 and 1 or 0 end'

function Heaviside:evaluateDerivative(deriv, ...)
	return require 'symmath.Constant'(0)
end

return Heaviside
