local class = require 'ext.class'
local Equation = require 'symmath.op.Equation'

local ne = class(Equation)

ne.name = '!='	-- sorry Lua ...

function ne:switch()
	local a,b = table.unpack(self)
	return b:ne(a)
end

function ne:isTrue()
	return self[1] ~= self[2]
end

return ne
