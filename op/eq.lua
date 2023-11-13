local Equation = require 'symmath.op.Equation'

local eq = Equation:subclass()

-- should op names be paths for compatability with export.SymMath?
eq.name = '='
eq.nameForExporterTable = {}
eq.nameForExporterTable.Language = '=='
eq.nameForExporterTable.SymMath = 'eq'	-- used as a member function name

function eq:isTrue()
	return self[1] == self[2]
end

--[[
I think i put other member functions in Equation, but this is specific to equals ...
Works just like Variable:inferDependentVars or TensorRef:inferDependentVars,
except it assumes you are inferring for the lhs based on the rhs

TODO something similar for linear systems, since Variable: and TensorRef: (and Expression:) handle inferring from multiple expressions
TODO TODO am I naming too many functions the same name that do somewhat different things? Expression, Variable/TensorRef, eq ... ?
--]]
function eq:inferDependentVars()
	self:lhs():inferDependentVars(self:rhs())
end

return eq
