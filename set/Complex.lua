local class = require 'ext.class'
local Set = require 'symmath.set.Set'

local Complex = class(Set)

local symmath
function Complex:isSubsetOf(s)
	symmath = symmath or require 'symmath'
	if symmath.set.Complex:isa(s) then return true end
	if symmath.set.Universal:isSubsetOf(s) then return true end
end

-- TODO even nan?
function Complex:containsNumber(x)
	assert(type(x) == 'number')
	return true
end

-- TODO even nan?
local complex = require 'complex'
function Complex:containsComplex(x)
	assert(complex:isa(x))
	return true
end

return Complex
