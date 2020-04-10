local class = require 'ext.class'
local table = require 'ext.table'
local complex = require 'symmath.complex'
local Expression = require 'symmath.Expression'

--[[
fields:
	name = variable name
	dependentVars = table of vars that this var depends on
	value = (optional) value of this var ... as a Lua number
	set = what set does this variable belong to?
--]]
local Variable = class(Expression)

Variable.precedence = 10	-- high since it will never have nested members 

Variable.name = 'Variable'

--[[
args:
	name = name of variable
	dependentVars = variables this var is dependent on
	value = numerical value of this variable
--]]
function Variable:init(name, dependentVars, value, set)
	self.name = name
	self.dependentVars = table(dependentVars)
	self.value = value
	if not set then
		if complex.is(value) then 
			set = require 'symmath.set.sets'.complex
		elseif type(value) == 'number' then
			set = require 'symmath.set.sets'.real
		else
			-- default set ... Real or Universal?
			set = require 'symmath.set.sets'.real	
		end
	end
	self.set = set 
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

--[[ this is the same as Derivative.visitors.Prune.self
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
	if getmetatable(a) ~= getmetatable(b) then 
		return Variable.super.__eq(a,b)
	end
	return a.name == b.name
end

-- assign or concatenate?
-- Maxima would concatenate 
-- but that'd leave us no room to remove
-- so I'll assign
function Variable:depends(...)
	self.dependentVars = table{...}
end

function Variable:getRealDomain()
	local RealDomain = require 'symmath.set.RealDomain'
	if self.value then 
		if type(self.value) == 'number' then
			return RealDomain(self.value, self.value, true, true)
		elseif complex.is(self.value) and self.value.im == 0 then
			return RealDomain(self.value.re, self.value.re, true, true)
		end
	end
	if RealDomain.is(self.set) then return self.set end
	-- assuming start and finish are defined in all Real's subclasses
	-- what about Integer?  Integer's RealInterval is discontinuous ...
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
