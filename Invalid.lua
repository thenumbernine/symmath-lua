--[[
TODO rename this to 'indeterminate', as in 'indeterminate form':
https://en.wikipedia.org/wiki/Indeterminate_form
https://functions.wolfram.com/Constants/Indeterminate/introductions/Symbols/ShowAll.html
0/0, inf/inf, 0*inf, inf-inf, 0^0, 1^inf, inf^0


TODO how about replacing this all with a builtin Variable with value NaN ?
then copy the same nameForExporterTable across to it upon symmath init

--]]
local class = require 'ext.class'
local table = require 'ext.table'
local Expression = require 'symmath.Expression'

local Invalid = class(Expression)
Invalid.name = 'Invalid'
Invalid.nameForExporterTable = setmetatable(table(Invalid.nameForExporterTable), nil)
Invalid.nameForExporterTable.C = 'NAN'
Invalid.nameForExporterTable.GnuPlot = '(0/0)'
Invalid.nameForExporterTable.JavaScript = '(0/0)'
Invalid.nameForExporterTable.LaTeX = '¿'
Invalid.nameForExporterTable.Mathematica = '¿'
Invalid.nameForExporterTable.MultiLine = 'nan'
Invalid.nameForExporterTable.SingleLine = 'nan'
Invalid.nameForExporterTable.SymMath = 'symmath.invalid'

-- this behavior would be true to NaNs, but I'm not trying to reproduce IEEE standards.
--function Invalid.__eq(a,b) return false end

function Invalid:evaluateDerivative(deriv, ...)
	return self
end

return Invalid
