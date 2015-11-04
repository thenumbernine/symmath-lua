local class = require 'ext.class'
local Expression = require 'symmath.Expression'

local BinaryOp = class(Expression)

function BinaryOp:init(...)
	BinaryOp.super.init(self, ...)
--	assert(#self > 1)
end

function BinaryOp:getSepStr()
	local sep = self.name
	if self.implicitName then 
		sep = ' '
	elseif not self.omitSpace then 
		sep = ' ' .. sep .. ' ' 
	end
	return sep
end

return BinaryOp

