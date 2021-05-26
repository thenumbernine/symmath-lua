local class = require 'ext.class'
local Equation = require 'symmath.op.Equation'

local lt = class(Equation)

lt.name = '<'
lt.nameForExporterTable = {}
lt.nameForExporterTable.LaTeX = '\\lt'
lt.nameForExporterTable.SymMath = 'lt'

function lt:switch()
	local a,b = table.unpack(self)
	return b:gt(a)
end

function lt:isTrue()
	if self[1]:getRealRange():last().finish < self[2]:getRealRange()[1].start then return true end
	if self[1]:getRealRange()[1].start > self[2]:getRealRange():last().finish then return false end
end

return lt
