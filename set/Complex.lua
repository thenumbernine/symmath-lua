local class = require 'ext.class'
local Universal = require 'symmath.set.Universal'
local complex = require 'symmath.complex'
local Constant = require 'symmath.Constant'

local Complex = class(Universal)

function Complex:containsSet(other)
	if require 'symmath.set.sets'.real:contains(other) then
		return true
	end
	return Complex.super.containsSet(self, other)
end

function Complex:containsVariable(x)
	if Complex.super.containsVariable(self, x) == false then return false end
	if complex:isa(x.value) then return true end
end

function Complex:containsElement(x)
	if Complex.super.containsElement(self, x) == false then return false end
	if self:containsVariable(x) then return true end

	-- right now Constant is either symmath.complex or Lua number.
	if Constant:isa(x) then return true end
	if complex:isa(x) then return true end

	if require 'symmath.set.sets'.real:contains(x) then return true end
end

return Complex
