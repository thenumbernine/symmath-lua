local Equation = require 'symmath.op.Equation'

local le = Equation:subclass()

le.name = '≤'
le.nameForExporterTable = {}
le.nameForExporterTable.LaTeX = '\\le'
le.nameForExporterTable.Language = '<='
le.nameForExporterTable.SymMath = 'le'

function le:switch()
	local a,b = table.unpack(self)
	return b:ge(a)
end

function le:isTrue()
	if self[1]:getRealRange():last().finish <= self[2]:getRealRange()[1].start then return true end
	if self[1]:getRealRange()[1].start >= self[2]:getRealRange():last().finish then return false end
end

return le
