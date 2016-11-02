local class = require 'ext.class'
local Expression = require 'symmath.Expression'

local Function = class(Expression)
Function.precedence = 10	-- high since it will always show parenthesis
Function.name = 'Function'

function Function:evaluateConstants()
	local Constant = require 'symmath.Constant'
	for i=1,#self do
		if Constant.is(self[i]) then
			self[i] = Constant(self.func(node.value))
		end
	end
end

Function.visitorHandler = {
	Eval = function(eval, expr)
		return expr.func(table.map(expr, function(node, k)
			if type(k) ~= 'number' then return end
			return eval:apply(node)
		end):unpack())
	end,
}

return Function
