local class = require 'ext.class'
local Set = require 'symmath.set.Set'

-- the set of all things
local Universal = class(Set)

--[[
so this is 'true'
but then all subclasses are 'true'
but contrarily any subset of Universal that isn't equal will have a 'false' somewhere
so the subclass == subset idea is a bad one from the implementation perspective

TODO replace with lookup/rules and just have Universal.rules['*'] = return true
then do rules based on Lua type or based on symmath class
--]]
function Universal:containsNumber(x) return true end
function Universal:containsComplex(x) return true end
function Universal:containsConstant(x) return true end
function Universal:containsSet(x) return true end
function Universal:containsVariable(x) return true end
function Universal:containsExpression(x) return true end

function Universal:isSubsetOf(x)
	return Universal:isa(x)
end

return Universal
