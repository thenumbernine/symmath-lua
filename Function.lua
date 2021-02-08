local class = require 'ext.class'
local table = require 'ext.table'
local Expression = require 'symmath.Expression'

local Function = class(Expression)
Function.precedence = 10	-- high since it will always show parenthesis
Function.name = 'Function'

-- [[ Seems no one is calling this anymore.  It looks like :eval() or :compile() serves its purpose now.
function Function:evaluateConstants()
	local Constant = require 'symmath.Constant'
	local complex = require 'symmath.complex'
	for i=1,#self do
		if Constant:isa(self[i]) then
			self = self:shallowCopy()
			if complex:isa(self[i].value) then
				self[i] = Constant(self.cplxFunc(node.value))
			else
				self[i] = Constant(self.realFunc(node.value))
			end
		end
	end
	return self
end
--]]

-- [[ :eval() is another one I question.  Why not just use :compile()?
Function.rules = {
	Eval = {
		{apply = function(eval, expr)
			-- visitors are child-first, right?  then we don't need to call 
			-- but visitors don't store Lua-numbers, I think they clone them, so these will be constants ...
			return expr.realFunc(table.mapi(expr, function(node, k)
				return node.value
			end):unpack())
		end},
	},
}
--]]

return Function
