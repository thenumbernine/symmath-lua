local class = require 'ext.class'
local Equation = require 'symmath.op.Equation'

local eq = class(Equation)

-- should op names be paths for compatability with export.SymMath?
eq.name = '='
eq.nameForExporterTable = {}
eq.nameForExporterTable.Language = '=='
eq.nameForExporterTable.SymMath = 'eq'	-- used as a member function name

function eq:isTrue()
	return self[1] == self[2]
end

return eq
