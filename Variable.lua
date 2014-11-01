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
	return Variable(self.name, self.dependentVars) 
end

-- [[
function Variable:diff(...)
	--[[
	local diffs = table{...}
	if #diffs == 1 and diffs[1] == self then
		return Constant(1)
	end
	
	-- if any variable in ... is not in dependentVars
	-- then we can assert that the derivative of this with respect to that is zero
	-- and everything is zero
	for _,x in ipairs{...} do
		if not self.dependentVars:find(x) then
			return Constant(0)
		end
	end
	--]]	
	local Derivative = require 'symmath.Derivative'
	return Derivative(self, ...)
end
--]]

function Variable:eval()
	error("found a variable that wasn't replace()'d with a constant")
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

