local class = require 'ext.class'
local table = require 'ext.table'
local Expression = require 'symmath.Expression'

local Variable = class(Expression)
Variable.precedence = 10	-- high since it will never have nested members 
Variable.name = 'Variable'

--[[
args:
	name = name of variable
	dependentVars = variables this var is dependent on
	value = numerical value of this variable
--]]
function Variable:init(name, dependentVars, value)
	self.name = name
	self.dependentVars = table(dependentVars)
	self.value = value
end

function Variable:clone()
	-- return variable references ... so if the original gets modified, the rest will be updated as well
	return self
end

-- used for comma derivatives
-- override this to override for anholonomic basis
function Variable:applyDiff(x)
	return x:diff(self)
end

-- [[ this is the same as Derivative.visitors.Prune.self
-- either is interoperable (right?)
-- (TODO double check this with the non-coordinate derivatives that are used to create commutation coefficients)
function Variable:evaluateDerivative(deriv, ...)
	local derivs = {...}
	if #derivs == 1 and derivs[1] == self then
		return require 'symmath.Constant'(1)
	end
	for i=1,#derivs do
		if derivs[i] == self then
			return require 'symmath.Constant'(0)
		end
	end
end
--]]

-- Variable equality is by name and value at the moment
-- this way log(e) fails to simplify, but log(symmath.e) simplifies to 1 
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

Variable.rules = {
	Eval = {
		{apply = function(eval, expr)
			if expr.value then 
				assert(type(expr.value) == 'number')
				return expr.value
			end
			error("Eval: Variable "..tostring(expr).." wasn't given a value, or replace()'d with a Constant")
		end},
	},
}

return Variable
