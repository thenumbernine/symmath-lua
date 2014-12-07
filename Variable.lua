require 'ext'

local Expression = require 'symmath.Expression'
local Constant = require 'symmath.Constant'

local Variable = class(Expression)
Variable.precedence = 10	-- high since it will never have nested members 
Variable.name = 'Variable'
variable = Variable	-- shorthand / case convention

-- the old 'value' assignment is going to be replaced with :replace()
-- 'deferDiff' replaced with a list of dependencies, assigned with :depends()
function Variable:init(name, dependentVars)
	self.name = name
	self.dependentVars = table(dependentVars)
end

function Variable:clone()
	-- return variable references ... so if the original gets modified, the rest will be updated as well
	return self
end

function Variable.__eq(a,b)
	if getmetatable(a) ~= getmetatable(b) then return false end
	return a.name == b.name
end

-- assign or concatenate?
-- Maxima would concatenate 
-- but that'd leave us no room to remove
-- so I'll assign
function Variable:depends(...)
	self.dependentVars = table{...}
end

return Variable

