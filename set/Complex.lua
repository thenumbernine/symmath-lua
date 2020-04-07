local class = require 'ext.class'
local Universal = require 'symmath.set.Universal'

local Complex = class(Universal)

function Complex:containsSet(other)
	if require 'symmath.set.Real':contains(other) then
		return true
	end
	return Complex.super.containsSet(self, other)
end

function Complex:containsElement(x)
	-- right now Constant is either symmath.complex or Lua number.
	if Constant.is(x) then return true end
end

return Complex
