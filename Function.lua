require 'ext'

local Expression = require 'symmath.Expression'
local Constant = require 'symmath.Constant'

local Function = class(Expression)
Function.precedence = 10	-- high since it will always show parenthesis
Function.name = 'Function'

function Function:evaluateConstants()
	for i=1,#self do
		if self[i]:isa(Constant) then
			self[i] = Constant(self.func(node.value))
		end
	end
end

return Function

