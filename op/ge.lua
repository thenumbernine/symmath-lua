local class = require 'ext.class'
local Equation = require 'symmath.op.Equation'

local ge = class(Equation)

ge.name = '≥'
ge.nameForExporterTable = {}
ge.nameForExporterTable.LaTeX = '\\ge'
ge.nameForExporterTable.Language = '>='
ge.nameForExporterTable.SymMath = 'ge'

function ge:switch()
	local a,b = table.unpack(self)
	return b:le(a)
end

function ge:isTrue()
	if self[1]:getRealRange()[1].start >= self[2]:getRealRange():last().finish then return true end
	if self[1]:getRealRange():last().finish <= self[2]:getRealRange()[1].start then return false end
end

return ge
