require 'ext'
local Expression = require 'symmath.Expression'
local expand = require 'symmath.expand'

local BinaryOp = class(Expression)

function BinaryOp:toVerboseStr()
	return 'BinaryOp{'..self.name..'}['..self.xs:map(tostring):concat(', ')..']'
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

