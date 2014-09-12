require 'ext'
local Expression = require 'symmath.Expression'

local BinaryOp = class(Expression)

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

