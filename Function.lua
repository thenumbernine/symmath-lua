require 'ext'

local Expression = require 'symmath.expression'
local Constant = require 'symmath.constant'

local Function = class(Expression)
Function.precedence = 10	-- high since it will always show parenthesis
Function.name = 'Function'

function Function:evaluateConstants()
	for i=1,#self.xs do
		if self.xs[i]:isa(Constant) then
			self.xs[i] = Constant(self.func(node.value))
		end
	end
end

function Function:eval()
	return self.func(unpack(self.xs:map(function(node) 
		return node:eval()
	end)))
end

return Function

